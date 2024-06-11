function indices = SRSindices(srs,carrier)
%JSRSindices Generate the corresponding mapped indices for the SRS symbols.
%
% Description:
%   This function aims to generate SRS symbol indices in the resource grid
%   according to 3GPP TS38.211 v16.4.0 clause 6.4.1.4.
%
%	Developer: Jia. Institution: PML. Date: 2021/08/01  

Nsc_band = carrier.NSizeGrid * 12;
SymbolsPerSlot = carrier.SymbolsPerSlot;
SlotsPerFrame = carrier.SlotsPerFrame;
indices = zeros( srs.M_sc_b(srs.B_SRS +1), srs.N_symb, srs.N_ap);
if mod( ( carrier.SlotsPerFrame * srs.Nframe + srs.nslot - srs.Periodset(2) ), ...
        srs.Periodset(1) ) == 0
    for p = 0 : srs.N_ap-1
        if any( srs.N_cycshf == ( srs.N_cycshf_max /2 : srs.N_cycshf_max -1) ) && ...
                srs.N_ap == 4 && any( p == [1 3])
            KTC_p = mod( srs.KTC_offset + srs.KTC /2, srs.KTC);
        else
            KTC_p = srs.KTC_offset;
        end    
        for l1 = 0 : srs.N_symb -1  
            if strcmp( srs.ResType,'periodic')
                n_SRS = ( SlotsPerFrame * srs.Nframe + srs.nslot- ...
                    srs.Periodset(2) ) / srs.Periodset(1) * srs.N_symb / ...
                    srs.R_rf + floor( l1 / srs.R_rf );
            elseif strcmp( srs.ResType, 'aperiodic')
                n_SRS = floor( l1 / srs.R_rf );
            end
            if srs.b_hop >= srs.B_SRS
                n_b = mod( floor( srs.n_RRC *4 ./ srs.m_srs_b), srs.N_b );  %column
            else
                for b = 0 : srs.b_hop
                    n_b( b +1, 1) = mod( floor( srs.n_RRC * 4./ ...
                        srs.m_srs_b( b +1) ), srs.N_b(b +1));
                end
                for b = (srs.b_hop+1) : srs.B_SRS
                    if mod( srs.N_b( b +1), 2) == 0
                        Fb_n_SRS = srs.N_b( b+1) /2 *floor( mod( n_SRS, ...
                            prod(srs.N_b( srs.b_hop +1 : b +1 ) )  ) / ...
                            prod(srs.N_b( srs.b_hop +1 : b) ) ) ...
                            +floor( mod(n_SRS, prod( srs.N_b( srs.b_hop +1: b +1) ) ) ...
                            / 2/ prod( srs.N_b( srs.b_hop +1 : b ) ) );
                    elseif mod( srs.N_b(b +1), 2) == 1
                        Fb_n_SRS = floor( srs.N_b(b +1) /2 ) * ...
                            floor( n_SRS / prod( srs.N_b( srs.b_hop +1 : b) ) );                     
                    end
                    n_b(b+1,1) = mod( Fb_n_SRS + floor( srs.n_RRC * 4./ ...
                        srs.m_srs_b( b +1) ), srs.N_b( b +1) );
                end
            end
            
            k_offset_p  = srs.n_shift *12 + mod( KTC_p + srs.K_offset( l1 +1), srs.KTC);
            k0_p = k_offset_p + sum(srs.KTC * srs.m_srs_b .* n_b);
            indices(:, l1+1, p+1) = 1+ k0_p + srs.KTC * ...
                (0 : srs.M_sc_b( srs.B_SRS +1) -1).' + Nsc_band * ...
                (srs.L_0 +l1) + Nsc_band * SymbolsPerSlot * p;
        end
    end
else
    indices = [];
end
end