function run_all_tests()
%RUN_ALL_TESTS One-click runner for all reproduction scenarios.

root = fileparts(mfilename('fullpath'));
addpath(root);
addpath(fullfile(root, 'controllers'));
addpath(fullfile(root, 'scripts'));

params = init_params();

% 可选：自动创建模型结构（需 Simulink）
try
    build_simulink_model();
catch ME
    warning('build_simulink_model skipped: %s', ME.message);
end

all_results = struct();
all_metrics = table();

fprintf('Running Test 1: startup...\n');
[r1, m1] = test_startup(params);
all_results.startup = r1;
all_metrics = [all_metrics; m1]; %#ok<AGROW>

fprintf('Running Test 2: load step...\n');
[r2, m2] = test_load_step(params);
all_results.loadstep = r2;
all_metrics = [all_metrics; m2]; %#ok<AGROW>

fprintf('Running Test 3: parameter perturbation...\n');
[r3, m3] = test_param_perturbation(params);
all_results.perturb = r3;
all_metrics = [all_metrics; m3]; %#ok<AGROW>

fprintf('Running Test 4: composite disturbance...\n');
[r4, m4] = test_composite_disturbance(params);
all_results.composite = r4;
all_metrics = [all_metrics; m4]; %#ok<AGROW>

plot_all_results(all_results, params);
export_figures(params);

% 指标导出
csvPath = fullfile(params.path.results, 'metrics_summary.csv');
writetable(all_metrics, csvPath);

matPath = fullfile(params.path.results, 'all_results.mat');
save(matPath, 'all_results', 'all_metrics', 'params');

fprintf('All tests completed.\nResults: %s\n', params.path.results);
end
