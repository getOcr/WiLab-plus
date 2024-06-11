%--------------------------------------------------------------------------
% 5G localization link level simulator for beam-based angle estimation
%--------------------------------------------------------------------------
close all;
clear all;
clc;
rng('default');
[sysPar, carrier, BeamSweep, Layout, RFI, PE, Chan] = lk.gen_sysconfig_orient;
BeamSweep.SndDeterAngle = [-45 +12 * ( rand -0.5 ) ; 90 +12 * ( rand -0.5 ) ];
get_SweepBeamsPara(BeamSweep);
[data.CIR_cell, data.hcoef, data.Hinfo] = lk.gen_channelcoeff(sysPar, ...
    carrier, Layout, Chan, RFI);
% generate RS symbols
[data.rsSymbols, data.rsIndices, data.txGrid] = lk.gen_rssymbol(sysPar, ...
    carrier, BeamSweep.IndBmSweep);
% OFDM modulation
[data.txWaveform] = lk.gen_transmitsignal(sysPar, carrier, data, RFI, BeamSweep);
% Channel filtering
[data.rxWaveform] = lk.gen_receivesignal(sysPar, carrier, data, RFI, BeamSweep);
% OFDM demodulation
[data.rxGrid] = lk.gen_demodulatedgrid(sysPar, carrier, data.rxWaveform);
%     RSRP estimation
[data.rsrp,data.rsrp_dbm] = lk.gen_rsrp(sysPar, carrier, data, BeamSweep);
[data.SelTxBeamAng,data.SelRxBeamAng] = lk.gen_beamorientresult(BeamSweep,...
    sysPar, carrier, Layout, data);
pf.plotRSRP(sysPar, data);
pf.plotSelBeamAng(sysPar, data);
pf.plotSysLayout(sysPar,Layout, data);  % display Layout
pf.plotPDP(sysPar, data);% display power-delay profile
pf.plotCIR(sysPar, data); % display perfect CIR
pf.plotResources(sysPar, data); % display RS resources grid
