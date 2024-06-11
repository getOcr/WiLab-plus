function out = get_nSamPerSlot(islot,carrier,RSPeriod)
%get_nSamPerSlot Generate sample number of a slot.
islotsf = mod(RSPeriod * islot, carrier.SlotsPerSubframe);
out = sum( carrier.NSa( islotsf * carrier.SymbolsPerSlot ...
    + (1: carrier.SymbolsPerSlot) ));
end