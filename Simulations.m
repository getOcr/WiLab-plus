% Simplified scenario to use WilabV2Xsim
% Packet size and MCS are set accordingly to utilize the whole channel
% Each transmission uses all the subchannels available.
% NR-V2X is considered for these simulations

% WiLabV2Xsim('help')

close all    % Close all open figures
clear        % Reset variables
clc          % Clear the command window

para.packetSize=350;        % 1000B packet size
para.nTransm=1;              % Number of transmission for each packet
para.sizeSubchannel=10;      % Number of Resource Blocks for each subchannel 每个子信道10个RB
%Raw = [50, 150, 200];   % Range of Awarness for evaluation of metrics
para.Raw =100;
para.speed=40;               % Average speed
para.speedStDev=7;           % Standard deviation speed
para.SCS=30;                 % Subcarrier spacing [kHz]
para.pKeep=0.4;              % keep probability
para.periodicity=0.1;        % periodic generation every 100ms
para.sensingThreshold=-126;  % threshold to detect resources as busy
para.BRAlgorithm=18;
para.rho=[30];
para.BandMHz=[40];
para.cbrSensingInterval=0.005;
para.cbrSensingIntervalDesynchN=100;
para.F=6;
para.Ptx_dBm=23;
para.configFile = 'Highway3GPP.cfg';
%[para,sysPar, carrier, BeamSweep, RFI, PE] = WilabplusConfig();

%% NR-V2X PERIODIC GENERATION
for BandMHz=para.BandMHz

if BandMHz==20
    MCS=5;
elseif BandMHz==40
    MCS=23;
elseif BandMHz==100
    MCS=5;
end    
for i = para.rho % number of vehicles/km

        % Just for visualization purposes the simulations time now are really short,
        % when performing actual simulation, each run should take at least
        % 30mins or one hour of computation time.

    if i==30
        simTime=2;     % simTime=300
    elseif i==50
        simTime=10;      % simTime=150;
    elseif i==70
        simTime=3;      % simTime=100;
    end
    
% HD periodic
outputFolder = sprintf('Output/LWCC/NRV2X_%dMHz_periodic',BandMHz);


% % % Launches simulation
[posE,simValues,outputValues,appParams,simParams,phyParams,sinrManagement,outParams,stationManagement,timeManagement,positionManagement] = WiLabV2Xsim(para.configFile,'outputFolder',outputFolder,'Technology','5G-V2X','SCS_NR',para.SCS,'MCS_NR',MCS,'beaconSizeBytes',para.packetSize,...
    'simulationTime',simTime,'rho',i,'probResKeep',para.pKeep,'BwMHz',BandMHz,'vMean',para.speed,'vStDev',para.speedStDev,...
    'cv2xNumberOfReplicasMax',para.nTransm,'allocationPeriod',para.periodicity,'sizeSubchannel',para.sizeSubchannel,...
    'powerThresholdAutonomous',para.sensingThreshold,'Raw',para.Raw,'FixedPdensity',false,'dcc_active',false,'cbrActive',true,'BRAlgorithm',para.BRAlgorithm,'cbrSensingInterval',para.cbrSensingInterval);%'sysPar', sysPar,'carrier',carrier, 'BeamSweep', BeamSweep,'RFI', RFI,'PE',PE)

% 
% WiLabV2Xsim(configFile,'outputFolder',outputFolder,'Technology','5G-V2X','MCS_NR',MCS,'SCS_NR',SCS,'beaconSizeBytes',packetSize,...
%     'simulationTime',simTime,'rho',rho,'BwMHz',BandMHz,'vMean',speed,'vStDev',speedStDev,...
%     'cv2xNumberOfReplicasMax',nTransm,'allocationPeriod',periodicity,'sizeSubchannel',sizeSubchannel,...
%     'Raw',Raw,'FixedPdensity',false,'dcc_active',false,'cbrActive',true,'BRAlgorithm',BRAlgorithm)
% 

% WiLabV2Xsim(configFile,'outputFolder',outputFolder,'Technology','LTE-V2X','MCS_LTE',MCS,'beaconSizeBytes',packetSize,...
%     'simulationTime',simTime,'rho',rho,'BwMHz',BandMHz,'vMean',speed,'vStDev',speedStDev,...
%     'cv2xNumberOfReplicasMax',nTransm,'allocationPeriod',periodicity,'sizeSubchannel',sizeSubchannel,...
%     'Raw',Raw,'FixedPdensity',false,'dcc_active',false,'cbrActive',true,'BRAlgorithm',BRAlgorithm)
% 

end
end

% 
%% PLOT of results

figure
hold on
grid on

for iCycle=1:3
    rho=100*iCycle;

    % Loads packet reception ratio output file
    xMode2_periodic=load(outputFolder + "/packet_reception_ratio_"+num2str(iCycle)+"_5G.xls");

    % PRR plot
    % it takes the first column and the last column
    plot(xMode2_periodic(:,1),xMode2_periodic(:,end),'linewidth',2.5,'displayName',"Mode2, periodic generation, vehicles/km=" + num2str(rho))

end
    
    legend()
    title("NR-V2X, " + num2str(BandMHz) + "MHz, MCS=" + num2str(MCS))
    legend('Location','southwest')
    xlabel("Distance [m]")
    ylabel("PRR")
    yline(0.95,'HandleVisibility','off');


% iCycle=1;
% rho=100*iCycle;
% 
% % Loads packet_delay output file
% xMode2_periodic=load(outputFolder + "/update_delay_"+num2str(iCycle)+"_5G.xls");
% xMode2_periodic_2=load(outputFolder + "/update_delay_"+num2str(2)+"_5G.xls");
% xMode2_periodic_3=load(outputFolder + "/packet_delay_"+num2str(3)+"_5G.xls");
% % packet_delay plot
% % it takes the first column and the last column
% plot(xMode2_periodic(:,1),xMode2_periodic(:,3),'linewidth',2.5,'displayName',"Mode2, periodic generation, vehicles/km=" + num2str(rho))
% plot(xMode2_periodic_2(:,1),xMode2_periodic_2(:,3),'linewidth',2.5,'displayName',"Mode1, periodic generation, vehicles/km=" + num2str(rho)) 
% legend()
% title("NR-V2X, " + num2str(BandMHz) + "MHz, MCS=" + num2str(MCS))
% legend('Location','southwest')
% xlabel("Delay [s]")
% ylabel("CDF")
% yline(0.95,'HandleVisibility','off');

% 

