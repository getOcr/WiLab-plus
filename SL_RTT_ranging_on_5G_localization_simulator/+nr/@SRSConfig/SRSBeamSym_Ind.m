function [symbols,indices] = SRSBeamSym_Ind( srs, carrier, nBeam);
%SRSBeamSym_Ind Generate the SRS symbols and indices with beamforming.

symbols =[];
indices =[];
for iBeam = 1 : nBeam
    srs.L_0(1) = iBeam -1;
    rsIndices_s = SRSindices( srs,carrier );
    rsSymbols_s = SRSsymbols( srs,carrier );
    symbols = cat(2, symbols, rsSymbols_s );
    indices = cat(2, indices, rsIndices_s );
end
end

