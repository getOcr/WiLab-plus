function  plotPhaseDiff(sysPar,data);
%PLOTPHASEDIFF Plot interantenna phase difference.
%%================================%%
nTr = sysPar.nTr;
nRr = sysPar.nRr;
nRx = sysPar.nRx;
for iTr = 1 : nTr
    figure;
    for iRr = 1 : nRr
        hh= data.hcfr_esti(:,:,1,1,iRr,1);   
        hh(hh==0)=[];
        hh = reshape(hh,[],nRx);
        x1 = unwrap( angle( hh ) );
        x2 = x1-x1(:,1);
        subplot(2,nRr,iRr);  plot(x1,'LineWidth',1.2);  grid on;
        name  = strcat('Ant. ', num2str((1:nRx).'));
        hl=legend(name, 'Location','NorthEast');
        set(hl,'edgecolor','k','FontSize',11);
        if sysPar.IndUplink
            title([' Absolute Phase for ', num2str(iRr),' BS — ', ...
                num2str(iTr),' UE pair']);
        else
            title([' Absolute Phase for ', num2str(iTr),' BS — ',  ...
                num2str(iRr),' UE pair']);
        end
        ylabel('Phase');xlabel('Sub-Carrier Index');
        set(gca,'FontName','Times New Roman','FontSize',11);
        subplot(2,nRr,iRr +nRr);  plot(x2,'LineWidth',1.2); grid on;
        name2  = strcat('Ant.', num2str((1:nRx).'),'-1');
        hl2=legend(name2, 'Location','NorthEast');
        set(hl2,'edgecolor','k','FontSize',11);
        if sysPar.IndUplink
            title([' Relative Phase for ', num2str(iRr),' BS — ',  ...
                num2str(iTr),' UE pair']);
        else
            title([' Relative Phase for ', num2str(iTr),' BS — ',  ...
                num2str(iRr),' UE pair']);
        end
        xlabel('Sub-Carrier Index');ylabel('Phase Difference');
        set(gca,'FontName','Times New Roman','FontSize',11);
    end
end
end