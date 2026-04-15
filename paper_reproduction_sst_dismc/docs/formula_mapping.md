# 论文公式与代码映射

> 注：由于当前仓库未提供论文 PDF 原文行号，本文件按“变量/结构”级别进行映射，并在代码注释中标注“论文式( )/图( )/表( )”占位。

## 1) 误差定义
- 论文：`e = v_ref - v_o`
- 代码：
  - `scripts/simulate_case.m` 内每步 `e = vout_ref_eff - vo(k)`

## 2) DISMC 滑模面
- 论文：`s = e + k1∫e dt + k2∫∫e dt²`
- 代码：
  - `controllers/dismc_controller.m`

## 3) SISMC 滑模面
- 论文：`s = e + k1∫e dt`
- 代码：
  - `controllers/sismc_controller.m`

## 4) 抖振抑制
- 论文：`sign(s)` -> `tanh(s/μ)`
- 代码：
  - `controllers/controller_utils.m` (`tanh_sign`)
  - SISMC / DISMC 控制律中调用

## 5) 相移映射
- 论文：`δ* = arcsin(u_eq)`, `D3* = δ*/π`, 且在 SPS 下 `D3=D12`
- 代码：
  - `controllers/dismc_controller.m` 输出 `delta_star`, `D3_star`
  - `scripts/simulate_case.m` 中 `D12 = D3`

## 6) SPS 特例
- 论文：`D1=1, D2=1, 0<D12<=1, D3=D12`
- 代码：
  - `init_params.m` 固定 `D1/D2`
  - `simulate_case.m` 每步使用 `D12=D3`

## 7) 前级 TPBR dq 双闭环结构
- 论文：Park 变换 + 电压电流双闭环 + 前馈解耦 + SVPWM
- 代码：
  - `build_simulink_model.m` 生成 `tpbr_dq_control.slx` 结构骨架
