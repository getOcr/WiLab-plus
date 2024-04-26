close all;
clear all;
clc;

addpath('..\');
rng('default');
M = 2;
N = 2;
P = 1;
Mg = 1;
Ng = 1;
P_ue = 2;
nUE = 1;
Ind_LOS = 2;
noise_K = 1.38e-23; % J/K
noise_T = 290; % K
UEnoisefig = 9; % dB
vh_BS = [10 10 10 10 25 25 25 25 3 3 3 3];
vISD = [200 200 200 200 500 500 500 500 20 20 20 20];
vmindis = [10 10 10 10 35 35 35 35 0 0 0 0 ];
vBSpower = [44 35 35 35 49 35 35 35 24 24 24 24];
vBandWidth = repmat([20e6 100e6 100e6 100e6],1,3);
vcf = [6e9 30e9 60e9 70e9 6e9 30e9 60e9 70e9 6e9 30e9 60e9 70e9 ];
cescen = {'umi','umi','umi','umi','uma','uma','uma','uma',...
    'indoor','indoor','indoor','indoor'};
vang_etilt =[102 102 102 102 102 102 102 102 110 110 110 110];
vnBS = [ones(1, 8) * 19, ones(1, 4) * 12];
vdis_2pole = [0.5 * ones(1,8), 0 * ones(1,4)];
% save('.\data\fullcalib_conf2_result.mat','nUE','-append');
for iii = 1 : 1
    tic;
    %-------------------------------
    Scenario = cescen( iii ); % cell sty
    min_dis = vmindis( iii );
    h_BS = vh_BS( iii );
    ISD = vISD( iii );
    max_dis = 0.93 * ISD;
    BSpower = vBSpower( iii ); % dBm
    cf = vcf( iii );
    BandWidth = vBandWidth( iii );
    ang_etilt = vang_etilt( iii );
    nBS = vnBS( iii );
    dis_2pole = vdis_2pole(iii);
    %-------------------------------
    [ BS_pos, BS_orient, UE_pos, UE_orient, Ind_O2I ] = ...
        get_BS_UE_layoutinfo(nBS, nUE, ISD, h_BS, min_dis, max_dis, ...
        Scenario{1,1},ang_etilt);
    Pgroundnoise = 10*log10( noise_K * noise_T * BandWidth );
    Pn = 10^( ( Pgroundnoise + UEnoisefig)/10 );
    %-------------------------------------------
    Layout = SysLayoutConfig;
    Layout.BS_position = BS_pos;
    Layout.Ind_3_sector = 1;
    Layout.BSorientation = BS_orient;
    Layout.UE_position = UE_pos;
    Layout.UEorientation = UE_orient;
    Layout.center_frequency = cf;
    Layout.BSarrayTuple = [Mg Ng M N P];
    Layout.UEarrayTuple = [1 1 1 1 P_ue];
    Layout.UEX_pol = 0;
    Layout.dis_2pole = dis_2pole;
    get_BS_UE_array_config( Layout );
    Chan = ChannelConfig(Layout);
    Chan.scenario = Scenario;
    Chan.Ind_LOS = Ind_LOS;
    Chan.Ind_O2I = Ind_O2I;
    Chan.channeltype = 'static';
    %-------------------------------------------
    [HHhcoef,HHinfo] = get_channelcoeff( Chan,Layout);
    %---------------------
    P_eff = zeros(3, nBS, nUE);
    for iBS = 1 : nBS
        for iUE = 1 : nUE
            hh = HHhcoef(iBS, iUE).H;
            h_temp = reshape(hh, [],4, 3);
            h_temp = permute(h_temp(:,1,:), [1 3 2]);
            P_temp = abs(h_temp).^2;
            P_temp = sum(P_temp, 1)/(P_ue);
            P_eff(:, iBS, iUE) = ( 10^( BSpower/10 ) /1000 ) * P_temp;
            %------------------
        end
    end
    RSRP = reshape(P_eff, [], nUE );
    % Couplingloss
    CL = 10 * log10( max(RSRP,[],1) ) - BSpower + 30;
    % WidebandSIR
    WSIR = 10 * log10(  max(RSRP,[],1)./ (sum(RSRP,1) ...
        - max(RSRP,[],1) ) );
    %--------------------------------------
    % Select serving cell
    [sub1, sub2] = find(RSRP == max(RSRP,[],1) );
    Ind_sBS = ceil(sub1/3);
    Ind_scell = mod(sub1-1,3) +1;
    %--------------------------------------
    nPRB = 1;
    sv = zeros(2,nUE);
    for iUE = 1 : nUE
        iBS = Ind_sBS(iUE);
        hh = HHhcoef(iBS, iUE).H; % ncluster(+4) nRx nTx nsnap
        h_temp = sqrt(10.^(HHinfo.lsp.gainloss_dB(iBS, iUE)/10 ) ) .* hh;
        timedelay = HHhcoef(iBS, iUE).timedelay;
        hcfr = get_cfr(h_temp, timedelay, BandWidth, nPRB); % nRx nTx N 1
        hcfr = reshape(hcfr, [2 4 3 nPRB]);
        %----------
        mhcfr = 0;
        for in = 1 : nPRB
            mhcfr = mhcfr +  hcfr(:,:,Ind_scell(iUE),in) *...
                hcfr(:,:,Ind_scell(iUE),in)';
        end
        sv(:,iUE) = eig(mhcfr)/nPRB;
    end
    sv = sort(sv,1);
    % 1st singular value
    LSV = 10*log10( sv(2,:,:) );
    % 2nd singular value
    SSV = 10*log10( sv(1,:,:) );
    % Ratio between Lsv and Ssv
    RATIO = LSV-SSV;
    %-------------------------------------
    var_cell = {'cl','wsir','1st','2nd','ratio'};
    var1_cell = {'CL','WSIR','LSV','SSV','RATIO'};
    name_cell = {'Coupling Loss','Wideband SIR','Largest singular value (LSV)',...
        'Smallest singular value (SSV)','Ratio between LSV and SSV'};
    unit_cell = {'dB','dB','dB','dB','dB'};
    grid_min = [-180 -30 -30 -80 0];
    grid_max = [-60 40 30 20 90];
    for iF = 1 : 5
        load('.\data\Fullcalib2.mat',[(Scenario{1}),'_',num2str(fix(cf/1e9)),'_',var_cell{iF}]);
    end
    figure;set(gcf,'position',[300,200,1200,600],'color','w');
    for iF = 1 : 5
        subplot(2,3,iF);
        plotecdf(eval([(Scenario{1}),'_',num2str(fix(cf/1e9)),'_',var_cell{iF}]),...
            grid_min(iF),grid_max(iF),100,name_cell{iF},unit_cell{iF});hold on;
        plotecdf(eval(var1_cell{iF}),...
            grid_min(iF),grid_max(iF),100,name_cell{iF},unit_cell{iF});hold on;
        title([upper(Scenario{1}),'-',num2str(fix(cf/1e9)),'GHz']);
        hl=legend('3GPP ref. mean','Simulator','Location','Best');
        eval(['sim_',(Scenario{1}),'_',num2str(fix(cf/1e9)),'_',var_cell{iF},...
            '=',var1_cell{iF},';']);
%         save('.\data\fullcalib_conf2_result.mat',['sim_',(Scenario{1}),'_',...
%             num2str(fix(cf/1e9)),'_',var_cell{iF}],'-append');
    end
    toc;
end

