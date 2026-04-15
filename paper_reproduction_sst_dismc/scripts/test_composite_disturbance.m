function [results, metrics_tbl] = test_composite_disturbance(params)
controllers = {'PI','SISMC','DISMC'};
results = struct();
metrics = [];

for i = 1:numel(controllers)
    c = controllers{i};
    simout = simulate_case(params, c, 'composite', 1.0);
    results.(c) = simout;
    m = compare_metrics(simout, params, 'composite');
    metrics = [metrics; struct2table(m)]; %#ok<AGROW>
end

% 按验收要求输出 C 相电压/电流、vdc、vo、io、iL（展示 DISMC）
s = results.DISMC;
fig = figure('Visible','off', 'Position', [100,100,920,850]);

subplot(5,1,1);
plot(s.t, s.v_phase_c, 'LineWidth',1.0); hold on;
plot(s.t, s.i_phase_c*100, 'LineWidth',1.0);
grid on; ylabel('v_c [V], i_c*100');
title('Composite Disturbance - DISMC');
legend('v_c','i_c*100','Location','best');

subplot(5,1,2); plot(s.t, s.vdc, 'LineWidth',1.2); grid on; ylabel('v_{dc} [V]');
subplot(5,1,3); plot(s.t, s.vo, 'LineWidth',1.2); hold on; plot(s.t, s.vref, '--'); grid on; ylabel('v_o [V]'); legend('v_o','v_{ref}');
subplot(5,1,4); plot(s.t, s.io, 'LineWidth',1.2); grid on; ylabel('i_o [A]');
subplot(5,1,5); plot(s.t, s.iL, 'LineWidth',1.2); grid on; ylabel('i_L [A]'); xlabel('Time [s]');

saveas(fig, fullfile(params.path.results, 'fig_composite_disturbance.png'));
close(fig);

metrics_tbl = metrics;
end
