function[sysPar, carrier, BeamSweep, RFI, PE] = WilabplusConfig(phyParams)
    %% Configuration function for Wilab+
    % Developer: Jin. Institution: SHU. Date: 2024/4/23
    
    fprintf('sysPar carrier BeamSweep RFI PE settings\n');

   % [sysPar,varargin] = addNewParam([],'bandwidth',1e8,'bandwidth','double',fileCfg,varargin{1});
  %  [sysPar,varargin] = addNewParam(sysPar,'center_frequency',4.9e9,'center_frequency','double',fileCfg,varargin{1});
   % [sysPar,varargin] = addNewParam(sysPar,'nFrames',0.05,'nFrames (s)','double',fileCfg,varargin{1});
%     
%     para.packetSize=350;        % 1000B packet size
%     para.nTransm=1;              % Number of transmission for each packet
%     para.sizeSubchannel=10;      % Number of Resource Blocks for each subchannel 每个子信道10个RB
%     %Raw = [50, 150, 200];   % Range of Awarness for evaluation of metrics
%     para.Raw =100;
%     para.speed=40;               % Average speed
%     para.speedStDev=7;           % Standard deviation speed
%     para.SCS=15;                 % Subcarrier spacing [kHz]
%     para.pKeep=0.4;              % keep probability
%     para.periodicity=0.1;        % periodic generation every 100ms
%     para.sensingThreshold=-126;  % threshold to detect resources as busy
%     para.BRAlgorithm=18;
%     para.rho=[30 50 70];
%     para.BandMHz=[20];     
%     %% Configuration file
%     para.configFile = 'Highway3GPP.cfg';

    %% Configuration for positioning module
    % indicator of using SL positioning module
    sysPar.SLposi_en=false;

    if sysPar.SLposi_en
        %% ====Basic Parameters Config.====%
        sysPar.nFrames = 0.1;   %
        sysPar.center_frequency = 5.9e9;
        sysPar.UEstate = 'static';% static or dynamic
        sysPar.VelocityUE = 3/3.6;% m/s
        sysPar.BSArraySize = [1 4];
        sysPar.UEArraySize = [1 1];
        sysPar.nBS = 2;
        sysPar.nUE = 1;
        sysPar.RSPeriod = 4;  % n slot
        sysPar.SignalType = 'SRS';       %'SRS', 'CSIRS'
        sysPar.BeamSweep = 0;
        sysPar.SNR = 20; % in dB 
        sysPar.bandwidth = phyParams.BwMHz*1e6; %bandwidth与主函数对齐
        %% ====System layout Config.========%
        %%以下四行是默认值，在定位函数里可有修改
        sysPar.h_BS = 1.5;
        sysPar.h_UE = 1.5;
        sysPar.BSorientation = pi * ones(1, sysPar.nBS);
        sysPar.UEorientation = 0  * rand(1, sysPar.nUE); 
        % sysPar.BSPos = [ zeros(1, sysPar.nBS) ; (0 : sysPar.nBS-1) * 20 ;...
        %     sysPar.h_BS * ones(1, sysPar.nBS) ];
        % sysPar.UEPos = [ (-30 * rand(1,sysPar.nUE) -10); (50 * rand(1,sysPar.nUE) );...
        %     sysPar.h_UE * ones(1,sysPar.nUE)];
        % sysPar.UEPos(:,1) = [ -20 ; 10; sysPar.h_UE];
        
        
        % sysPar.Scenario = '3GPP_38.901_Indoor_LOS';
        sysPar.Scenario = {'umi'};
        % '3GPP_38.901_InF_DH''LOSonly','3GPP_38.901_Indoor_LOS'
        sysPar.powerUE = 23; % dBm 200 mW   
        sysPar.powerBS = 23; % dBm 250 mW
        sysPar = cf.ParaTransConfig(sysPar);
        %% ====Carrier Config.==============%
        carrier = nr.CarrierConfig;
        carrier.NSizeGrid = RBtable_5G(phyParams.BwMHz,phyParams.SCS_NR);   %RB数量，remember to modify the corresponding configuration in signal Config function
        carrier.SubcarrierSpacing = phyParams.SCS_NR;   %子载波间隔与主函数对齐
        %% ====RS Config.===================%
        sysPar = cf.SigResConfig(sysPar, carrier);
        %% ====Beam Sweeping Config.========%
        BeamSweep = BeamSweepConfig(sysPar,carrier);
        %% ====Channel Simulator Config.====%
        %[Layout, Chan] = cf.ChanSimuConfig(sysPar, carrier); %%信道配置要在定位函数里进行
        %% ======Hardware Imparement========%
        RFI = RFImpairConfig(sysPar, carrier);
        % FRI.Ind_AntPhaseOffset =1;
        % FRI.Ind_IQImbalance = 1; 
        % FRI.Ind_TimingOffset = 1;
        % FRI.Ind_ApproxiCIR = true;
        RFI.Ind_SNR = 0; % 0 for base noise; 1 sig power by path loss; 2 measured; 3 no noise
        %% === Estimation Config.===========%
        PE = ParaEstimation;
        PE.SCS = carrier.SubcarrierSpacing;
        % SRS = nr.SRSConfig;
        % SRS.m_srs_b = carrier.NSizeGrid;
        PE.AngEstiMethodSel = 'music1';
        PE.RngEstiMethodSel = 'toa_music';
    else
        [carrier, BeamSweep, RFI, PE] = deal([],[],[],[]); %定位模块不启动时
    end
    



end