close all;
clear all;
clc;
% config1
addpath('..\');
tic
% rng('default');
M = 4;
N = 4;
P = 2;
Mg = 1;
Ng = 2;
P_ue = 2;
noise_K = 1.38e-23; % J/K
noise_T = 290; % K
UEnoisefig = 9; % dB
ISD = 200;
min_dis = 18;
max_dis = 100;
BSpower = 35; % dBm
BandWidth = 100e6;
ang_etilt = 102;
nBS = 1;
nUEp = 500;
imax = 11;
nUE = nUEp*imax;
nPRB = 50;
Pgroundnoise = 10*log10( noise_K * noise_T * BandWidth );
Pn = 10^( ( Pgroundnoise + UEnoisefig)/10 );
% save('.\data\spconsconfig1_result.mat','nUE','-append');
h_UE = 1.5 * ones(nUE,1);
r_UE1 = sqrt( rand(nUEp, 1 ) ) * ( max_dis - min_dis ) + min_dis;
theta_UE1 = rand( nUEp, 1 ) * 2 * pi;
Dis = (0:imax-1)*10;
theta0 = rand(nUEp,imax) * 2 * pi;
ry = r_UE1 .* sin(theta_UE1) + Dis .* sin( theta0 );
rx = r_UE1 .* cos(theta_UE1) + Dis .* cos( theta0 );
r_UE2 = sqrt( rx.^2 + ry.^2 );
r_UE2( r_UE2 <= min_dis ) = min_dis;
theta_UE2 = atan( ry./rx );
temp = theta_UE2( rx <0 );
theta_UE2(rx < 0 ) = pi + temp;
x_UE = r_UE2 .* cos( theta_UE2 );
x_UE = reshape(x_UE,[],1);
y_UE = r_UE2 .* sin( theta_UE2 );
y_UE = reshape(y_UE,[],1);
UE_pos = [ x_UE, y_UE, h_UE ].';
figure(1);plot(UE_pos(1,:), UE_pos(2,:),'.'); hold on;
%-------------------------------------------
Layout = SysLayoutConfig;
Layout.BS_position = [0; 0; 10];
Layout.BSorientation = [ pi/6; 0; 0];
Layout.UE_position = UE_pos;
Layout.center_frequency = 30e9;
Layout.BSSpacTuple = [2.5 2.5 0.5 0.5];
Layout.BSarrayTuple = [Mg Ng M N P];
Layout.UEarrayTuple = [1 1 1 1 P_ue];
Layout.UEX_pol = 0;
Layout.Ind_3_sector = 1;
Layout.UE_speed = 0;
Layout.dis_2pole = 0;
get_BS_UE_array_config( Layout);
Chan = ChannelConfig( Layout);
Chan.scenario = {'umi'};
Chan.Ind_spatconsis = 1;
Chan.Ind_LOS = 2;
Chan.Ind_O2I = 1;
Chan.channeltype = 'dynamic';
%-------------------------------------------
[HHhcoef,HHinfo] = get_channelcoeff( Chan,Layout);
%---------------------
w_tilt = 1/sqrt(M*N) * exp(-1i * pi * (0:M-1) * cos(ang_etilt/180*pi) ).'...
    .* exp(-1i * pi * (0:N-1) * sin(0/180*pi) ); % sure
delay = zeros(nUE,1);
AOA = zeros(nUE,1);
LOS = zeros(nUE,1);
chanresp = zeros(nUE,1);
P_eff = zeros(3, 1, nUE);
P_eff1 = zeros(3, 1, nUE);
for iUEp = 1 : nUE
    delay( iUEp ) = HHinfo.ssp(1, iUEp ).cluster.tau_n_tilde(3,1);
    AOA( iUEp ) = HHinfo.ssp(1, iUEp ).cluster.phi_AOA_nt(3,1);
    LOS( iUEp ) = HHinfo.lsp.Ind_LOS(1,iUEp );
    hh = HHhcoef(1, iUEp ).H; % ncluster(+4) nRx nTx nsnap
    h_temp = reshape(hh, size(hh,1), P_ue, M, N, [],3);
    h_temp = permute(h_temp, [3 4 1 2 5 6] ); % M N Npath P_ue []
    h_temp = sum(h_temp .* w_tilt,[1 2]);
    h_temp1 = sqrt(10.^(HHinfo.lsp.gainloss_dB(1, iUEp )/10 ) ) .* h_temp;
    h_temp1 = permute(h_temp1 , [3 1 2 4 5 6]);
    timedelay = HHhcoef(1, iUEp ).timedelay(:,1);
    hcfr = get_cfr(h_temp1(:,1,1,1,1,1), timedelay, BandWidth, nPRB); % nRx nTx N 1
    hcfr = permute(hcfr , [3 1 2]);
    chanresp(iUEp ) = hcfr( nPRB/2 +1 );
    %----
    P_temp = abs(h_temp).^2;
    P_temp1 = sum(P_temp,[3 4 5] ) / (Ng * P_ue * P);
    P_temp1 = permute(P_temp1, [6 1 2 3 4 5 ] );
    P_eff(:,1,iUEp) = ( 10^( BSpower/10 ) /1000 ) * P_temp1;
    P_temp2 = sum(P_temp(:,:,:,:,1,:),[3 4] ) / (P_ue);
    P_temp2 = permute(P_temp2, [6 1 2 3 4 5 ] );
    P_eff1(:,1,iUEp) = ( 10^( BSpower/10 ) /1000 ) * P_temp2;
end
P_cl = reshape(P_eff, [], nUE );
RSRP = reshape(P_eff1, [], nUE );
%------------------------
%Select serving cell(BS)
%Note that in this simulator, AS and DS in each BS site are the same.
[sub1, sub2] = find(RSRP == max(RSRP,[],1) );
Ind_servBS = ceil(sub1/3);
Ind_sc = sub2ind([nBS*3 nUE],sub1,sub2);
% %-------------------------------------
% Couplingloss
sim_cf1_cl = 10 * log10( P_cl(Ind_sc) ) - BSpower + 30;
% WidebandSINR
sim_cf1_wsinr = 10 * log10( max(RSRP,[],1)./ (Pn + sum(RSRP,1) ...
    - max(RSRP,[],1) ) );
%--------------------
figure;
plotecdf(sim_cf1_cl, -180,-40,100,'Coupling loss','dB');
figure;
plotecdf(sim_cf1_wsinr, -15,30,100,'SINR','dB');
delay = reshape(delay,nUEp,imax);
AOA = reshape(AOA,nUEp,imax);
LOS = reshape(LOS,nUEp,imax);
chanresp = reshape(chanresp,nUEp,imax);
corr_delay = get_cro_cor_coeff(delay(:,1),delay);
corr_AOA = get_cro_cor_coeff(AOA(:,1),AOA);
corr_LOS = get_cro_cor_coeff(LOS(:,1),LOS);
corr_Chanres = get_cro_cor_coeff(chanresp(:,1),chanresp);
% save('.\data\spconsconfig1_result.mat','corr_delay','corr_AOA','corr_LOS',...
%     'corr_Chanres','sim_cf1_cl','sim_cf1_wsinr')
%--------------------------------------
figure; set(gcf,'position',[300,100,1200,900],'color','w');
subplot(2,2,1);
plot(corr_delay); grid on; xlabel( 'Distance'); ylabel('xcorr-delay');
subplot(2,2,2);
plot(corr_AOA); grid on; xlabel( 'Distance' ); ylabel('xcorr-AOA');
subplot(2,2,3);
plot(corr_LOS); grid on; xlabel( 'Distance'); ylabel('xcorr-LOS');
subplot(2,2,4);
plot(corr_Chanres); grid on; xlabel( 'Distance'); ylabel('xcorr-channel response');
set(gca,'FontName','Times New Roman','FontSize',11);
toc;

