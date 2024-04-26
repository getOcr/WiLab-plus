function [sysPar,carrier,BeamSweep,Layout,RFI,PE,Chan] = gen_sysconfig_beam(~);
%gen_sysconfig_beam System paramenters Config. for beam management.
%% ====Basic Parameters Config.====%
sysPar.nFrames = 0.1;
sysPar.center_frequency = 4.9e9;
sysPar.UEstate = 'dynamic';% static or dynamic
sysPar.VelocityUE = 0.5/3.6;% m/s
sysPar.BSArraySize = [2 2];
sysPar.UEArraySize = [2 2];
sysPar.nBS = 1;
sysPar.nUE = 1;
sysPar.RSPeriod = 1;  % must be 1 for SSB beam sweeping %nslot
sysPar.SignalType = 'CSIRS';         %'SSB', 'SRS', 'CSIRS', 'PRS'
sysPar.BeamSweep = 1;
sysPar.IndrxBeam = 0;
sysPar.nBeams = 12; % number of sweeping beams
sysPar.SNR = 20; % in dB 
sysPar.bandwidth = 1e8;
%% ====System layout Config.========%
sysPar.h_BS = 3;
sysPar.h_UE = 1.5;
sysPar.BSorientation = pi * ones(1, sysPar.nBS);
sysPar.BSPos = [ zeros(1, sysPar.nBS) ; (0 : sysPar.nBS-1) * 20 ;...
    sysPar.h_BS * ones(1, sysPar.nBS) ];
sysPar.UEPos = [ -50 ; 10; sysPar.h_UE] * ones(1,sysPar.nUE);
sysPar.UEorientation = 0 * ones(1, sysPar.nUE);% not considered.
sysPar.Scenario = {'indoor'};
sysPar.powerUE = 23; % dBm 200 mW   
sysPar.powerBS = 24; % dBm 250 mW
sysPar = cf.ParaTransConfig(sysPar);
%% ====Carrier Config.==============%
carrier = nr.CarrierConfig;
carrier.NSizeGrid = 272;
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
BeamSweep.IndSweepOrient = 'azimuth';
%% ====Channel Simulator Config.====%
[Layout, Chan] = cf.ChanSimuConfig(sysPar, carrier);
%% ======Hardware Imparement========%
RFI = RFImpairConfig(sysPar, carrier);
RFI.Ind_SNR = 3; % 0 for base noise; 1 sig power by path loss; 2 measured;3 no noise
%% === Estimation Config.===========%
PE = ParaEstimation;
end

