function   plotCIRMeas(sysPar,data);
%PLOTCIR Display CIR (channel impulse response) of selected BSs.
%hcfr_esti : nSC * nRx * nTx * nRSslot * nRr * nTr
%% =============================%%
nRr = sysPar.nRr; 
nTr = sysPar.nTr;
[~,~,~,nRSslot,~,~] = size(data.hcfr_esti);
%%==============================%%
for iTr = 1 : nTr
    figure;
    for iRr = 1 : nRr
        CIR = ifft( data.hcfr_esti(:,1,1,:,iRr,iTr), 4096, 1 );
        CIR_amp =  abs( squeeze( CIR((1:100), 1,1, (1 : nRSslot ) ) ) );
        CIR_amp =  permute( CIR_amp, [2 1]);
        CIR_lgamp = 20 * log10(CIR_amp'); 
        subplot(nRr, 1, iRr );
        [x1, y1] = meshgrid((0 : length( CIR_lgamp(:, 1) ) -1), (1 : nRSslot) );
        hp=stem3(x1, y1, CIR_lgamp','.','LineWidth',1.5,'Marker','none');
        set(hp,'BaseValue',min(min(CIR_lgamp)));
        if sysPar.IndUplink 
            title(['Measured CIR for ', num2str(iRr),' BS — ', num2str(iTr),' UE pair']);
        else
            title(['Measured CIR for ', num2str(iTr),' BS — ', num2str(iRr),' UE pair']);
        end
       xlabel('nSample');ylabel('nRSslot');zlabel('Amplitude / dB');
       set(gca,'FontName','Times New Roman','FontSize',10);
    end
end
end
