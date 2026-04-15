function export_figures(params)
%EXPORT_FIGURES Placeholder for extended export logic.
% 当前脚本中各测试已直接保存 PNG 到 results 目录。
if ~exist(params.path.results, 'dir')
    mkdir(params.path.results);
end
fprintf('Figures are exported to: %s\n', params.path.results);
end
