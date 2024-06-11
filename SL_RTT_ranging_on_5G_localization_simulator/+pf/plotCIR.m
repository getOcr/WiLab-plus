function   plotCIR(sysPar,data);
%PLOTCIR Display CIR (channel impulse response) of selected BS-UE links.
%% =============================%%
nTr = sysPar.nTr;
nRr = sysPar.nRr;
[~,~,~,nslot] = size( data.CIR_cell{1, 1} );
%%==============================%%
for iTr = 1 : nTr
    figure;
    for iRr = 1 : nRr
        CIR = data.CIR_cell{iRr, iTr};% nDelayx * nTx * nRx * nSRSslot
        CIR_amp = abs( squeeze( CIR(:, 1,1, (1 : nslot ) ) ) );
        CIR_amp = permute( CIR_amp, [2 1] );
        CIR_lgamp = 20 * log10( CIR_amp' );
        subplot( nRr, 1, iRr );
        [x1, y1] = meshgrid( (0 : length( CIR_lgamp(:, 1) ) -1), (1 : nslot) );
        hp = stem3( x1, y1, CIR_lgamp', '.', 'LineWidth', 1.5, 'Marker', 'none');
        set(hp, 'BaseValue', min( min( CIR_lgamp ) ) );
        if sysPar.IndUplink
            title(['CIR for ', num2str(iRr),' BS — ', num2str(iTr),' UE pair']);
        else
            title(['CIR for ', num2str(iTr),' BS — ', num2str(iRr),' UE pair']);
        end
        xlabel('nSample');ylabel('nSRSslot');zlabel('Amplitude / dB');
        set(gca,'FontName','Times New Roman','FontSize',10);
    end
end
end
