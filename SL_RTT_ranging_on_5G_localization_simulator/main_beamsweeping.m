%--------------------------------------------------------------------------
% 5G localization link level simulator for beam management
%--------------------------------------------------------------------------
close all;
clear all;
clc;
rng('default');
[sysPar, carrier, BeamSweep, Layout, RFI, PE, Chan] = lk.gen_sysconfig_beam;
BeamSweep.TxAzimBmRange = [-30,30];
BeamSweep.TxElevBmRange = [85 99];
BeamSweep.RxAzimBmRange = [-30,30];
BeamSweep.RxElevBmRange = [85 99];
get_SweepBeamsPara(BeamSweep);
[data.CIR_cell, data.hcoef, data.Hinfo] = lk.gen_channelcoeff(sysPar, ...
    carrier, Layout, Chan, RFI);
% generate RS symbols
[data.rsSymbols, data.rsIndices, data.txGrid] = lk.gen_rssymbol(sysPar, ...
    carrier,BeamSweep.IndBmSweep);
% OFDM modulation
[data.txWaveform] = lk.gen_transmitsignal(sysPar, carrier,data, RFI, BeamSweep);
% Channel filtering
[data.rxWaveform] = lk.gen_receivesignal(sysPar, carrier, data, RFI, BeamSweep);
% OFDM demodulation
[data.rxGrid] = lk.gen_demodulatedgrid(sysPar, carrier, data.rxWaveform);
[data.rsrp,data.rsrp_dbm] = lk.gen_rsrp(sysPar, carrier, data, BeamSweep);
[data.SelTxBeamAng,data.SelRxBeamAng] = lk.gen_SelBeamAng(BeamSweep, data.rsrp);
%-------------------------
% display functions
%-------------------------
pf.plotRSRP(sysPar,data);
pf.plotSelBeamAng(sysPar,data);
pf.plotSysLayout(sysPar,Layout,data);  % display Layout
pf.plotPDP(sysPar,data);% display power-delay profile
pf.plotCIR(sysPar,data); % display perfect CIR
pf.plotResources(sysPar,data); % display RS resources grid
