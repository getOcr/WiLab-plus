function [sysPar,carrier,BeamSweep,Layout,RFI,PE,Chan] = gen_sysconfig_orient(~);
%gen_sysconfig_orient System paramenters Config. for beamforming based AOA estimation.
%% ====Basic Parameters Config.====%
sysPar.nFrames = 0.1;
sysPar.center_frequency = 26e9;
sysPar.UEstate = 'dynamic';% static or dynamic
sysPar.VelocityUE = 3/3.6;% m/s
sysPar.BSArraySize = [8 8];
sysPar.UEArraySize = [1 1];
sysPar.nBS = 1;
sysPar.nUE = 1;
sysPar.RSPeriod = 1;  % must be 1 for SSB beam sweeping %nslot
sysPar.SignalType = 'SRS';         %'SSB', 'SRS', 'CSIRS', 'PRS'
sysPar.BeamSweep = 1;
sysPar.IndrxBeam = 1;
sysPar.nBeams = 6; % number of sweeping beams
sysPar.SNR = 20; % in dB
sysPar.bandwidth = 1e8;
%% ====System layout Config.========%
sysPar.h_BS = 3;
sysPar.h_UE = 3;
sysPar.BSorientation = pi * ones(1, sysPar.nBS);
sysPar.BSPos = [ zeros(1, sysPar.nBS) ; (0 : sysPar.nBS-1) * 20 ;...
    sysPar.h_BS * ones(1, sysPar.nBS) ];
sysPar.UEPos = [ -15 ; 15; sysPar.h_UE] * ones(1,sysPar.nUE);
sysPar.UEorientation = 0 * ones(1, sysPar.nUE);% not considered.
sysPar.Scenario = {'indoor'};
% '3GPP_38.901_InF_DH''LOSonly','3GPP_38.901_Indoor_LOS'
sysPar.powerUE = 23; % dBm 200 mW
sysPar.powerBS = 24; % dBm 250 mW
sysPar = cf.ParaTransConfig(sysPar);
%% ====Carrier Config.==============%
carrier = nr.CarrierConfig;
carrier.NSizeGrid = 272;
carrier.SubcarrierSpacing = 60;
%% ====RS Config.===================%
sysPar = cf.SigResConfig(sysPar, carrier);
%% ====Beam Sweeping Config.========%
BeamSweep = BeamSweepConfig(sysPar,carrier);
BeamSweep.IndBmSweep = sysPar.BeamSweep;
BeamSweep.nTxBeam = sysPar.nBeams;
BeamSweep.nRxBeam = sysPar.nBeams;
if strcmpi(sysPar.SignalType, 'SSB' )
    BeamSweep.nTxBeam = sysPar.SigRes(1).Lmax_bar;
    BeamSweep.nRxBeam = sysPar.SigRes(1).Lmax_bar;
end
BeamSweep.IndrxBmSweep = sysPar.IndrxBeam;
BeamSweep.IndOrientFind = 1;
BeamSweep.SpatFreqoffset = pi/8;  %pi/N, three N/2; two beam N
%% ====Channel Simulator Config.====%
[Layout,Chan] = cf.ChanSimuConfig(sysPar, carrier);
%% ======Hardware Imparement========%
RFI = RFImpairConfig(sysPar, carrier);
RFI.Ind_SNR = 1; % 0 for base noise; 1 sig power by path loss; 2 measured;3 no noise
%% === Estimation Config.===========%
PE = ParaEstimation;
end

