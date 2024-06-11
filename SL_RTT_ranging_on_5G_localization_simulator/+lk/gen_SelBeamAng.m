function [SelTxBeamAng, SelRxBeamAng] = gen_SelBeamAng(BeamSweep, rsrp);
%gen_SelBeamAng Calculate selected angles by comparing RSRP.
%
% Developer: Jia. Institution: PML. Date: 2021/08/06

[~,~, nRr, nTr]=size( rsrp );
SelRxBeamAng = zeros(2, nRr,nTr);
SelTxBeamAng = zeros(2, nRr,nTr);
for iTr = 1 : nTr
for iRr = 1 : nRr
% if nRxBeam > 1
    Pmax = max(rsrp(:,:, iRr, iTr),[], 'all');
    [IndRx, IndTx] = find( rsrp(:,:,iRr, iTr) == Pmax );
SelRxBeamAng(:,iRr, iTr) = BeamSweep.RxBeamAng(:, IndRx(1) );
SelTxBeamAng(:,iRr, iTr) = BeamSweep.TxBeamAng(:, IndTx(1) );
end
end