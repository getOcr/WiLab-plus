function plotbeam(sysPar,SelTxBeamAng,SelRxBeamAng,Unit);
%plotbeam Display formed beams at the transceivers.
if sysPar.IndUplink == false
    pf.plotpattern( sysPar.BSArraySize, SelTxBeamAng, sysPar.BSorientation,...
        sysPar.BSPos,Unit,0);
    pf.plotpattern(sysPar.UEArraySize, SelRxBeamAng, 0, sysPar.UEPos(:,1), Unit,0);
elseif sysPar.IndUplink == true
    pf.plotpattern(sysPar.BSArraySize, SelRxBeamAng, sysPar.BSorientation,...
        sysPar.BSPos,Unit,0);
    pf.plotpattern(sysPar.UEArraySize, SelTxBeamAng, 0,sysPar.UEPos(:,1),Unit,0);
end