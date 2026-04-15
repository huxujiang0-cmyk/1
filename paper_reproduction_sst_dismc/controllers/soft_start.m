function vref = soft_start(t, v_target, t_ramp)
%SOFT_START 线性软启动参考生成
if t <= 0
    vref = 0;
elseif t < t_ramp
    vref = v_target * (t / t_ramp);
else
    vref = v_target;
end
end
