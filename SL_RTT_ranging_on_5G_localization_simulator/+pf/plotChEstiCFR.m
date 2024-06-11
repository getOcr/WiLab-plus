function plotChEstiCFR(sysPar,data);
%PLOTCHESTICFR Plot estimated Channel Frequency Reponse of selected BSs.
%  hcfr_esti %   nSC * nRx * nTx * nRSslot * nRr * nTr
%%================================%%
nRr = sysPar.nRr; 
nTr = sysPar.nTr;
[nSC,~,~,nRSslot,~,~] = size(data.hcfr_esti);
for iTr = 1 : nTr
figure;
for iRr = 1 : nRr
    subplot( nRr,1,iRr);
    htot =squeeze( data.hcfr_esti(:,1,1,:,iRr ,iTr));   
    htot(htot==0)=[];
    htot = reshape(htot,[],nRSslot);
    imagesc(abs(htot), 'AlphaData',~isnan(htot) )
    axis xy; xlabel('RS slot'); ylabel('Subcarrier');
    set(gca,'xtick',(1 : nRSslot) );set(gca,'xticklabel',(1:nRSslot));
    colorbar;
    if sysPar.IndUplink
        title(['Estimated CFR for ', num2str(iRr),' BS — ', num2str(iTr),...
            ' UE pair']);
    else
        title(['Estimated CFR for ', num2str(iTr),' BS — ', num2str(iRr),...
            ' UE pair']);
    end
end
end