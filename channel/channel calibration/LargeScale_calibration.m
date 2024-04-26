close all;
clear all;
clc;

addpath('..\');
rng('default');
M = 10;
nUE = 200;
Ind_LOS = 2;
noise_K = 1.38e-23; % J/K
noise_T = 290; % K
UEnoisefig = 9; % dB
vh_BS = [10 10 10 25 25 25 3 3 3];
vISD = [200 200 200 500 500 500 20 20 20];
vmindis = [10 10 10 35 35 35 0 0 0 ];
vBSpower = [44 35 35 49 35 35 24 24 24];
vBandWidth = [20e6 100e6 100e6 20e6 100e6 100e6 20e6 100e6 100e6];
vcf = [6e9 30e9 70e9 6e9 30e9 70e9 6e9 30e9 70e9];
cescen = {'umi','umi','umi','uma','uma','uma','Indoor','Indoor','Indoor'};
vang_etilt =[102 102 102 102 102 102 110 110 110];
vnBS = [ones(1,6) * 19, ones(1,3) * 12];
vdis_2pole = [0.5 * ones(1,6), 0.2 * ones(1,3)];
% save('.\data\LScalib_result.mat','nUE','-append');
for iii = 7 : 7
    tic;
    %-------------------------------
    Scenario = cescen(iii); % cell sty
    min_dis = vmindis(iii);
    h_BS = vh_BS(iii);
    ISD = vISD(iii);
    max_dis = 0.93 * ISD;
    BSpower = vBSpower(iii); % dBm
    cf = vcf(iii);
    BandWidth = vBandWidth(iii);
    ang_etilt = vang_etilt(iii);
    nBS = vnBS(iii);
    dis_2pole = vdis_2pole(iii);
    %-------------------------------
    [ BS_pos, BS_orient, UE_pos,~, Ind_O2I ] = get_BS_UE_layoutinfo(nBS, ...
        nUE, ISD, h_BS, min_dis, max_dis,Scenario{1,1},ang_etilt);
    Pgroundnoise = 10*log10( noise_K * noise_T * BandWidth);
    Pn = 10^( ( Pgroundnoise + UEnoisefig)/10 );
    %-------------------------------------------
    Layout = SysLayoutConfig;
    Layout.BS_position = BS_pos;
    Layout.Ind_3_sector = 1;
    Layout.BSorientation = BS_orient;
    Layout.UE_position = UE_pos;
    Layout.center_frequency = cf;
    Layout.BSarrayTuple = [1 1 M 1 1];  
    Layout.dis_2pole = dis_2pole;
    get_BS_UE_array_config(Layout);
    Chan = ChannelConfig(Layout);
    Chan.scenario = Scenario;
    Chan.Ind_LOS = Ind_LOS;
    Chan.Ind_O2I = Ind_O2I;
    Chan.channeltype = 'LOSonly';
    %-------------------------------------------
    [HHhcoef,~] = get_channelcoeff( Chan,Layout);
    %---------------------
    w_tilt = 1/sqrt(M)*exp(-1i*pi*(0:M-1)*cos(ang_etilt/180*pi) ).'; % sure
    coeff = zeros(M, 3, nBS, nUE);
    for iBS = 1 : nBS
        for iUE = 1 : nUE
            coeff(:,:,iBS,iUE) = reshape(HHhcoef(iBS, iUE).H,1,[],3);
        end
    end
    coeff = reshape(coeff, M, [], nUE);
    P_on =  ( 10^( BSpower/10 ) /1000 ) * abs( sum( coeff .* w_tilt, 1 ) ).^2;
    P_on = squeeze( P_on );
    % couplingloss
    CL = 10 * log10( max(P_on,[],1) ) -BSpower +30 ;
    % geometryfactor with noise
    GF_wn = 10 * log10(  max(P_on,[],1)./ (sum(P_on,1) +Pn - max(P_on,[],1) ) );
    % geometryfactor without noise
    GF_on = 10 * log10(  max(P_on,[],1)./ (sum(P_on,1) - max(P_on,[],1) ) );
    %------------------------------------
    
    var_cell = {'cl','gf_o','gf_w'};
    var1_cell = {'CL','GF_on','GF_wn'};
    name_cell = {'Coupling loss','Geometry factor without noise',...
        'Geometry factor with noise'};
    unit_cell = {'dB','dB','dB'};
    grid_min = [-180 -30 -30];
    grid_max = [-60 40 40];
    for iF = 1 : 3
        load('.\data\LScalib_3gpp.mat',[(Scenario{1}),'_',num2str(fix(cf/1e9)),'_',var_cell{iF}]);
    end
    figure;set(gcf,'position',[300,300,1200,300],'color','w');
    for iF = 1 : 3
        subplot(1,3,iF);
        plotecdf(eval([(Scenario{1}),'_',num2str(fix(cf/1e9)),'_',var_cell{iF}]),...
            grid_min(iF),grid_max(iF),100,name_cell{iF},unit_cell{iF});hold on;
        plotecdf(eval(var1_cell{iF}),...
            grid_min(iF),grid_max(iF),100,name_cell{iF},unit_cell{iF});hold on;
        title([upper(Scenario{1}),'-',num2str(fix(cf/1e9)),'GHz']);
        hl=legend('3GPP ref. mean','Simulator','Location','Best');
        eval(['sim_',(Scenario{1}),'_',num2str(fix(cf/1e9)),'_',var_cell{iF},...
            '=',var1_cell{iF},';']);
        %         save('.\data\LScalib_result.mat',['sim_',(Scenario{1}),'_',...
        %             num2str(fix(cf/1e9)),'_',var_cell{iF}],'-append');
    end
    toc;
end

