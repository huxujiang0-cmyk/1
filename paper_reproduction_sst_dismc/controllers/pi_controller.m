function [u, st] = pi_controller(e, st, params, dt)
%PI_CONTROLLER 后级 PI 基准控制器
% 输入 e = v_ref - v_o

Kp = params.ctrl.pi.Kp;
Ki = params.ctrl.pi.Ki;

st.int_e = st.int_e + e * dt;
u_raw = Kp * e + Ki * st.int_e;

u = controller_utils('sat', u_raw, params.ctrl.pi.u_min, params.ctrl.pi.u_max);

% anti-windup (简单回算)
if u ~= u_raw
    st.int_e = st.int_e - 0.2 * (u_raw - u) / max(Ki, 1e-9);
end
end
