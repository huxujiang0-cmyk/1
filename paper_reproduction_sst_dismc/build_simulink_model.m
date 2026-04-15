function build_simulink_model()
%BUILD_SIMULINK_MODEL Auto-generate basic Simulink models for structure mapping.
% 注：为保证跨版本可运行，详细控制算法在 MATLAB 脚本中执行。
% 本脚本主要建立论文结构对应的可视化骨架：
% - tpbr_dq_control
% - ibdc_sps_stage
% - sst_main_model

root = fileparts(mfilename('fullpath'));
modelsDir = fullfile(root, 'models');
if ~exist(modelsDir,'dir'), mkdir(modelsDir); end

create_tpbr_model(fullfile(modelsDir,'tpbr_dq_control'));
create_ibdc_model(fullfile(modelsDir,'ibdc_sps_stage'));
create_sst_model(fullfile(modelsDir,'sst_main_model'));

fprintf('Simulink structure models generated under: %s\n', modelsDir);
end

function create_tpbr_model(modelPath)
mdl = modelPath;
if bdIsLoaded(mdl), close_system(mdl,0); end
new_system(mdl);
open_system(mdl);

add_block('simulink/Sources/In1',[mdl '/abc_voltage'],'Position',[50 80 80 100]);
add_block('simulink/Math Operations/Gain',[mdl '/Park_Transform'],'Gain','1','Position',[120 70 200 110]);
add_block('simulink/Discrete/Discrete PID Controller',[mdl '/PI_i_dq'],'Position',[240 60 330 120]);
add_block('simulink/Discrete/Discrete PID Controller',[mdl '/PI_v_dc'],'Position',[240 140 330 200]);
add_block('simulink/Math Operations/Sum',[mdl '/Feedforward_Decouple'],'Inputs','++','Position',[370 95 390 125]);
add_block('simulink/Math Operations/Gain',[mdl '/SVPWM'],'Gain','1','Position',[430 90 500 130]);
add_block('simulink/Sinks/Out1',[mdl '/gate_signals'],'Position',[540 100 570 120]);

add_line(mdl,'abc_voltage/1','Park_Transform/1');
add_line(mdl,'Park_Transform/1','PI_i_dq/1');
add_line(mdl,'PI_i_dq/1','Feedforward_Decouple/1');
add_line(mdl,'PI_v_dc/1','Feedforward_Decouple/2');
add_line(mdl,'Feedforward_Decouple/1','SVPWM/1');
add_line(mdl,'SVPWM/1','gate_signals/1');

save_system(mdl,[mdl '.slx']);
close_system(mdl,0);
end

function create_ibdc_model(modelPath)
mdl = modelPath;
if bdIsLoaded(mdl), close_system(mdl,0); end
new_system(mdl);
open_system(mdl);

add_block('simulink/Sources/In1',[mdl '/vdc_in'],'Position',[40 80 70 100]);
add_block('simulink/Sources/In1',[mdl '/vref'],'Position',[40 130 70 150]);
add_block('simulink/Math Operations/Sum',[mdl '/e=vref-vo'],'Inputs','+-','Position',[110 105 130 135]);
add_block('simulink/User-Defined Functions/MATLAB Function',[mdl '/Controller_PI_SISMC_DISMC'],'Position',[170 90 300 150]);
add_block('simulink/Math Operations/Gain',[mdl '/SPS_Power_Stage'],'Gain','1','Position',[330 95 420 145]);
add_block('simulink/Continuous/Integrator',[mdl '/Co_dynamics'],'Position',[450 100 480 130]);
add_block('simulink/Sinks/Out1',[mdl '/vo'],'Position',[520 110 550 130]);

add_line(mdl,'vref/1','e=vref-vo/1');
add_line(mdl,'vo/1','e=vref-vo/2');
add_line(mdl,'e=vref-vo/1','Controller_PI_SISMC_DISMC/1');
add_line(mdl,'Controller_PI_SISMC_DISMC/1','SPS_Power_Stage/1');
add_line(mdl,'SPS_Power_Stage/1','Co_dynamics/1');
add_line(mdl,'Co_dynamics/1','vo/1');

save_system(mdl,[mdl '.slx']);
close_system(mdl,0);
end

function create_sst_model(modelPath)
mdl = modelPath;
if bdIsLoaded(mdl), close_system(mdl,0); end
new_system(mdl);
open_system(mdl);

add_block('simulink/Ports & Subsystems/Subsystem',[mdl '/TPBR_dq_Subsystem'],'Position',[80 90 230 190]);
add_block('simulink/Ports & Subsystems/Subsystem',[mdl '/IBDC_SPS_Subsystem'],'Position',[320 90 470 190]);
add_block('simulink/Sinks/Out1',[mdl '/vdc'],'Position',[520 95 550 115]);
add_block('simulink/Sinks/Out1',[mdl '/vo'],'Position',[520 125 550 145]);
add_block('simulink/Sinks/Out1',[mdl '/io'],'Position',[520 155 550 175]);
add_block('simulink/Sinks/Out1',[mdl '/iL'],'Position',[520 185 550 205]);

add_line(mdl,'TPBR_dq_Subsystem/1','IBDC_SPS_Subsystem/1');
add_line(mdl,'TPBR_dq_Subsystem/1','vdc/1');
add_line(mdl,'IBDC_SPS_Subsystem/1','vo/1');
add_line(mdl,'IBDC_SPS_Subsystem/1','io/1');
add_line(mdl,'IBDC_SPS_Subsystem/1','iL/1');

save_system(mdl,[mdl '.slx']);
close_system(mdl,0);
end
