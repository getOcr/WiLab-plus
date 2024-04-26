function [symbols, indices] = PRSsymbols_indices(prs,carrier)
%PRSsymbols_indices Generate the PRS symbols and indices.
%
% Description:
%   This function aims to generate PRS symbols in the resource grid.
%   according to 3GPP TS38.211 clause 7.4.1.7.
%
%	Developer: Jia. Institution: PML. Date: 2021/08/12

NsymPerSlot = carrier.SymbolsPerSlot;
SlotsPerFrame = carrier.SlotsPerFrame;

if any( mod( ( SlotsPerFrame * prs.Nframe + prs.nslot - prs.Periodset(2) - ...
        prs.T_offset_res ), prs.Periodset(1) ) == (0:prs.T_rep-1) * prs.T_gap );
    symbols = [];
    indices = [];
    for l = prs.L_start : prs.L_start + prs.L_prs -1
        c_init = mod( ( 2^22 *floor( prs.nPRSID /1024) + 2^10 *...
            ( NsymPerSlot * prs.nslot +l +1) * ( 2 * mod( prs.nPRSID, 1024 )...
            +1) + mod( prs.nPRSID, 1024 ) ), 2^31 );
        c_seq = nr.get_sequence( c_init, 2 *12 *prs.NumRB +2 );
        
        switch prs.KTC
            case 2
                k_prime = prs.k_prime_table( 1, (l - prs.L_start +1) );
            case 4
                k_prime = prs.k_prime_table( 2, (l - prs.L_start +1) );
            case 6
                k_prime = prs.k_prime_table( 3, (l - prs.L_start +1) );
            case 12
                k_prime = prs.k_prime_table( 4, (l - prs.L_start +1) );
        end
        symbols_k = [];
        indices_k = [];
        for m = 0 : 12 *prs.NumRB /prs.KTC -1
            k = m * prs.KTC + mod( prs.K_offset + k_prime, prs.KTC );
            Rseq = 1 /sqrt(2) * ( 1 -2 * c_seq(2 *m +1 ) ) + 1i *1 /sqrt(2)...
                * ( 1 -2 *c_seq( 2 *m +2 ) );
            symbols_sgl = ( 10^( prs.beta_prs /10 ) ) * Rseq;
            symbols_k = cat( 1 ,symbols_k, symbols_sgl );
            indices_sgl = k +l * prs.NumRB *12 +1;
            indices_k = cat( 1, indices_k, indices_sgl );
        end
        symbols = cat( 2, symbols, symbols_k);
        indices = cat( 2, indices, indices_k);
    end
    if ~isempty( prs.bitmap1 )
        ind1 = mod( floor( ( SlotsPerFrame * prs.Nframe + prs.nslot ...
            - prs.Periodset(2) - prs.T_offset_res ) / ( prs.T_muting * ...
            prs.Periodset(1) ) ), prs.L );
        if prs.bitmap1( ind1 +1 ) == 1
            symbols = zeros( size( symbols ) );
        end
    end
    
    if ~isempty( prs.bitmap2 )
        ind2 = mod( floor( mod( ( SlotsPerFrame * prs.Nframe + prs.nslot ...
            - prs.Periodset(2) - prs.T_offset_res ), prs.Periodset(1) ) /...
            prs.T_gap), prs.T_rep );
        if prs.bitmap2(ind2+1) == 1
            symbols = zeros( size( symbols ) );
        end
    end
else
    symbols = [];
    indices = [];
end

end