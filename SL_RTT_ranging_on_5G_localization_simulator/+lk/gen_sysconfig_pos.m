function [sysPar,carrier,BeamSweep,Layout,RFI,PE,Chan] = gen_sysconfig_pos(UEx);
%gen_sysconfig_pos System paramenters Config. for AOA positioning
%% ====Basic Parameters Config.====%
sysPar.nFrames = 1; %取1时得出5个测距估计
sysPar.center_frequency = 4.9e9;
sysPar.UEstate = 'static';% static or dynamic
sysPar.VelocityUE = 3/3.6;% m/s
sysPar.BSArraySize = [1 4];
sysPar.UEArraySize = [1 1];
sysPar.nBS = 1;
sysPar.nUE = 1;
sysPar.RSPeriod = 4;  % n slot
sysPar.SignalType = 'SRS';       %'SRS', 'CSIRS'
sysPar.BeamSweep = 0;
sysPar.SNR = 20; % in dB 
sysPar.bandwidth = 2e7;
%% ====System layout Config.========%
sysPar.h_BS = 1.5;
sysPar.h_UE = 1.5;

sysPar.BSorientation = 0;
sysPar.UEorientation = pi;

sysPar.BSPos = [ 0 ;  0 ; sysPar.h_BS * ones(1, sysPar.nBS) ];
sysPar.UEPos = [ UEx ; 0 ; sysPar.h_UE];

% sysPar.Scenario = '3GPP_38.901_Indoor_LOS';
sysPar.Scenario = {'umi'};
% '3GPP_38.901_InF_DH''LOSonly','3GPP_38.901_Indoor_LOS'
sysPar.powerUE = 23; % dBm 200 mW   
sysPar.powerBS = 24; % dBm 250 mW
sysPar = cf.ParaTransConfig(sysPar);  %把仿真器的参数配置和5GNR的信号系统一致对应
%% ====Carrier Config.==============%
carrier = nr.CarrierConfig;
carrier.NSizeGrid = 104;   %
%% ====RS Config.===================%
sysPar = cf.SigResConfig(sysPar, carrier);
%% ====Beam Sweeping Config.========%
BeamSweep = BeamSweepConfig(sysPar,carrier);
%% ====Channel Simulator Config.====%
[Layout, Chan] = cf.ChanSimuConfig(sysPar, carrier);   %
%% ======Hardware Imparement========%
RFI = RFImpairConfig(sysPar, carrier);
% FRI.Ind_AntPhaseOffset =1;
% FRI.Ind_IQImbalance = 1;
% FRI.Ind_TimingOffset = 1;
% FRI.Ind_ApproxiCIR = true;
RFI.Ind_SNR = 0; % 0 for base noise; 1 sig power by path loss; 2 measured; 3 no noise
%% === Estimation Config.===========%
PE = ParaEstimation;  %PE是ParaEstimation类的一个对象
PE.SCS = carrier.SubcarrierSpacing;
PE.AngEstiMethodSel = 'music1';
PE.RngEstiMethodSel = 'toa_music';
end

