close all;
clear all;
clc;
% config2
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
min_dis = 10;
ISD = 200;
max_dis = 100;
BSpower = 35; % dBm
BandWidth = 100e6;
ang_etilt = 102;
nBS = 1;
nUE = 100;
nsnap = 100;
inteval = 0.1; % seconds
Pgroundnoise = 10*log10( noise_K * noise_T * BandWidth );
Pn = 10^( ( Pgroundnoise + UEnoisefig)/10 );
% save('.\data\spconsconfig2_result.mat','nUE','-append');
h_UE = 1.5 * ones(nUE,1);
r_UE = sqrt( rand(nUE, 1 ) ) * ( max_dis - min_dis ) + min_dis;
theta_UE = rand( nUE, 1 ) * 2 * pi;
x_UE = r_UE .* cos( theta_UE );
y_UE = r_UE .* sin( theta_UE );
UE_pos = [ x_UE, y_UE, h_UE ].';
% UE_pos = [0 10 1.5].';
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
Layout.UE_speed = 30/3.6;
Layout.UE_mov_direction = [pi*2*rand(1,nUE); pi/2*ones(1,nUE)];
Layout.dis_2pole = 0;
get_BS_UE_array_config( Layout );
Chan = ChannelConfig(Layout);
Chan.scenario = {'umi'};
Chan.Ind_spatconsis = 1;
Chan.Ind_LOS = 2;
Chan.Ind_O2I = 0;
Chan.channeltype = 'dynamic';
Chan.interval_snap = inteval; %100ms
Chan.nsnap = nsnap;
%-------------------------------------------
[HHhcoef,HHinfo] = get_channelcoeff( Chan,Layout);
%---------------------
w_tilt = 1/sqrt(M*N) * exp(-1i * pi * (0:M-1) * cos(ang_etilt/180*pi) ).'...
    .* exp(-1i * pi * (0:N-1) * sin(0/180*pi) ); % sure
delay = zeros(nUE,nsnap);
AOA = zeros(nUE,nsnap);
Pow = zeros(nUE,nsnap);
P_eff = zeros(3, 1, nUE);
P_eff1 = zeros(3, 1, nUE);
for iUE = 1 : nUE
    delay( iUE,: ) = HHinfo.ssp(1, iUE ).cluster.tau_n_tilde(3,:)*1e9;
    AOA( iUE,: ) = HHinfo.ssp(1, iUE ).cluster.phi_AOA_nt(3,:);
    Pow( iUE,: ) = HHinfo.ssp(1, iUE ).cluster.P_nt(3,:);
    hh = HHhcoef(1, iUE ).H(:,:,:,1); % ncluster(+4) nRx nTx nsnap
    h_temp = reshape(hh, size(hh,1), P_ue, M, N, [],3);
    h_temp = permute(h_temp, [3 4 1 2 5 6] ); % M N Npath P_ue []
    h_temp = sum(h_temp .* w_tilt,[1 2]);
    P_temp = abs(h_temp).^2;
    P_temp1 = sum(P_temp,[3 4 5] ) / (Ng * P_ue * P);
    P_temp1 = permute(P_temp1, [6 1 2 3 4 5 ] );
    P_eff(:,1,iUE) = ( 10^( BSpower/10 ) /1000 ) * P_temp1;
    P_temp2 = sum(P_temp(:,:,:,:,1,:),[3 4] ) / (P_ue);
    P_temp2 = permute(P_temp2, [6 1 2 3 4 5 ] );
    P_eff1(:,1,iUE) = ( 10^( BSpower/10 ) /1000 ) * P_temp2;
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
CL2 = 10 * log10( P_cl(Ind_sc) ) - BSpower + 30;
% WidebandSINR
WSINR2 = 10 * log10( max(RSRP,[],1)./ (Pn + sum(RSRP,1) ...
    - max(RSRP,[],1) ) );
%--------------------
AOA = unwrap(AOA/180*pi)/pi*180;
stddelay = std(delay,[],2) /inteval;
stdAOA = std(AOA,[],2) /inteval;
stdPow = std(Pow,[],2) /inteval;
% save('.\data\spconsconfig2_result.mat.mat','CL2','WSINR2',...
%     'stddelay','stdAOA','stdPow')
toc;
figure;set(gcf,'position',[300,100,1200,900],'color','w');
subplot(2,3,1);
plotecdf(CL2, -40,-180,100,'Coupling loss','dB');
subplot(2,3,2);
plotecdf(WSINR2, -15,30,100,'SINR','dB');
subplot(2,3,3);
plotecdf(stddelay, 0,10000,100,'avg varying rate -- AOA',[]);
subplot(2,3,4);
plotecdf(stdAOA, 0,1400,100,'avg varying rate -- AOA',[]);
subplot(2,3,5);
plotecdf(stdPow, 0,1.8,100,'avg varying rate -- AOA',[]);
set(gca,'FontName','Times New Roman','FontSize',11);


