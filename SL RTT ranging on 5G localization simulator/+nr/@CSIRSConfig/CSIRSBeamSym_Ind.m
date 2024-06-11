function [symbols,indices] = CSIRSBeamSym_Ind( csirs, carrier, nBeam);
%CSIRSBeamSym_Ind Generate the CSIRS symbols and indices with beamforming.

symbols = [];
indices = [];
for iBeam = 1 : nBeam
    csirs.L0(1) = iBeam -1;
    [ rsSymbols_s, rsIndices_s] = CSIRSsymbols_indices( csirs, carrier);
    symbols = cat( 2, symbols, rsSymbols_s );
    indices = cat( 2, indices, rsIndices_s );
end
end

