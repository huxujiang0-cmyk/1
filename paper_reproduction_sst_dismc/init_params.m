function params = init_params()
%INIT_PARAMS Parameter initialization for SST DISMC paper reproduction.
%  对应论文: 《基于双积分滑模控制的固态变压器电压控制策略》
%  说明:
%  - 本文件集中定义电路参数/控制参数/仿真参数/测试工况参数
%  - 所有“论文未给出”的参数均在 docs/assumptions_and_tuning.md 中解释

params = struct();

%% 1) 电路参数（论文表中给出）
params.elec = struct();
params.elec.V_phase_rms = 110;      % 三相相电压 RMS [V]（论文表）
params.elec.Vdc_ref = 220;          % 级间电压参考 [V]（论文表）
params.elec.Ls = 6e-3;              % TPBR 侧电感 [H]（论文表）
params.elec.C1 = 1880e-6;           % 级间电容 [F]（论文表）
params.elec.Co = 110e-6;            % IBDC 输出电容 [F]（论文表）
params.elec.Leq = 30e-6;            % 变压器等效电感 [H]（论文表）
params.elec.Req = 0.4;              % 变压器等效电阻 [Ohm]（论文表）
params.elec.n = 1;                  % 变压器变比（论文表）
params.elec.f_grid = 50;            % 电网频率 [Hz]（论文未明确，工程假设）

%% 2) IBDC/SPS 调制相关参数
params.mod = struct();
params.mod.fs_sw = 20e3;            % IBDC 开关频率 [Hz]（论文未给，工程假设）
params.mod.Ts_sw = 1 / params.mod.fs_sw;
params.mod.phi_approx = pi/2;       % 论文控制律近似 φ≈π/2

% 统一移相参数（论文变量）
% D1, D2, D12, D3, alpha, beta, delta
params.mod.D1 = 1;                  % SPS: D1=1
params.mod.D2 = 1;                  % SPS: D2=1
params.mod.D12 = 0.2;               % 初值，0<D12<=1
params.mod.D3 = params.mod.D12;     % SPS: D3 = D12
params.mod.alpha = pi * params.mod.D1 / 2;
params.mod.beta  = pi * params.mod.D2 / 2;
params.mod.delta = pi * params.mod.D3;

%% 3) 前级 TPBR dq 双闭环参数（论文未明确，工程整定）
params.tpbr = struct();
params.tpbr.enable_detailed_model = false; % true=启用 Simulink 细化前级；false=平均模型
params.tpbr.Kp_i = 5.0;             % 电流环比例
params.tpbr.Ki_i = 800.0;           % 电流环积分
params.tpbr.Kp_v = 0.8;             % 电压环比例
params.tpbr.Ki_v = 120.0;           % 电压环积分
params.tpbr.vdc_damping = 120;      % 平均模型对 vdc 的阻尼系数
params.tpbr.pf_target = 0.99;       % 功率因数目标

%% 4) 后级控制器参数（论文仅给方法，具体增益未完全给出 -> 工程整定）
params.ctrl = struct();

% PI 控制器
params.ctrl.pi.Kp = 0.035;
params.ctrl.pi.Ki = 130;
params.ctrl.pi.u_min = -0.95;       % 归一化控制量限幅
params.ctrl.pi.u_max = 0.95;

% SISMC（单积分滑模）
% 论文式：s = e + k1*∫e
params.ctrl.sismc.k1 = 350;
params.ctrl.sismc.k3 = 0.35;        % 切换项增益
params.ctrl.sismc.mu = 3.0;         % tanh 边界层厚度
params.ctrl.sismc.u_min = -0.98;
params.ctrl.sismc.u_max = 0.98;

% DISMC（双积分滑模）
% 论文式：s = e + k1*∫e + k2*∫∫e
% 控制律：u = u_eq + k3*tanh(s/mu), 在 φ≈π/2 时 δ*=asin(u_eq), D3*=δ*/π
params.ctrl.dismc.k1 = 480;
params.ctrl.dismc.k2 = 2.8e4;
params.ctrl.dismc.k3 = 0.30;
params.ctrl.dismc.mu = 2.5;
params.ctrl.dismc.u_min = -0.999;
params.ctrl.dismc.u_max = 0.999;

%% 5) 数值仿真参数
params.sim = struct();
params.sim.dt = 2e-6;               % 离散步长 [s]
params.sim.Tend_startup = 0.08;     % 工况1时长 [s]
params.sim.Tend_loadstep = 0.10;    % 工况2时长 [s]
params.sim.Tend_perturb = 0.10;     % 工况3时长 [s]
params.sim.Tend_composite = 0.40;   % 工况4时长 [s]
params.sim.soft_start_time = 0.02;  % 软启动时长 [s]
params.sim.metric_band = 0.02;      % 调节时间 ±2%

%% 6) 负载与扰动工况参数
params.test = struct();
params.test.R_load_nominal = 120;   % [Ohm]
params.test.R_load_step = 60;       % [Ohm]
params.test.load_step_t1 = 0.030;   % 工况2 负载切换时刻 [s]
params.test.load_step_t2 = 0.075;   % 工况2 恢复时刻 [s]

% 工况3 参数摄动
params.test.L_perturb_plus = 1.15;  % +15%
params.test.L_perturb_minus = 0.85; % -15%

% 工况4 综合扰动
params.test.composite_t_load = 0.1;
params.test.composite_t_vdc_ref = 0.2;
params.test.composite_t_vout_ref = 0.3;
params.test.vdc_ref_drop = 190;
params.test.vout_ref_step = 260;

%% 7) 结果输出
params.path = struct();
params.path.root = fileparts(mfilename('fullpath'));
params.path.results = fullfile(params.path.root, 'results');
params.path.docs = fullfile(params.path.root, 'docs');

if ~exist(params.path.results, 'dir')
    mkdir(params.path.results);
end

end
