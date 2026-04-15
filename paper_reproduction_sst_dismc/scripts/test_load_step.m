function [results, metrics_tbl] = test_load_step(params)
controllers = {'PI','SISMC','DISMC'};
results = struct();
metrics = [];

fig = figure('Visible','off');
for i = 1:numel(controllers)
    c = controllers{i};
    simout = simulate_case(params, c, 'loadstep', 1.0);
    results.(c) = simout;

    m = compare_metrics(simout, params, 'loadstep');
    metrics = [metrics; struct2table(m)]; %#ok<AGROW>

    plot(simout.t*1e3, simout.vo, 'LineWidth', 1.4); hold on;
end
plot(results.PI.t*1e3, results.PI.vref, 'k--', 'LineWidth', 1.0);

grid on; xlabel('Time [ms]'); ylabel('v_o [V]');
title('Load Step Comparison (120\Omega -> 60\Omega -> 120\Omega)');
legend({'PI','SISMC','DISMC','v_{ref}'}, 'Location','best');
saveas(fig, fullfile(params.path.results, 'fig_loadstep_compare.png'));
close(fig);

metrics_tbl = metrics;
end
