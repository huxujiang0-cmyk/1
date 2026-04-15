function [u, st] = sismc_controller(e, st, params, dt)
%SISMC_CONTROLLER 单积分滑模控制
% 论文思想映射：
%   s = e + k1*∫e dt
%   u = u_eq + k3*tanh(s/mu)

cfg = params.ctrl.sismc;

st.int_e = st.int_e + e * dt;
s = e + cfg.k1 * st.int_e;

% 等效项：使用线性近似项，使稳态有足够调节能力
u_eq = 0.004 * e + 0.0015 * st.int_e;
u_sw = cfg.k3 * controller_utils('tanh_sign', s, cfg.mu);

u_raw = u_eq + u_sw;
u = controller_utils('sat', u_raw, cfg.u_min, cfg.u_max);

st.s = s;
end
