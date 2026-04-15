function [results, metrics_tbl] = test_startup(params)
controllers = {'PI','SISMC','DISMC'};
results = struct();
metrics = [];

for i = 1:numel(controllers)
    c = controllers{i};
    simout = simulate_case(params, c, 'startup', 1.0);
    results.(c) = simout;
    m = compare_metrics(simout, params, 'startup');
    metrics = [metrics; struct2table(m)]; %#ok<AGROW>

    fig = figure('Visible','off');
    plot(simout.t*1e3, simout.vo, 'LineWidth', 1.4); hold on;
    plot(simout.t*1e3, simout.vref, '--', 'LineWidth', 1.0);
    grid on;
    xlabel('Time [ms]'); ylabel('v_o [V]');
    title(sprintf('Startup Response - %s', c));
    legend('v_o','v_{ref}','Location','best');
    saveas(fig, fullfile(params.path.results, sprintf('fig_startup_%s.png', c)));
    close(fig);
end

metrics_tbl = metrics;
end
