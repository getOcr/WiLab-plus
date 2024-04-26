%--------------------------------------------------------------------------
% 5G localization link level simulator for 2-D positioning
%--------------------------------------------------------------------------
% close all;
% clear all;
% clc;
% rng('default');
data.LocErrall = [];
%调用函数lk.gen_sysconfig_pos生成系统参数(sysPar)、载波参数(carrier)、波束扫描参数(BeamSweep)、布局参数(Layout)
%射频干扰参数(RFI)、位置误差参数(PE)和信道参数(Chan)，并将其赋值给相应的变量
[sysPar, carrier, BeamSweep, Layout, RFI, PE, Chan] = lk.gen_sysconfig_pos;
% generate wireless channel information
%调用函数lk.gen_channelcoeff生成无线信道信息，包括信道冲激响应(CIR_cell)、小区中的信道系数(hcoef)
%信道信息(Hinfo)，并将其赋值给相应的变量
[data.CIR_cell, data.hcoef, data.Hinfo] = lk.gen_channelcoeff(sysPar, ...
    carrier, Layout, Chan, RFI);
 
% generate RS symbols
%调用函数lk.gen_rssymbol生成参考信号(RS)符号、RS符号的索引(rsIndices)和传输网格(txGrid)
[data.rsSymbols, data.rsIndices, data.txGrid] = lk.gen_rssymbol(sysPar, ...
    carrier,BeamSweep.IndBmSweep);
      
% OFDM modulation调用函数lk.gen_transmitsignal进行OFDM调制，生成传输信号(txWaveform)
[data.txWaveform] = lk.gen_transmitsignal(sysPar, carrier,data, RFI, BeamSweep);
% Channel filtering调用函数lk.gen_receivesignal对传输信号进行信道滤波，生成接收信号(rxWaveform)
[data.rxWaveform] = lk.gen_receivesignal(sysPar, carrier, data, RFI, BeamSweep);
% OFDM demodulation调用函数lk.gen_demodulatedgrid进行OFDM解调，生成解调网格(rxGrid)
[data.rxGrid] = lk.gen_demodulatedgrid(sysPar, carrier, data.rxWaveform);

% Channel estimation % works for SRS or CSIRS
%调用函数lk.gen_estimated_cfr进行信道估计，生成通道频率响应(hcfr_esti)
[data.hcfr_esti] = lk.gen_estimated_cfr(sysPar, carrier, data);

% %     angle estimation
%调用函数lk.gen_estimated_angle进行AOA角度估计，生成角度估计结果(Angle_esti)
%调用函数lk.gen_estimatedTOA进行到达时间(TOA)估计，生成距离估计结果(Range_esti)
[data.Angle_esti] = lk.gen_estimated_angle(sysPar, data.hcfr_esti,PE);
[data.Range_esti] = lk.gen_estimatedTOA(sysPar,data.hcfr_esti,PE);

%     % LS localization
%调用函数lk.gen_UElocation进行最小二乘定位，生成估计位置(EstiLoc)、定位误差(LocErr)和基站选择结果(BS_sel)
[data.EstiLoc, data.LocErr, data.BS_sel] = lk.gen_UElocation(sysPar, data,PE);

%将定位误差(LocErr)加入到数据结构数组data.LocErrall中
data.LocErrall = cat(2, data.LocErrall, data.LocErr);
disp(data.LocErrall)
%调用函数pf.plotSysLayout绘制系统布局图。
pf.plotSysLayout(sysPar,Layout, data);  % display Layout

% 调用函数pf.plotCIRMeas绘制信道冲激响应测量图。
pf.plotCIRMeas(sysPar, data);

% 调用函数pf.plotCDF绘制累积分布函数(CDF)图。
pf.plotCDF(sysPar, data);% display CDF

% 调用函数pf.plotPDP绘制功率-时延特性图。
pf.plotPDP(sysPar, data);% display power-delay profile

% 调用函数pf.plotCIR绘制完美信道冲激响应图。
pf.plotCIR(sysPar, data); % display perfect CIR

% 调用函数pf.plotPhaseDiff绘制相位差图。
pf.plotPhaseDiff(sysPar, data); % display Phase difference

% 调用函数pf.plotChEstiCFR绘制估计的通道频率响应图。
pf.plotChEstiCFR(sysPar, data); % display estimated CFR

% 调用函数pf.plotResources绘制参考信号资源网格图
pf.plotResources(sysPar, data); % display RS resources grid
%%
