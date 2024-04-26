function [simValues,outputValues,appParams,simParams,phyParams,sinrManagement,outParams,stationManagement] = mainV2X(appParams,simParams,phyParams,outParams,simValues,outputValues,positionManagement,sysPar, carrier, BeamSweep, RFI, PE)
% Core function where events are sorted and executed

%% Initialization
[appParams,simParams,phyParams,outParams,simValues,outputValues,...
    sinrManagement,timeManagement,positionManagement,stationManagement] = mainInit(appParams,simParams,phyParams,outParams,simValues,outputValues,positionManagement);


% The variable 'timeNextPrint' is used only for printing purposes
timeNextPrint = 0;
CRLB_Range_Array =  [];
CRLB_Range_Sum = [];
ROOT_CRLB_Range_Array = [];
CRLB_Range_FilterSum=[];
% The variable minNextSuperframe is used in the case of coexistence
minNextSuperframe = min(timeManagement.coex_timeNextSuperframe);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Simulation Cycle
% The simulation ends when the time exceeds the duration of the simulation
% (not really used, since a break inside the cycle will stop the simulation
% earlier)

% Start stopwatch
tic

fprintf('Simulation ID: %d\nMessage: %s\n',outParams.simID, outParams.message);
fprintf('Simulation Time: ');
reverseStr = '';
fprintf('\n ');
while timeManagement.timeNow < simParams.simulationTime
    
    % The instant and node of the next event is obtained
    % indexEvent is the index of the vector IDvehicle
    % idEvent is the ID of the vehicle of the current event
    [timeEvent, indexEvent] = min(timeManagement.timeNextEvent(stationManagement.activeIDs));
    idEvent = stationManagement.activeIDs(indexEvent);


 
    % If the next C-V2X event is earlier than timeEvent, set the time to the
    % C-V2X event
    if timeEvent >= timeManagement.timeNextCV2X - 1e-9
        timeEvent = timeManagement.timeNextCV2X;
        %fprintf('LTE subframe %.6f\n',timeEvent);
    end

    % If the next superframe event (coexistence, method A) is earlier than timeEvent, set the time to the
    % this event
    if timeEvent >= minNextSuperframe  - 1e-9
        timeEvent = minNextSuperframe;
    end
        
    % If timeEvent is later than the next CBR update, set the time
    % to the CBR update
    if timeEvent >= (timeManagement.timeNextCBRupdate - 1e-9) 
        timeEvent = timeManagement.timeNextCBRupdate;
        %fprintf('CBR update%.6f\n',timeEvent);
    end
        
    % If timeEvent is later than the next position update, set the time
    % to the position update
    % With LTE, it must necessarily be done after the end of a subframe and
    % before the next one
    if timeEvent >= (timeManagement.timeNextPosUpdate-1e-9) && ...
        (isempty(stationManagement.activeIDsCV2X) || (isfield(timeManagement, "ttiCV2Xstarts") && timeManagement.ttiCV2Xstarts==true))
        timeEvent = timeManagement.timeNextPosUpdate;
    end
    
    % to avoid vechile go out of scenario right before CV2X Tx ending or CBR update
    % special case: timeManagement.timeNextPosUpdate == timeManagement.timeNextCV2X
    if (isfield(timeManagement, "ttiCV2Xstarts") && timeManagement.ttiCV2Xstarts==false) ||...
            timeManagement.timeNextPosUpdate == timeManagement.timeNextCBRupdate
        delayPosUpdate = true;
    else
        delayPosUpdate = false;
    end

    % if the CV2X ending transmission time equals to the timeNextCBRupdate,
    % end the transmission first
    if timeManagement.timeNextCBRupdate == timeManagement.timeNextCV2X &&...
            (isfield(timeManagement, "ttiCV2Xstarts") && timeManagement.ttiCV2Xstarts==false)
        delayCBRupdate = true;
    else
        delayCBRupdate = false;
    end

    % if the CV2X ending transmission time equals to the minNextSuperframe,
    % end the transmission first
    if minNextSuperframe == timeManagement.timeNextCV2X &&...
            (isfield(timeManagement, "ttiCV2Xstarts") && timeManagement.ttiCV2Xstarts==false)
        delay_minNextSuperframe = true;
    else
        delay_minNextSuperframe = false;
    end
    if timeEvent < timeManagement.timeNow
        % error log
        fid_error = fopen(fullfile(outParams.outputFolder,...
            sprintf("error_log_%d.txt",outParams.simID)), "at");
        fprintf(fid_error, sprintf("Time goes back! Stop and check!\nSeed=%d, timeNow=%f, timeEvent=%f\n",...
            simParams.seed, timeManagement.timeNow, timeEvent));
        fclose(fid_error);
    end
    % update timenow, timenow do not go back, deal with float-point-related
    % cases.
    % fixme: need to check
    timeManagement.timeNow = max(timeEvent, timeManagement.timeNow);
    
    % If the time instant exceeds or is equal to the duration of the
    % simulation, the simulation is ended
    if round(timeManagement.timeNow, 10) >= round(simParams.simulationTime, 10)
        break;
    end

    %%
    % Print time to video
    while timeManagement.timeNow > timeNextPrint  - 1e-9
        reverseStr = printUpdateToVideo(timeManagement.timeNow,simParams.simulationTime,reverseStr);
        timeNextPrint = timeNextPrint + simParams.positionTimeResolution;
        fprintf('\n循环时刻:%0.5f,下一循环时刻：%0.5f\n',timeManagement.timeNow,timeNextPrint);
    end

    %% Action
    % The action at timeManagement.timeNow depends on the selected event
    % POSITION UPDATE: positions of vehicles are updated
    if timeEvent == timeManagement.timeNextPosUpdate && ~delayPosUpdate
        % DEBUG EVENTS
        % printDebugEvents(timeEvent,'position update',-1);
        
        if isfield(timeManagement,'ttiCV2Xstarts') && timeManagement.ttiCV2Xstarts==false
            % During a position update, some vehicles can enter or exit the
            % scenario; this is not managed if it happens during one
            % subframe
            error('A position update is occurring during the subframe; not allowed by implementation.');
        end
        %%%%%%%%%%%%%%
        % 找到 NaN 值的索引
        CRLB_Range_ArrayFilter = CRLB_Range_Array;
        NaNIndices = CRLB_Range_Array>10 | isnan(CRLB_Range_Array);
        % 使用逻辑索引删除 NaN 值
        CRLB_Range_ArrayFilter2= CRLB_Range_ArrayFilter(~NaNIndices);
        CRLB_Range_FilterSum=[CRLB_Range_FilterSum,CRLB_Range_ArrayFilter2];
        % 找到数组的众数
        mode_value = mode(sqrt(CRLB_Range_FilterSum));

        CRLB_Range_FilterSum_percentile_99 = prctile(sqrt(CRLB_Range_FilterSum), 95);
        fprintf('\n 更新的root 95percent CRLB:%0.4f m\n', mode_value); 


%         CRLB_Range_Sum = [CRLB_Range_Sum, CRLB_Range_Array];
%         fprintf('\n位置更新时刻:%0.5f\n',timeManagement.timeNow); 
%         percentile_99 = prctile(sqrt(CRLB_Range_Array), 99);
%         %fprintf('\n CRLB_Range_Array:%0.7f\n',CRLB_Range_Array); 
% 
%         fprintf('\n ROOT_CRLB_Range:%0.7f m\n',percentile_99); 
%         ROOT_CRLB_Range_Array = [ROOT_CRLB_Range_Array,percentile_99];

        CRLB_Range_Array = [];


        [appParams,simParams,phyParams,outParams,simValues,outputValues,timeManagement,positionManagement,sinrManagement,stationManagement] = ...
            mainPositionUpdate(appParams,simParams,phyParams,outParams,simValues,outputValues,timeManagement,positionManagement,sinrManagement,stationManagement);
        

        %%%%%%%%%%%%%%%%   
%         sinr=mean(sinrManagement.cumulativeSINR(:, 5));
%         %sinr=mean(mean(sinrManagement.cumulativeSINR););
%         SINR=mean(sinr);
%         crlb=CaculateCLRB_Range(SINR,phyParams.SCS_NR);
%         fprintf('第140行：第1辆车范围估计的CRLB=%0.15f\n',crlb);
        %%%%%%%%%%%
        timeManagement.timeNextPosUpdate = round(timeManagement.timeNextPosUpdate + simParams.positionTimeResolution, 10);
        positionManagement.NposUpdates = positionManagement.NposUpdates+1;

    elseif timeEvent == timeManagement.timeNextCBRupdate && ~delayCBRupdate
        % Part dealing with the channel busy ratio calculation
        % Done for every station in the system, if the option is active
        %
        thisSubInterval = mod(ceil((timeEvent-1e-9)/(simParams.cbrSensingInterval/simParams.cbrSensingIntervalDesynchN))-1,simParams.cbrSensingIntervalDesynchN)+1;
        %
        % ITS-G5
        % CBR and DCC (if active)
        if ~isempty(stationManagement.activeIDs11p)
            vehiclesToConsider = stationManagement.activeIDs11p(stationManagement.cbr_subinterval(stationManagement.activeIDs11p)==thisSubInterval);        
            [timeManagement,stationManagement,stationManagement.cbr11pValues(vehiclesToConsider,ceil(timeEvent/simParams.cbrSensingInterval-1e-9))] = ...
                cbrUpdate11p(timeManagement,vehiclesToConsider,stationManagement,simParams,phyParams,outParams);
%             %% =========
%             % Plot figs of related paper, could be commented in other case.
%             % Please check .../codeForPaper/Zhuofei2023Repetition/fig6
%             % Only for IEEE 802.11p, highway scenario. 
%             % log number of replicas
%             stationManagement.ITSReplicasLog(vehiclesToConsider,ceil(timeEvent/simParams.cbrSensingInterval-1e-9)) = stationManagement.ITSNumberOfReplicas(vehiclesToConsider);
%             stationManagement.positionLog(vehiclesToConsider,ceil(timeEvent/simParams.cbrSensingInterval-1e-9)) = positionManagement.XvehicleReal(vehiclesToConsider);
%             %% =========
        end
        % In case of Mitigation method with dynamic slots, also in LTE nodes
        if simParams.technology==constants.TECH_COEX_STD_INTERF && simParams.coexMethod~=constants.COEX_METHOD_NON && simParams.coex_slotManagement==constants.COEX_SLOT_DYNAMIC && simParams.coex_cbrTotVariant==2
            vehiclesToConsider = stationManagement.activeIDsCV2X(stationManagement.cbr_subinterval(stationManagement.activeIDsCV2X)==thisSubInterval);
            [timeManagement,stationManagement,sinrManagement.cbrLTE_coex11ponly(vehiclesToConsider)] = ...
                cbrUpdate11p(timeManagement,vehiclesToConsider,stationManagement,simParams,phyParams,outParams);
        end
       
        % LTE-V2X
        % CBR and DCC (if active)
        if ~isempty(stationManagement.activeIDsCV2X)
            vehiclesToConsider = stationManagement.activeIDsCV2X(stationManagement.cbr_subinterval(stationManagement.activeIDsCV2X)==thisSubInterval);
            [timeManagement,stationManagement,sinrManagement,stationManagement.cbrCV2Xvalues(vehiclesToConsider,ceil(timeEvent/simParams.cbrSensingInterval)),stationManagement.coex_cbrLteOnlyValues(vehiclesToConsider,ceil(timeEvent/simParams.cbrSensingInterval))] = ...
                cbrUpdateCV2X(timeManagement,vehiclesToConsider,stationManagement,positionManagement,sinrManagement,appParams,simParams,phyParams,outParams,outputValues);
        end
        
        timeManagement.timeNextCBRupdate = round(timeManagement.timeNextCBRupdate + (simParams.cbrSensingInterval/simParams.cbrSensingIntervalDesynchN), 10);

    elseif timeEvent == minNextSuperframe && ~delay_minNextSuperframe
        % only possible in coexistence with mitigation methods
        if simParams.technology~=constants.TECH_COEX_STD_INTERF || simParams.coexMethod==constants.COEX_METHOD_NON
            error('Superframe is only possible with coexistence, Methods A, B, C, F');
        end
        
        % coexistence Methods, superframe boundary
        [timeManagement,stationManagement,sinrManagement,outputValues] = ...
            superframeManagement(timeManagement,stationManagement,simParams,sinrManagement,phyParams,outParams,simValues,outputValues);
                    
         minNextSuperframe=min(timeManagement.coex_timeNextSuperframe(stationManagement.activeIDs));
        
        sinr=mean(sinrManagement.cumulativeSINR);
        SINR=mean(sinr);
        crlb=CaculateCLRB_Range(SINR,phyParams.SCS_NR);
        fprintf('第213行：第1辆车范围估计的CRLB=%0.15f\n',crlb);
        % CASE C-V2X
    elseif abs(timeEvent-timeManagement.timeNextCV2X)<1e-8    % timeEvent == timeManagement.timeNextCV2X

        if timeManagement.ttiCV2Xstarts
            % DEBUG EVENTS
            %printDebugEvents(timeEvent,'LTE subframe starts',-1);
            %fprintf('Starts\n');M_sc_b
 
            if timeManagement.timeNow>0
                [phyParams,simValues,outputValues,sinrManagement,stationManagement,timeManagement] = ...
                    mainCV2XttiEnds(appParams,simParams,phyParams,outParams,simValues,outputValues,timeManagement,positionManagement,sinrManagement,stationManagement,vehiclesToConsider);
                
                %%%%%%%车辆定位模块
                if sysPar.SLposi_en
                    % 先随机生成一个包含随机0和1的nRBx1资源分配矩阵
                    ResourseAllocation_RB = randi([0, 1], appParams.RBsFrequencyV2V, 1);
                    % 定位函数
                    [Angle_esti,Range_esti,EstiLoc,LocErr,LocErrall] = mainV2XSidelinkPosition(ResourseAllocation_RB,positionManagement,sysPar, carrier, BeamSweep, RFI, PE);
                end
 
            end
            
            [sinrManagement,stationManagement,timeManagement,outputValues] = ...
                mainCV2XttiStarts(appParams,phyParams,timeManagement,sinrManagement,stationManagement,simParams,simValues,outParams,outputValues);

            % DEBUG TX-RX
            % if isfield(stationManagement,'IDvehicleTXLTE') && ~isempty(stationManagement.transmittingIDsLTE)
            %     printDebugTxRx(timeManagement.timeNow,'LTE subframe starts',stationManagement,sinrManagement);
            % end

            % DEBUG TX
            % printDebugTx(timeManagement.timeNow,true,-1,stationManagement,positionManagement,sinrManagement,outParams,phyParams);

            timeManagement.ttiCV2Xstarts = false;
            timeManagement.timeNextCV2X = round(timeManagement.timeNextCV2X + (phyParams.TTI - phyParams.TsfGap), 10);

            % DEBUG IMAGE
            % if isfield(stationManagement,'IDvehicleTXLTE') && ~isempty(stationManagement.transmittingIDsLTE)
            %     printDebugImage('LTE subframe starts',timeManagement,stationManagement,positionManagement,simParams,simValues);
            % end
        else
            % DEBUG EVENTS
            % printDebugEvents(timeEvent,'LTE subframe ends',-1);
            % fprintf('Stops\n');

            [phyParams,simValues,outputValues,sinrManagement,stationManagement,timeManagement] = ...
                mainCV2XtransmissionEnds(appParams,simParams,phyParams,outParams,simValues,outputValues,timeManagement,positionManagement,sinrManagement,stationManagement);

            % DEBUG TX-RX
            % if isfield(stationManagement,'IDvehicleTXLTE') && ~isempty(stationManagement.transmittingIDsLTE)
            %     printDebugTxRx(timeManagement.timeNow,'LTE subframe ends',stationManagement,sinrManagement);
            % end

            timeManagement.ttiCV2Xstarts = true;
            timeManagement.timeNextCV2X = round(timeManagement.timeNextCV2X + phyParams.TsfGap, 10);

            %%%%%%%%%%%%%
            TransmissionCar = stationManagement.transmittingIDsCV2X;
            cumulativeSINR = sinrManagement.cumulativeSINR;
            if numel(TransmissionCar) > 1
                disp('TransmissionCar不是1*1的数组，程序将在此处暂停。');
                %keyboard; % 启动调试模式
            end
            CLRB_Range = zeros(1,length(TransmissionCar));

            for i = 1:length(TransmissionCar)
                % 计算每辆车的 SINR
                sinr = mean(cumulativeSINR(:, TransmissionCar(i)));

                % 使用 SINR 计算 CLRB_Range
                CLRB_Range(i) = CaculateCLRB_Range(sinr, phyParams.SCS_NR);
                %fprintf('第283行ttiCV2Xstarts：第%d辆车范围估计的CRLB=%0.7f m\n',TransmissionCar(i),CLRB_Range(i));
            end


            %CLRB_Velocity=CaculateCLRB_Velocity(SINR,phyParams.SCS_NR);
            fprintf('\n现在循环时刻:%0.5f\n',timeManagement.timeNow);
     
%             currentDateTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
%             disp(['当前运行时刻是：', char(currentDateTime)]);
            
            % 将计算得到的结果添加到数组中
            CRLB_Range_Array = [CRLB_Range_Array, CLRB_Range];

            %fprintf('第283行ttiCV2Xstarts：第1辆车速度估计的CRLB=%0.7f\n', CLRB_Velocity);
            %%%%%%%%%%
   
            % DEBUG IMAGE
            % if isfield(stationManagement,'IDvehicleTXLTE') && ~isempty(stationManagement.transmittingIDsLTE)
            %     printDebugImage('LTE subframe ends',timeManagement,stationManagement,positionManagement,simParams,simValues);
            % end
        end
     
    % CASE A: new packet is generated
    elseif abs(timeEvent-timeManagement.timeNextPacket(idEvent))<1e-8   % timeEvent == timeManagement.timeNextPacket(idEvent)

           printDebugReallocation(timeEvent,idEvent,positionManagement.XvehicleReal(indexEvent),'gen',-1,outParams);

        if stationManagement.vehicleState(idEvent)==constants.V_STATE_LTE_TXRX % is LTE
            % DEBUG EVENTS
            %printDebugEvents(timeEvent,'New packet, LTE',idEvent);
       
            stationManagement.pckBuffer(idEvent) = stationManagement.pckBuffer(idEvent)+1;
            %% From version 6.2, the following corrects a bug
            % The buffer may include a packet that is being transmitted
            % If the buffer already includes a packet, this needs to be
            % checked at the end of this subframe
            % If this is not the case, the pckNextAttempt must be reset
            if stationManagement.pckBuffer(idEvent)<=1
                stationManagement.pckNextAttempt(idEvent) = 1; 
            end
            
            % DEBUG IMAGE
            %printDebugImage('New packet LTE',timeManagement,stationManagement,positionManagement,simParams,simValues);
        else % is not LTE
            % DEBUG EVENTS
            %printDebugEvents(timeEvent,'New packet, 11p',idEvent);
            
            % In the case of 11p, some processing is necessary
            [timeManagement,stationManagement,sinrManagement,outputValues] = ...
                newPacketIn11p(idEvent,indexEvent,outParams,simParams,positionManagement,...
                phyParams,timeManagement,stationManagement,sinrManagement,outputValues,appParams);

            % DEBUG TX-RX
            % printDebugTxRx(timeManagement.timeNow,idEvent,'11p packet generated',stationManagement,sinrManagement,outParams);
            % printDebugBackoff11p(timeManagement.timeNow,'11p backoff started',idEvent,stationManagement,outParams)

            % DEBUG IMAGE
            %printDebugImage('New packet 11p',timeManagement,stationManagement,positionManagement,simParams,simValues);
        end

        % printDebugGeneration(timeManagement,idEvent,positionManagement,outParams);
        
        % from version 5.6.2 the 3GPP aperiodic generation is also supported. The generation interval is now composed of a
        % deterministic part and a random part. The random component is active only when enabled.
        generationInterval = timeManagement.generationIntervalDeterministicPart(idEvent) + exprnd(appParams.generationIntervalAverageRandomPart);
        if generationInterval >= timeManagement.dcc_minInterval(idEvent)
            timeManagement.timeNextPacket(idEvent) = round(timeManagement.timeNow + generationInterval, 10);
        else
            timeManagement.timeNextPacket(idEvent) = round(timeManagement.timeNow + timeManagement.dcc_minInterval(idEvent), 10);
            if ismember(idEvent, stationManagement.activeIDs11p)
                stationManagement.dcc11pTriggered(stationManagement.vehicleChannel(idEvent)) = true;
            elseif ismember(idEvent, stationManagement.activeIDsCV2X)
                stationManagement.dccLteTriggered(stationManagement.vehicleChannel(idEvent)) = true;
            end
        end
        
        timeManagement.timeLastPacket(idEvent) = timeManagement.timeNow-timeManagement.addedToGenerationTime(idEvent);
        
        if simParams.technology==constants.TECH_COEX_STD_INTERF && simParams.coexMethod==constants.COEX_METHOD_A && simParams.coexA_improvements>0
            timeManagement = coexistenceImprovements(timeManagement,idEvent,stationManagement,simParams,phyParams);
        end                
         
        % CASE B+C: either a backoff or a transmission concludes
    else % txrxevent-11p
        % A backoff ends
        if stationManagement.vehicleState(idEvent)==constants.V_STATE_11P_BACKOFF % END backoff
            % DEBUG EVENTS
            %printDebugEvents(timeEvent,'backoff concluded, tx start',idEvent);
            
            [timeManagement,stationManagement,sinrManagement,outputValues] = ...
                endOfBackoff11p(idEvent,indexEvent,simParams,simValues,phyParams,timeManagement,stationManagement,sinrManagement,appParams,outParams,outputValues);

            % DEBUG TX-RX
            % printDebugTxRx(timeManagement.timeNow,idEvent,'11p Tx started',stationManagement,sinrManagement,outParams);
            % printDebugBackoff11p(timeManagement.timeNow,'11p tx started',idEvent,stationManagement,outParams)
 
            % DEBUG TX
            % printDebugTx(timeManagement.timeNow,true,idEvent,stationManagement,positionManagement,sinrManagement,outParams,phyParams);
            
            % DEBUG IMAGE
            %printDebugImage('11p TX starts',timeManagement,stationManagement,positionManagement,simParams,simValues);
 
            % A transmission ends
        elseif stationManagement.vehicleState(idEvent)==constants.V_STATE_11P_TX % END tx
            % DEBUG EVENTS
            %printDebugEvents(timeEvent,'Tx concluded',idEvent);
            
            [simValues,outputValues,timeManagement,stationManagement,sinrManagement] = ...
                endOfTransmission11p(idEvent,indexEvent,positionManagement,phyParams,outParams,simParams,simValues,outputValues,timeManagement,stationManagement,sinrManagement,appParams);

            % DEBUG IMAGE
            %printDebugImage('11p TX ends',timeManagement,stationManagement,positionManagement,simParams,simValues);

            % DEBUG TX-RX
            % printDebugTxRx(timeManagement.timeNow,idEvent,'11p Tx ended',stationManagement,sinrManagement,outParams);
            % printDebugBackoff11p(timeManagement.timeNow,'11p tx ended',idEvent,stationManagement,outParams)

        else
            fprintf('idEvent=%d, state=%d\n',idEvent,stationManagement.vehicleState(idEvent));
            error('Ends unknown event...')
        end
    end
    
    % The next event is selected as the minimum of all values in 'timeNextPacket'
    % and 'timeNextTxRx'
    timeManagement.timeNextEvent = min(timeManagement.timeNextPacket,timeManagement.timeNextTxRx11p);
    if min(timeManagement.timeNextEvent(stationManagement.activeIDs)) < timeManagement.timeNow-1e-8 % error check
        format long
        fprintf('next=%f, now=%f\n',min(timeManagement.timeNextEvent(stationManagement.activeIDs)),timeManagement.timeNow);
        error('An event is schedule in the past...');
    end
    
end
%%%%

% 假设要保存的数组变量名为array_to_save
% 假设您要将数组变量的值保存到名为"data.xlsx"的Excel文件中的Sheet1中
filename = 'data.xlsx';

% 将数组变量值写入Excel文件
writematrix(sqrt(CRLB_Range_FilterSum)', filename, 'Sheet', 4);
%%%%

%fprintf('\n ROOT_CRLB_Range_Array:%0.7f m\n',ROOT_CRLB_Range_Array);
% result = mean(ROOT_CRLB_Range_Array(2:end));
% fprintf('\n 10m时的ROOT_CRLB：%0.7f\n',result);
% 找到数组的众数
mode_value = mode(sqrt(CRLB_Range_FilterSum));

fprintf('\n 更新的root 95percent CRLB:%0.4f m\n', mode_value);
%disp('\n 10m时候的ROOTCRLB：%0.7f\n',result);
% Print end of simulation
msg = sprintf('%.1f / %.1fs',simParams.simulationTime,simParams.simulationTime);
fprintf([reverseStr, msg]);

% Number of position updates
simValues.snapshots = positionManagement.NposUpdates;

% Stop stopwatch
outputValues.computationTime = toc;

end
