function [sysPar, BeamSweep, Layout, Chan, RFI] = gen_backwardconfig(sysPar,carrier)
% this function is used to manage the backward transmission configuration
%when using RTT.
% In this simulation,RTT is treated as round trip TOA estimation. And the
%Round Trip Time is equal to the mean of two TOA.
% Developer: Jinzhengyu. Institution: SHU. Date: 2024/06/01

if sysPar.IndUplink
    sysPar.TxArraySize = sysPar.BSArraySize;   
    sysPar.RxArraySize = sysPar.UEArraySize;
    sysPar.nTx = prod( sysPar.TxArraySize );
    sysPar.nRx = prod( sysPar.RxArraySize );   %如果BS是4*4的话，跑music1会报错，1*4就不会
    sysPar.nTr = sysPar.nBS;
    sysPar.nRr = sysPar.nUE;
    sysPar.IndUplink = false;
    sysPar.powerTr = sysPar.powerUE;
else
    sysPar.TxArraySize = sysPar.UEArraySize;
    sysPar.RxArraySize = sysPar.BSArraySize;
    sysPar.nTx = prod( sysPar.TxArraySize );
    sysPar.nRx = prod( sysPar.RxArraySize );
    sysPar.nTr = sysPar.nUE;
    sysPar.nRr = sysPar.nBS;
    sysPar.IndUplink = true;
    sysPar.powerTr = sysPar.powerBS;
end

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
end