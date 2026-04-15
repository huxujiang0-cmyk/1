function out = controller_utils(mode, varargin)
%CONTROLLER_UTILS Utility functions for SST DISMC project.

switch lower(mode)
    case 'sat'
        x = varargin{1}; lo = varargin{2}; hi = varargin{3};
        out = min(max(x, lo), hi);

    case 'tanh_sign'
        s = varargin{1}; mu = varargin{2};
        out = tanh(s / max(mu, 1e-8));

    case 'u_to_d3'
        % 论文控制映射：在 φ≈π/2，δ* = asin(u_eq)，D3* = δ*/π
        u = varargin{1};
        u = min(max(u, -0.999), 0.999);
        delta = asin(u);
        out = delta / pi;

    case 'd3_to_power_gain'
        % SPS 平均功率增益近似，留有 EPS/DPS/TPS 扩展接口。
        D3 = varargin{1};
        D1 = varargin{2};
        D2 = varargin{3};
        % 工程近似：p_norm ~ sin(pi*D3) * (D1*D2)
        out = sin(pi * D3) * (D1 * D2);

    otherwise
        error('Unknown mode: %s', mode);
end

end
