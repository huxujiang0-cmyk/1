# 基于双积分滑模控制的固态变压器电压控制策略 —— MATLAB/Simulink 复现工程

## 1. 工程目标
本工程复现 SST 两级控制策略趋势：
1. 前级 TPBR：dq 电压电流双闭环（结构骨架）；
2. 后级 IBDC(SPS)：PI / SISMC / DISMC 对比；
3. 复现实验趋势：DISMC 在动态响应、超调、鲁棒性方面优于 PI 与 SISMC。

## 2. MATLAB 版本要求
- 推荐 MATLAB R2022b 及以上（R2020b+ 通常也可运行）
- 若运行 `build_simulink_model.m`，需要 Simulink

## 3. 快速运行
```matlab
cd paper_reproduction_sst_dismc
run_all_tests
```
运行后在 `results/` 目录生成：
- 启动对比图（PI/SISMC/DISMC）
- 负载突变对比图
- 参数摄动图
- 综合扰动图
- `metrics_summary.csv`

## 4. 论文与代码对应关系
- 参数表：`init_params.m`
- PI/SISMC/DISMC：`controllers/*.m`
- SPS 模型与统一相移变量映射：`scripts/simulate_case.m`
- 前级 TPBR 控制框架：`build_simulink_model.m`
- 指标统计：`compare_metrics.m`
- 详细映射：`docs/formula_mapping.md`

## 5. 关键假设（论文未给参数补齐）
详见 `docs/assumptions_and_tuning.md`，包括：
- 控制器增益
- 开关频率与仿真步长
- 软启动时间
- 平均模型化假设

## 6. 调参方法
1. 先调 PI，保证稳定；
2. 调 SISMC 的 `k1,k3,mu`，平衡速度与抖振；
3. 调 DISMC 的 `k1,k2,k3,mu`，优先确保负载突变和参数摄动下恢复速度；
4. 观察 `metrics_summary.csv` 中超调/恢复时间/RMS 误差。

## 7. 当前复现程度
- ✅ 已实现可运行工程，一键跑 4 个工况并导出指标与图。
- ✅ 已体现 DISMC 在大多数工况下的优势趋势。
- ⚠️ 前级 TPBR 目前为“可视化结构骨架 + 平均动态”，非全开关详细电路。
- ⚠️ 若需进一步逼近论文波形细节，建议在 `models/` 中替换为开关模型与精确参数。
