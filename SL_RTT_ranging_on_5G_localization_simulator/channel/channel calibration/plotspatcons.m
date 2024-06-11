clear all;
close all;
clc;
% Configuration 1
load('.\data\data1spcons.mat');
load('.\data\SpatCons_calibration.mat');

var = {'cf1_cl','cf1_wsinr','cf1_xcorr_delay','cf1_xcorr_aoa','cf1_xcorr_LOS',...
    'cf1_xcorr_channelresponse'};
simvar = {'sim_cf1_cl','sim_cf1_wsinr','corr_delay','corr_AOA','corr_LOS','corr_Chanres'};
xvar = {'Coupling Loss','Wideband SINR','Distance','Distance','Distance','Distance'};
yvar = {'CDF','CDF','xcorr-delay','xcorr-aoa','xcorr-LOS','xcorr-channelresponse'};
grid_min = [-180 -15];
grid_max = [-40 30];
figure; set(gcf,'position',[300,100,1200,900],'color','w');
for iF = 1 : 2
subplot(3,2,iF);
plotecdf(eval(var{iF}),grid_min(iF),grid_max(iF),100,xvar{iF},'dB');hold on;
plotecdf(eval(simvar{iF}),grid_min(iF),grid_max(iF),100,xvar{iF},'dB');hold on;
end
for iF = 3 : 6
subplot(3,2,iF);
plot(1:131,eval(var{iF})/100);grid on; xlabel(xvar{iF});ylabel(yvar{iF});hold on;
% plot(1:10:91,eval(simvar{iF}));grid on; xlabel(xvar{iF});ylabel(yvar{iF});
plot(1:101,eval(simvar{iF}));grid on; xlabel(xvar{iF});ylabel(yvar{iF});
hl = legend('3GPP ref. mean','Simulator','Location','Best');
end
% Configuration 2
load('.\data\data2spcons.mat');
load('.\data\SpatCons_calibration.mat');

var = {'cf2_cl','cf2_wsir','cf2_delay_vr','cf2_pow_vr','cf2_aoa_vr'};
simvar = {'CL2','WSINR2','stddelay','stdPow','stdAOA'};
xvar = {'Coupling Loss','Wideband SINR','avg varying rate -- delay',...
    'avg varying rate -- power','avg varying rate -- AOA'};
yvar = {'CDF','CDF','CDF','CDF','CDF'};
grid_min = [-180 -15 0 0 0];
% grid_max = [-40 30 10000 1.8 1000];
grid_max = [-40 30 10 0.01 10];
unit = {'dB','dB',[],[],[]};
figure; set(gcf,'position',[300,100,1200,900],'color','w');
for iF = 1 : 5
subplot(3,2,iF);
plotecdf(eval(var{iF}),grid_min(iF),grid_max(iF),100,xvar{iF},unit{iF});hold on;
plotecdf(eval(simvar{iF}),grid_min(iF),grid_max(iF),100,xvar{iF},unit{iF});hold on;
hl = legend('3GPP ref. mean','Simulator','Location','Best');
end



