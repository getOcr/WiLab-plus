function plotSysLayout(sysPar,Layout, data);
%PLOTSYSLAYOUT Plot system layout
 
pf.plotLayout(sysPar, data);
if sysPar.BeamSweep
    pf.plotbeam(sysPar, data.SelTxBeamAng, data.SelRxBeamAng, 'dB');
end
pf.plotnodesArrays( Layout );
end