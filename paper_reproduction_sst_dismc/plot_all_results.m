function plot_all_results(all_results, params)
%PLOT_ALL_RESULTS Generate additional summary figures.

% Startup comparison
fig = figure('Visible','off');
plot(all_results.startup.PI.t*1e3, all_results.startup.PI.vo, 'LineWidth',1.2); hold on;
plot(all_results.startup.SISMC.t*1e3, all_results.startup.SISMC.vo, 'LineWidth',1.2);
plot(all_results.startup.DISMC.t*1e3, all_results.startup.DISMC.vo, 'LineWidth',1.2);
plot(all_results.startup.DISMC.t*1e3, all_results.startup.DISMC.vref, 'k--');
grid on; xlabel('Time [ms]'); ylabel('v_o [V]');
title('Startup Compare: PI vs SISMC vs DISMC');
legend('PI','SISMC','DISMC','v_{ref}','Location','best');
saveas(fig, fullfile(params.path.results, 'fig_startup_compare_all.png'));
close(fig);

end
