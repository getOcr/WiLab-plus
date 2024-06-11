%--------------------------------------------------------------------------
% 5G localization link level simulator 
% 2-D RTT ranging case
% First from target UE 2 reference UE, then from reference UE 2 target UE
%--------------------------------------------------------------------------
close all;
clear all;
clc;
%rng('default');
%data.LocErrall = [];
RangingE = [];
allE = [];
eTemp = [];

for UEx = 10:10:30
    for i = 1:20
        %% target UE-->reference UE
        [sysPar, carrier, BeamSweep, Layout, RFI, PE, Chan] = lk.gen_sysconfig_pos(UEx); % generate wireless channel information

        [data.CIR_cell, data.hcoef, data.Hinfo] = lk.gen_channelcoeff(sysPar, ...
            carrier, Layout, Chan, RFI);    %Hinfo里是大小尺度参数
        % generate RS symbols
        [data.rsSymbols, data.rsIndices, data.txGrid] = lk.gen_rssymbol(sysPar, ...
            carrier,BeamSweep.IndBmSweep);
        % OFDM modulation
        [data.txWaveform] = lk.gen_transmitsignal(sysPar, carrier,data, RFI, BeamSweep);
        % Channel filtering
        [data.rxWaveform] = lk.gen_receivesignal(sysPar, carrier, data, RFI, BeamSweep);
        % OFDM demodulation
        [data.rxGrid] = lk.gen_demodulatedgrid(sysPar, carrier, data.rxWaveform);
        % Channel estimation % works for SRS or CSIRS
        [data.hcfr_esti,data.totGridSize,data.H,data.hEst_temp] = lk.gen_estimated_cfr(sysPar, carrier, data);
        % angle estimation
        %[data.Angle_esti,theta] = lk.gen_estimated_angle(sysPar, data.hcfr_esti,PE);   %SRS对应的IndUplink是1

        % TOA esti 1st
        [data.Range_esti] = lk.gen_estimatedTOA(sysPar,data.hcfr_esti,PE);
        data.Range_error = abs(mean(data.Range_esti - sysPar.UEPos(1,1)));

        % LS localization
        %[data.EstiLoc, data.LocErr, data.BS_sel,data.power_rs,data.index,data.pos_BS,data.nn] = lk.gen_UElocation(sysPar, data,PE);
        %data.LocErrall = cat(2, data.LocErrall, data.LocErr); %构造出的矩阵维数是二维

        % plot function
        pf.plotSysLayout(sysPar,Layout, data);  % display Layout
        % pf.plotCIRMeas(sysPar, data);
        % pf.plotCDF(sysPar, data);% display CDF
        % pf.plotPDP(sysPar, data);% display power-delay profile
        % pf.plotCIR(sysPar, data); % display perfect CIR
        % pf.plotPhaseDiff(sysPar, data); % display Phase difference
        % pf.plotChEstiCFR(sysPar, data); % display estimated CFR
        % pf.plotResources(sysPar, data); % display RS resources grid
        %% reference UE-->target UE
        [sysPar2, BeamSweep2, Layout2, Chan2, RFI2] = lk.gen_backwardconfig(sysPar,carrier);

        %same as the procedure of 1st transmission
        [data2.CIR_cell, data2.hcoef, data2.Hinfo] = lk.gen_channelcoeff(sysPar2, carrier, Layout2, Chan2, RFI2);
        [data2.rsSymbols, data2.rsIndices, data2.txGrid] = lk.gen_rssymbol(sysPar2, carrier,BeamSweep2.IndBmSweep);
        [data2.txWaveform] = lk.gen_transmitsignal(sysPar2, carrier, data2, RFI2, BeamSweep2);
        [data2.rxWaveform] = lk.gen_receivesignal(sysPar2, carrier, data2, RFI2, BeamSweep2);
        [data2.rxGrid] = lk.gen_demodulatedgrid(sysPar2, carrier, data2.rxWaveform);
        [data2.hcfr_esti,data2.totGridSize,data2.H,data2.hEst_temp] = lk.gen_estimated_cfr(sysPar2, carrier, data2);

        % TOA esti 2nd
        [data2.Range_esti] = lk.gen_estimatedTOA(sysPar,data2.hcfr_esti,PE);
        data2.Range_error = abs(mean(data2.Range_esti - sysPar.UEPos(1,1)));
        %% RTT error calculation
        RTTRanging_error = mean([data.Range_error data2.Range_error]);
        eTemp = [eTemp RTTRanging_error];
    end
    meanE = mean(eTemp);
    allE = [allE meanE];
end