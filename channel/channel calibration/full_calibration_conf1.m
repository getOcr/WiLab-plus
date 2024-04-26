close all;
clear all;
clc;

addpath('..\');
rng('default');
M = 4;
N = 4;
P = 2;
Mg = 1;
Ng = 2;
P_ue = 2;
nUE = 2000;
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
% save('.\data\fullcalib_conf1_result.mat','nUE','-append');
for iii = 1 : 12
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
    Layout.BSSpacTuple = [2.5 2.5 0.5 0.5];
    Layout.BSarrayTuple = [Mg Ng M N P];
    Layout.UEarrayTuple = [1 1 1 1 P_ue];
    Layout.UEX_pol = 0;
    Layout.dis_2pole = 0;
    get_BS_UE_array_config( Layout );
    Chan = ChannelConfig(Layout);
    Chan.scenario = Scenario;
    Chan.Ind_LOS = Ind_LOS;
    Chan.Ind_O2I = Ind_O2I;
    Chan.channeltype = 'static';
    %-------------------------------------------
    [HHhcoef,HHinfo ] = get_channelcoeff( Chan,Layout  );
    %---------------------
    w_tilt = 1/sqrt(M*N) * exp(-1i * pi * (0:M-1) * cos(ang_etilt/180*pi) ).'...
        .* exp(-1i * pi * (0:N-1) * sin(0/180*pi) ); % sure
    P_eff = zeros(3, nBS, nUE);
    P_eff1 = zeros(3, nBS, nUE);
    for iBS = 1 : nBS
        for iUE = 1 : nUE
            hh = HHhcoef(iBS, iUE).H;
            h_temp = reshape(hh, size(hh,1), P_ue, M, N, [], 3);
            h_temp = permute(h_temp, [3 4 1 2 5 6] ); % M N Npath P_ue [] 3
            P_temp = abs(sum(h_temp .* w_tilt,[1 2]) ).^2;
            P_temp1 = sum(P_temp,[3 4 5] ) / (Ng * P_ue * P);
            P_temp1 = permute(P_temp1, [6 1 2 3 4 5 ] );
            P_eff(:,iBS,iUE) = ( 10^( BSpower/10 ) /1000 ) * P_temp1;
            P_temp2 = sum(P_temp(:,:,:,:,1,:),[3 4] ) / (P_ue);
            P_temp2 = permute(P_temp2, [6 1 2 3 4 5 ] );
            P_eff1(:,iBS,iUE) = ( 10^( BSpower/10 ) /1000 ) * P_temp2;
            %------------------
        end
    end
    P_cl = reshape(P_eff, [], nUE );
    RSRP = reshape(P_eff1, [], nUE );
    %------------------------
    %Select serving cell(BS)
    %Note that in this simulator, AS and DS in each BS site are the same.
    [sub1, sub2] = find(RSRP == max(RSRP,[],1) );
    Ind_servBS = ceil(sub1/3);
    Ind_sc = sub2ind([nBS*3 nUE],sub1,sub2);
    %-------------------------------------
    % Couplingloss
    CL = 10 * log10( P_cl(Ind_sc) ) - BSpower + 30;
    % WidebandSIR
    WSIR = 10 * log10( max(RSRP,[],1)./ (sum(RSRP,1) ...
        - max(RSRP,[],1) ) );
    %------------------------------------
    var_cell = {'cl','wsir','ds','asd','esd','asa','esa'};
    name_cell = {'Coupling Loss','Wideband SIR','Delay Spread','ASD','ESD','ASA','ESA'};
    unit_cell = {'dB','dB','nsec','deg','deg','deg','deg'};
    grid_min = [-180 -30 0 0 0 0 0];
    grid_max = [-40 40 6000 140 70 140 70];
    
    DS = get_DS_ServCell(HHinfo, Chan.channeltype, nUE, Ind_servBS)*1e9;
    for iF = 4 : 7
        eval([name_cell{iF},' = get_AS_ServCell(HHinfo, Chan.channeltype, nUE, Ind_servBS, var_cell{iF});']);
    end
    for iF = 1 : 7
        load('.\data\Fullcalib1.mat',[(Scenario{1}),'_',num2str(fix(cf/1e9)),'_',var_cell{iF}]);
    end
    figure; set(gcf,'position',[300,100,1200,900],'color','w');
    for iF = 1 : 7
        subplot(3,3,iF);
        plotecdf(eval([(Scenario{1}),'_',num2str(fix(cf/1e9)),'_',var_cell{iF}]),...
            grid_min(iF),grid_max(iF),100,name_cell{iF},unit_cell{iF});hold on;
        plotecdf(eval(upper(var_cell{iF})),...
            grid_min(iF),grid_max(iF),100,name_cell{iF},unit_cell{iF});hold on;
        title([upper(Scenario{1}),'-',num2str(fix(cf/1e9)),'GHz']);
        hl=legend('3GPP ref. mean','Simulator','Location','Best');
        eval(['sim_',(Scenario{1}),'_',num2str(fix(cf/1e9)),'_',var_cell{iF},...
            '=',upper(var_cell{iF}),';']);
        %         save(.\data\'fullcalib_conf1_result.mat',['sim_',(Scenario{1}),'_',...
        %             num2str(fix(cf/1e9)),'_',var_cell{iF}],'-append');
    end
    toc;
end


