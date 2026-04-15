function [u, st, extra] = dismc_controller(e, st, params, dt)
%DISMC_CONTROLLER 双积分滑模控制
% 对应论文核心：
%   e = v_ref - v_o
%   s = e + k1*∫e dt + k2*∫∫e dt^2
%   使用 tanh(s/mu) 代替 sign(s)
%   在 φ≈π/2 条件下, δ*=asin(u_eq), D3*=δ*/π

cfg = params.ctrl.dismc;

st.int_e = st.int_e + e * dt;
st.int2_e = st.int2_e + st.int_e * dt;

s = e + cfg.k1 * st.int_e + cfg.k2 * st.int2_e;

% 等效控制项（工程实现）
u_eq_raw = 0.003 * e + 0.0018 * st.int_e + 0.00002 * st.int2_e;
u_eq = controller_utils('sat', u_eq_raw, cfg.u_min, cfg.u_max);

u_sw = cfg.k3 * controller_utils('tanh_sign', s, cfg.mu);
u_raw = u_eq + u_sw;
u = controller_utils('sat', u_raw, cfg.u_min, cfg.u_max);

delta_star = asin(controller_utils('sat', u_eq, -0.999, 0.999));
D3_star = delta_star / pi;

st.s = s;
extra = struct('u_eq', u_eq, 'u_sw', u_sw, 'delta_star', delta_star, 'D3_star', D3_star);
end
