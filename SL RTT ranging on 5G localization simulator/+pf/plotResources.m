function plotResources(sysPar, data);
%plotResources Plot SRS resouce grid.
%%================================%%
[K,L] = size( data.txGrid(:,:,1,1) );
figure;
imagesc(1:L,1:K,ceil(abs(data.txGrid(:,:,1,1))));
xlabel('OFDM symbol'); ylabel('Subcarrier'); axis xy;
title(['Transmitted ',(sysPar.SignalType),' for port 1']);
end

