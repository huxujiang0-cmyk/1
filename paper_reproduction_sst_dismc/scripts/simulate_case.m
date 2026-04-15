function simout = simulate_case(params, controller_name, scenario, L_scale)
%SIMULATE_CASE Averaged SST simulation for controller/scenario.
% 说明：
% - 前级 TPBR 用平均模型近似：保持 vdc 在参考附近并具有扰动恢复动态
% - 后级 IBDC 采用 SPS 等效模型，保留 D1/D2/D12/D3 接口

if nargin < 4
    L_scale = 1.0;
end

cfg = params;
dt = cfg.sim.dt;
Tend = get_Tend(cfg, scenario);
N = floor(Tend / dt) + 1;
t = (0:N-1)' * dt;

% states
vdc = zeros(N,1);
vo = zeros(N,1);
io = zeros(N,1);
iL = zeros(N,1);
va = zeros(N,1); ia = zeros(N,1);  % 以 C 相替代展示，变量名保持论文需求“相电压/相电流”

vdc(1) = 0;
vo(1) = 0;
iL(1) = 0;

% controller state
st = struct('int_e',0,'int2_e',0,'s',0);

% constants
L = cfg.elec.Leq * L_scale;
Req = cfg.elec.Req;
Co = cfg.elec.Co;
C1 = cfg.elec.C1;
Vg_peak = sqrt(2) * cfg.elec.V_phase_rms;
omega = 2*pi*cfg.elec.f_grid;

% logging control
u_log = zeros(N,1);
D3_log = zeros(N,1);
vref_log = zeros(N,1);
Rload_log = zeros(N,1);

for k = 1:N-1
    tk = t(k);
    [Rload, vdc_ref, vout_ref] = scenario_profile(cfg, scenario, tk);

    % soft-start only in startup/perturb cases
    if strcmpi(scenario, 'startup') || strcmpi(scenario, 'perturb')
        vout_ref_eff = soft_start(tk, vout_ref, cfg.sim.soft_start_time);
    else
        vout_ref_eff = vout_ref;
    end

    e = vout_ref_eff - vo(k);

    switch upper(controller_name)
        case 'PI'
            [u, st] = pi_controller(e, st, cfg, dt);
            D3 = controller_utils('u_to_d3', u);
        case 'SISMC'
            [u, st] = sismc_controller(e, st, cfg, dt);
            D3 = controller_utils('u_to_d3', u);
        case 'DISMC'
            [u, st, ex] = dismc_controller(e, st, cfg, dt);
            D3 = ex.D3_star;
        otherwise
            error('Unknown controller: %s', controller_name);
    end

    % SPS 参数（论文变量映射）
    D1 = cfg.mod.D1;
    D2 = cfg.mod.D2;
    D12 = D3; % SPS: D3=D12

    alpha = pi * D1 / 2;
    beta  = pi * D2 / 2;
    delta = pi * D3;
    %#ok<NASGU> % 仅用于公式映射说明

    p_gain = controller_utils('d3_to_power_gain', D12, D1, D2);

    % IBDC averaged dynamics (engineering approximation)
    Vpri = max(vdc(k),0);
    Vsec_equ = cfg.elec.n * vo(k);

    diL = (Vpri * p_gain - Vsec_equ - Req * iL(k)) / max(L,1e-9);
    iL(k+1) = iL(k) + dt * diL;

    io(k) = vo(k) / max(Rload,1e-6);
    dvo = (cfg.elec.n * iL(k) - io(k)) / Co;
    vo(k+1) = max(vo(k) + dt * dvo, 0);

    % TPBR averaged vdc dynamics with disturbance rejection effect
    Pin = (vdc_ref - vdc(k)) * cfg.tpbr.vdc_damping;
    Pout = vo(k) * io(k) + 0.5 * Req * iL(k)^2;
    dvdc = (Pin - Pout) / max(C1 * max(vdc(k),20), 1e-6);
    vdc(k+1) = max(vdc(k) + dt * dvdc, 0);

    % input phase voltage/current trend (for composite disturbance figure)
    va(k) = Vg_peak * sin(omega*tk + 2*pi/3); % C 相等价展示
    % current with near-unity PF + transient ripple related to vdc error
    ia(k) = 0.08 * va(k) + 0.03 * (vdc_ref - vdc(k));

    % logs
    u_log(k) = u;
    D3_log(k) = D3;
    vref_log(k) = vout_ref_eff;
    Rload_log(k) = Rload;
end

io(end) = vo(end) / max(Rload_log(end),1e-6);
va(end) = Vg_peak * sin(omega*t(end) + 2*pi/3);
ia(end) = 0.08 * va(end) + 0.03 * (cfg.elec.Vdc_ref - vdc(end));

simout = struct();
simout.t = t;
simout.vdc = vdc;
simout.vo = vo;
simout.io = io;
simout.iL = iL;
simout.v_phase_c = va;
simout.i_phase_c = ia;
simout.u = u_log;
simout.D3 = D3_log;
simout.vref = vref_log;
simout.Rload = Rload_log;
simout.controller = upper(controller_name);
simout.scenario = scenario;
simout.L_scale = L_scale;

end

function Tend = get_Tend(cfg, scenario)
switch lower(scenario)
    case 'startup'
        Tend = cfg.sim.Tend_startup;
    case 'loadstep'
        Tend = cfg.sim.Tend_loadstep;
    case 'perturb'
        Tend = cfg.sim.Tend_perturb;
    case 'composite'
        Tend = cfg.sim.Tend_composite;
    otherwise
        error('Unknown scenario: %s', scenario);
end
end

function [Rload, vdc_ref, vout_ref] = scenario_profile(cfg, scenario, t)
Rload = cfg.test.R_load_nominal;
vdc_ref = cfg.elec.Vdc_ref;
vout_ref = 220;

switch lower(scenario)
    case 'startup'
        % no extra disturbance
    case 'loadstep'
        if t >= cfg.test.load_step_t1 && t < cfg.test.load_step_t2
            Rload = cfg.test.R_load_step;
        end
    case 'perturb'
        if t >= cfg.test.load_step_t1 && t < cfg.test.load_step_t2
            Rload = cfg.test.R_load_step;
        end
    case 'composite'
        if t >= cfg.test.composite_t_load
            Rload = cfg.test.R_load_step;
        end
        if t >= cfg.test.composite_t_vdc_ref
            vdc_ref = cfg.test.vdc_ref_drop;
        end
        if t >= cfg.test.composite_t_vout_ref
            vout_ref = cfg.test.vout_ref_step;
        end
    otherwise
        error('Unknown scenario: %s', scenario);
end
end
