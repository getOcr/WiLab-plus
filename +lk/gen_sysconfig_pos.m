function [sysPar,carrier,BeamSweep,Layout,RFI,PE,Chan] = gen_sysconfig_pos(sorted_nearest_positions);
%gen_sysconfig_pos System paramenters Config. for AOA positioning
%% ====Basic Parameters Config.====%
sysPar.nFrames = 0.1;
sysPar.center_frequency = 5.9e9;
sysPar.UEstate = 'static';% static or dynamic
sysPar.VelocityUE = 3/3.6;% m/s
sysPar.BSArraySize = [1 4];
sysPar.UEArraySize = [1 1];
sysPar.nBS = 2;
sysPar.nUE = 1;
sysPar.RSPeriod = 4;  % n slot
sysPar.SignalType = 'SRS';       %'SRS', 'CSIRS'
sysPar.BeamSweep = 0;
sysPar.SNR = 20; % in dB 
sysPar.bandwidth = 2e7;
%% ====System layout Config.========%
All_positions=sorted_nearest_positions';

sysPar.h_BS = 3;
sysPar.h_UE = 1.5;
sysPar.BSorientation = pi * ones(1, sysPar.nBS);

sysPar.BSPos = [All_positions(1, 1), All_positions(1, 3); All_positions(2, 1), All_positions(2, 3);sysPar.h_BS,sysPar.h_BS];
sysPar.UEPos = [All_positions(1, 2); All_positions(2, 2);sysPar.h_UE];
sysPar.UEorientation = 0  * rand(1, sysPar.nUE); 



sysPar.BSorientation = [1*pi,1*pi];
sysPar.UEorientation = pi * ones(1, sysPar.nUE); 
sysPar.BSPos = [4,4;500,400;3,3];
sysPar.UEPos=[-40;450;1.5];
sysPar.UEorientation = pi * ones(1, sysPar.nUE); 

% sysPar.BSPos = [ zeros(1, sysPar.nBS) ; (0 : sysPar.nBS-1) * 20 ;...
%     sysPar.h_BS * ones(1, sysPar.nBS) ];
% sysPar.UEPos = [ (-30 * rand(1,sysPar.nUE) -10); (50 * rand(1,sysPar.nUE) );...
%     sysPar.h_UE * ones(1,sysPar.nUE)];
% sysPar.UEPos(:,1) = [ -20 ; 10; sysPar.h_UE];



% sysPar.Scenario = '3GPP_38.901_Indoor_LOS';
sysPar.Scenario = {'umi'};
% '3GPP_38.901_InF_DH''LOSonly','3GPP_38.901_Indoor_LOS'
sysPar.powerUE = 23; % dBm 200 mW   
sysPar.powerBS = 23; % dBm 250 mW
sysPar = cf.ParaTransConfig(sysPar);
%% ====Carrier Config.==============%
carrier = nr.CarrierConfig;
carrier.NSizeGrid = 100;
%% ====RS Config.===================%
sysPar = cf.SigResConfig(sysPar, carrier);
%% ====Beam Sweeping Config.========%
BeamSweep = BeamSweepConfig(sysPar,carrier);
%% ====Channel Simulator Config.====%
[Layout, Chan] = cf.ChanSimuConfig(sysPar, carrier);
%% ======Hardware Imparement========%
RFI = RFImpairConfig(sysPar, carrier);
% FRI.Ind_AntPhaseOffset =1;
% FRI.Ind_IQImbalance = 1; 
% FRI.Ind_TimingOffset = 1;
% FRI.Ind_ApproxiCIR = true;
RFI.Ind_SNR = 0; % 0 for base noise; 1 sig power by path loss; 2 measured; 3 no noise
%% === Estimation Config.===========%
PE = ParaEstimation;
PE.SCS = carrier.SubcarrierSpacing;
% SRS = nr.SRSConfig;
% SRS.m_srs_b = carrier.NSizeGrid;
PE.AngEstiMethodSel = 'music1';
PE.RngEstiMethodSel = 'toa_music';
end

