function [Angle_esti,Range_esti,EstiLoc,LocErr,LocErrall,Error_RangeEst] = mainV2XSidelinkPosition(ResourseAllocation_RB,positionManagement,sysPar, carrier, BeamSweep, RFI, PE)
% V2X Sidelink Position车辆定位模块
%
% Description:
% Use 5G localization link level simulator for 2-D positioning for V2X sidelink positioning
% Two cars are selected to estimate the position and Angle of the other car
% Developer: Zhong. Institution: SHU. Date: 2024/4/22

%位置读取
% 合并 x 和 y 坐标矩阵成一个位置矩阵
positionsVehicles = [positionManagement.XvehicleReal, positionManagement.YvehicleReal];
% 
% 
% TargetUE = [950, 10]; % 给定点的坐标
% distances_to_TargetUE = sqrt((positionsVehicles(:, 1) - TargetUE(1)).^2 + (positionsVehicles(:, 2) - TargetUE(2)).^2);
% [sorted_distances1, TargetUE_indices] = sort(distances_to_TargetUE);
% TargetUE_indices = TargetUE_indices(1);
% TargetUE_positions = positionsVehicles(TargetUE_indices, :);
% 
% AnchorUE1 = [1000, 0]; % 给定点的坐标
% distances_to_AnchorUE1 = sqrt((positionsVehicles(:, 1) - AnchorUE1(1)).^2 + (positionsVehicles(:, 2) - AnchorUE1(2)).^2);
% [sorted_distances2, AnchorUE1_indices] = sort(distances_to_AnchorUE1);
% AnchorUE1_indices = AnchorUE1_indices(1);
% AnchorUE1_positions = positionsVehicles(AnchorUE1_indices, :);
% 
% 
% AnchorUE2 = [1000, 20]; % 给定点的坐标
% distances_to_AnchorUE2 = sqrt((positionsVehicles(:, 1) - AnchorUE2(1)).^2 + (positionsVehicles(:, 2) - AnchorUE2(2)).^2);
% [sorted_distances3, AnchorUE2_indices] = sort(distances_to_AnchorUE2);
% if AnchorUE2_indices ~= AnchorUE1_indices
%     AnchorUE2_indices = AnchorUE2_indices(1);
% else
%     AnchorUE2_indices = AnchorUE2_indices(2);
% end
% AnchorUE2_positions = positionsVehicles(AnchorUE2_indices, :);
%indices_close_to_center = find(distances_to_Centerpoint <= 100);

% % 计算每个位置到 x=500 的距离
distances_to_500 = abs(positionsVehicles(:, 1) - 500);
%找到离 x=500 最近的三个车辆位置用于定位
[sorted_distances, sorted_indices] = sort(distances_to_500);
nearest_indices = sorted_indices(1:3);
nearest_positions = positionsVehicles(nearest_indices, :);
% 对 nearest_positions 进行排序
sorted_nearest_positions = sortrows(nearest_positions,2);

% 假设 sorted_nearest_positions 是你的 3x2 矩阵，每一行代表一个点的x和y坐标
point1 = sorted_nearest_positions(1, :); % 第一个点的坐标
point2 = sorted_nearest_positions(2, :); % 第二个点的坐标
point3 = sorted_nearest_positions(3, :); % 第三个点的坐标

% 计算第一个点到第二个点的距离
distance_1_to_2 = sqrt((point1(1) - point2(1))^2 + (point1(2) - point2(2))^2);

% 计算第三个点到第二个点的距禞
distance_3_to_2 = sqrt((point3(1) - point2(1))^2 + (point3(2) - point2(2))^2);

%% ====System layout Config.========%
All_positions=sorted_nearest_positions';

sysPar.h_BS = 3;
sysPar.h_UE = 1.5;
sysPar.BSorientation = pi * ones(1, sysPar.nBS);
sysPar.BSPos = [All_positions(1, 1), All_positions(1, 3); All_positions(2, 1), All_positions(2, 3);sysPar.h_BS,sysPar.h_BS];
sysPar.UEPos = [All_positions(1, 2); All_positions(2, 2);sysPar.h_UE];
sysPar.UEorientation = 0  * rand(1, sysPar.nUE); 

%sysPar.BSPos = [4,4;500,400;3,3];
%sysPar.UEPos=[-40;450;1.5];

sysPar.BSPos = [0,0;0,25;3,3];
sysPar.UEPos=[-12.5*sqrt(3);12.5;1.5];



%求各锚点和UE之间的实际距离
sysPar.BSPos_2D = sysPar.BSPos(1:end-1,:);
sysPar.UEPos_2D = sysPar.UEPos(1:end-1,:);
Posdiff = sysPar.BSPos_2D - sysPar.UEPos_2D;
sysPar.range_real = abs(sqrt(Posdiff(1,:).^2-Posdiff(2,:).^2));

%sysPar.BSorientation = [pi+atan(abs(Posdiff(2,1)/Posdiff(1,1))),pi-atan(abs(Posdiff(2,2)/Posdiff(1,2)))];
%sysPar.UEorientation = 0 * rand(1, sysPar.nUE); 
%% ====Channel Simulator Config.====%
[Layout, Chan] = cf.ChanSimuConfig(sysPar, carrier);

%% 定位模块调用
data.LocErrall = [];
% %调用函数lk.gen_sysconfig_pos生成系统参数(sysPar)、载波参数(carrier)、波束扫描参数(BeamSweep)、布局参数(Layout)
% %射频干扰参数(RFI)、位置误差参数(PE)和信道参数(Chan)，并将其赋值给相应的变量
% [sysPar, carrier, BeamSweep, Layout, RFI, PE, Chan] = lk.gen_sysconfig_pos(sorted_nearest_positions);
% generate wireless channel information
%调用函数lk.gen_channelcoeff生成无线信道信息，包括信道冲激响应(CIR_cell)、小区中的信道系数(hcoef)
%信道信息(Hinfo)，并将其赋值给相应的变量
[data.CIR_cell, data.hcoef, data.Hinfo] = lk.gen_channelcoeff(sysPar, ...
    carrier, Layout, Chan, RFI);
% generate RS symbols
% 先随机生成一个包含随机0和1的100x1资源分配矩阵
%ResourseAllocation_RB = randi([0, 1], 100, 1);
% 将矩阵扩展为nRBx12行，14列。首先将矩阵重塑为nRBx12行，然后再调整为nRBx14
ResourseAllocation_CarrierSymbol =  repelem(ResourseAllocation_RB, 12);
% 将矩阵的每一列复制成14列
ResourseAllocation_CarrierSymbol = repmat(ResourseAllocation_CarrierSymbol, 1, 14);

%调用函数lk.gen_rssymbol生成参考信号(RS)符号、RS符号的索引(rsIndices)和传输网格(txGrid)
[data.rsSymbols, data.rsIndices, data.txGrid] = lk.gen_rssymbol(sysPar, ...
    carrier,BeamSweep.IndBmSweep);
data.txGrid = ResourseAllocation_CarrierSymbol .* data.txGrid;
% OFDM modulation调用函数lk.gen_transmitsignal进行OFDM调制，生成传输信号(txWaveform)
[data.txWaveform] = lk.gen_transmitsignal(sysPar, carrier,data, RFI, BeamSweep);
% Channel filtering调用函数lk.gen_receivesignal对传输信号进行信道滤波，生成接收信号(rxWaveform)
[data.rxWaveform] = lk.gen_receivesignal(sysPar, carrier, data, RFI, BeamSweep);
% OFDM demodulation调用函数lk.gen_demodulatedgrid进行OFDM解调，生成解调网格(rxGrid)
[data.rxGrid] = lk.gen_demodulatedgrid(sysPar, carrier, data.rxWaveform);

% Channel estimation % works for SRS or CSIRS
%调用函数lk.gen_estimated_cfr进行信道估计，生成通道频率响应(hcfr_esti)
[data.hcfr_esti] = lk.gen_estimated_cfr(sysPar, carrier, data);

% angle estimation
%调用函数lk.gen_estimated_angle进行AOA角度估计，生成角度估计结果(Angle_esti)
[data.Angle_esti] = lk.gen_estimated_angle(sysPar, data.hcfr_esti,PE);

%调用函数lk.gen_estimatedTOA进行到达时间(TOA)估计，生成距离估计结果(Range_esti)
[data.Range_esti] = 0.3 * lk.gen_estimatedTOA(sysPar,data.hcfr_esti,PE);

%% LS localization
%调用函数lk.gen_UElocation进行最小二乘定位，生成估计位置(EstiLoc)、定位误差(LocErr)和基站选择结果(BS_sel)
[data.EstiLoc, data.LocErr, data.BS_sel] = lk.gen_UElocation(sysPar, data,PE);

%将定位误差(LocErr)加入到数据结构数组data.LocErrall中
data.LocErrall = cat(2, data.LocErrall, data.LocErr);
% disp(distance_1_to_2)
% disp(distance_3_to_2)
fprintf('\nLocErrall:%0.3f\n',data.LocErrall);

Angle_esti=data.Angle_esti;
Range_esti=data.Range_esti;
Error_RangeEst = abs(Range_esti - sysPar.range_real);
EstiLoc=data.EstiLoc;
LocErr=data.LocErr;
LocErrall=data.LocErrall;

% 关闭之前的图像窗口
close all;
%% 调用函数pf.plotSysLayout绘制系统布局图。
pf.plotSysLayout(sysPar,Layout, data);  % display Layout
% % 调用函数pf.plotCIRMeas绘制信道冲激响应测量图。
%pf.plotCIRMeas(sysPar, data);
% % 
% % 调用函数pf.plotCDF绘制累积分布函数(CDF)图。
%pf.plotCDF(sysPar, data);% display CDF
% 
% % 调用函数pf.plotPDP绘制功率-时延特性图。
%pf.plotPDP(sysPar, data);% display power-delay profile
% 
% % 调用函数pf.plotCIR绘制完美信道冲激响应图。
%pf.plotCIR(sysPar, data); % display perfect CIR
% 
% % 调用函数pf.plotPhaseDiff绘制相位差图。
%pf.plotPhaseDiff(sysPar, data); % display Phase difference
% 
% % 调用函数pf.plotChEstiCFR绘制估计的通道频率响应图。
%pf.plotChEstiCFR(sysPar, data); % display estimated CFR
% 
% % 调用函数pf.plotResources绘制参考信号资源网格图
% pf.plotResources(sysPar, data); % display RS resources grid
