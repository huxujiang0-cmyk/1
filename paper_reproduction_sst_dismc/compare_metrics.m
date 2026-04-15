function metrics = compare_metrics(simout, params, mode)
%COMPARE_METRICS Calculate dynamic metrics from simulation output.

t = simout.t;
y = simout.vo;
r = simout.vref;

metrics = struct();
metrics.controller = simout.controller;
metrics.scenario = simout.scenario;
metrics.mode = mode;

switch lower(mode)
    case 'startup'
        y_final = r(end);
        y_peak = max(y);
        metrics.overshoot_pct = max((y_peak - y_final) / max(y_final,1e-9) * 100, 0);

        idx10 = find(y >= 0.1*y_final, 1, 'first');
        idx90 = find(y >= 0.9*y_final, 1, 'first');
        if isempty(idx10) || isempty(idx90)
            metrics.rise_time = NaN;
        else
            metrics.rise_time = t(idx90) - t(idx10);
        end

        band = params.sim.metric_band * y_final;
        idx_settle = find(abs(y - y_final) > band, 1, 'last');
        if isempty(idx_settle)
            metrics.settling_time = 0;
        else
            metrics.settling_time = t(idx_settle);
        end

    case 'loadstep'
        t1 = params.test.load_step_t1;
        t2 = params.test.load_step_t2;
        [metrics.drop_pct, metrics.recover_time_1] = local_step_metrics(t,y,r,t1,params.sim.metric_band);
        [metrics.bump_pct, metrics.recover_time_2] = local_step_metrics(t,y,r,t2,params.sim.metric_band);

    case 'perturb'
        y_nom = r;
        dev = abs(y - y_nom) ./ max(y_nom,1e-9) * 100;
        metrics.max_dev_pct = max(dev);
        metrics.rms_dev_pct = rms(dev);

    case 'composite'
        metrics.max_abs_err = max(abs(r-y));
        metrics.rms_err = rms(r-y);

    otherwise
        error('Unknown mode: %s', mode);
end

end

function [amp_pct, rec_t] = local_step_metrics(t,y,r,t0,band_ratio)
idx0 = find(t>=t0,1,'first');
if isempty(idx0)
    amp_pct = NaN; rec_t = NaN; return;
end

window = idx0:min(length(t), idx0 + round(0.02/(t(2)-t(1))));
r0 = r(idx0);
if r0 < 1e-6
    amp_pct = NaN;
else
    amp_pct = max(abs(y(window)-r0))/r0*100;
end

band = band_ratio * r0;
idx_rec = find(abs(y(idx0:end)-r0) <= band, 1, 'first');
if isempty(idx_rec)
    rec_t = NaN;
else
    rec_t = t(idx0+idx_rec-1) - t0;
end
end
