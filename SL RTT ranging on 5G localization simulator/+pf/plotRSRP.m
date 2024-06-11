function plotRSRP(sysPar,data);
%plotRSRP display measured RSRP for beam sweeping
[nRxBeam,nTxBeam,nRr,nTr] = size(data.rsrp_dbm);
for iTr = 1 : nTr
    figure;
    for iRr = 1 : nRr
        subplot( nRr,1,iRr);
        if ~( nRxBeam >1 && nTxBeam >1 )
            nBeams = max(nRxBeam, nTxBeam);
            plot(data.rsrp_dbm(:,:,iRr,iTr));grid on;
            axis xy; xlabel('nBeams'); ylabel('RSRP / dBm');
            set(gca,'xtick',(1 : nBeams) );set(gca,'xticklabel',(1 : nBeams));
        else
            mesh(data.rsrp_dbm(:,:,iRr,iTr));grid on;colorbar;
            axis xy; xlabel('nRxBeams');ylabel('nTxBeams'); zlabel('RSRP / dBm');
            set(gca,'xtick',(1 : nRxBeam) );set(gca,'xticklabel',(1 : nRxBeam));
            set(gca,'ytick',(1 : nTxBeam) );set(gca,'yticklabel',(1 : nTxBeam));
        end
        if sysPar.IndUplink
            title(['Measured RSRP for ', num2str(iRr),' BS — ', ...
                num2str(iTr),' UE pair']);
        else
            title(['Measured RSRP for ', num2str(iTr),' BS — ', ...
                num2str(iRr),' UE pair']);
        end
    end
end