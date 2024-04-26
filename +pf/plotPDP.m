function  plotPDP(sysPar,data);
%PLOTPDP  Display PDP (Power-Delay Profile) of selected BSs
% Note: the delay per path is approximate according to the time-sampling
% resolution.
%% ===========================%%
nTx = sysPar.nTx;
nRx = sysPar.nRx;
nBS =sysPar.nBS;
nUE =sysPar.nUE;
nRSslot = sysPar.nRSslot;
hcoef = data.hcoef;
%% =========generate CIR============%
for iUE = 1 : nUE
    PDP_cell = cell(nBS, 1);
    for iBS = 1 : nBS
        PathCoeff = permute( hcoef(iBS, iUE).H, [1 3 2 4]); 
        %nP * nTx * nRx * nRSslot
        PathDelay = hcoef(iBS, iUE).timedelay;
        if size(PathDelay,2) == 1
            PathDelay = repmat(PathDelay, 1, nRSslot); % nP * nRSslot
        end
        nDelayx = max( max( round( PathDelay * 1e11) +1) );
        PDP_temp = zeros(nDelayx, nTx, nRx, nRSslot);
        for islot = 1 : nRSslot
            idx_Chn = round( PathDelay(:, islot)  * 1e11) +1 ;
            for iP = 1 : length(idx_Chn)
                PDP_temp( idx_Chn(iP) ,:,:, islot) = ...
                    PDP_temp(idx_Chn(iP) ,:,:, islot) + PathCoeff(iP, :,:, islot);
            end
        end
        PDP_cell{iBS, 1} = PDP_temp;   % nDelayx * nTx * nRx * nSRSslot
    end
    %% ==========plot figure==============%
    figure;
    for iBS = 1 : nBS
        PDP = PDP_cell{iBS, 1};              % nDelayx * nTx * nRx * nSRSslot
        PDP_temp =  abs( squeeze( PDP(:,1,1,(1 : nRSslot) ) ) ) .^2 * 1000;
        PDP_temp =  permute(PDP_temp, [2 1]);
        PDP_lg = 10 * log10(PDP_temp);
        subplot(nBS, 1, iBS );
        [x1, y1] = meshgrid( (0:length(PDP_lg(1, :) )-1)/100,(1:nRSslot));
        hp=stem3(x1,y1,PDP_lg,'.','LineWidth',1.5,'Marker','none');
        set(hp,'BaseValue',min(min(PDP_lg)));
        if sysPar.IndUplink
            title(['Power-Delay Profile of ', num2str( iBS ),' BS — ', ...
                num2str( iUE ),' UE pair']);
        else
            title(['Power-Delay Profile of ', num2str( iUE ),' BS — ', ...
                num2str( iBS ),' UE pair']);
        end
        xlabel('Delay / ns');ylabel('nRSslot');zlabel('Power / dBm');
        set(gca,'FontName','Times New Roman','FontSize',10); 
    end
end
end
