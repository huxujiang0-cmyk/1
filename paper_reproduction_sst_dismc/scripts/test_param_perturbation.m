function [results, metrics_tbl] = test_param_perturbation(params)
controllers = {'PI','SISMC','DISMC'};
perturb = [params.test.L_perturb_minus, 1.0, params.test.L_perturb_plus];
plabel = {'L-15%','Lnom','L+15%'};

results = struct();
metrics = [];

fig = figure('Visible','off');
idxPlot = 1;
for p = 1:numel(perturb)
    for i = 1:numel(controllers)
        c = controllers{i};
        simout = simulate_case(params, c, 'perturb', perturb(p));
        key = sprintf('%s_%s', c, plabel{p});
        results.(key) = simout;

        m = compare_metrics(simout, params, 'perturb');
        m.L_scale = perturb(p);
        metrics = [metrics; struct2table(m)]; %#ok<AGROW>

        if strcmp(c,'DISMC')
            subplot(3,1,idxPlot);
            plot(simout.t*1e3, simout.vo, 'LineWidth', 1.4); hold on;
            plot(simout.t*1e3, simout.vref, '--', 'LineWidth', 1.0);
            title(sprintf('DISMC under %s', plabel{p}));
            ylabel('v_o [V]'); grid on;
            if idxPlot == 3, xlabel('Time [ms]'); end
            idxPlot = idxPlot + 1;
        end
    end
end
saveas(fig, fullfile(params.path.results, 'fig_param_perturbation.png'));
close(fig);

metrics_tbl = metrics;
end
