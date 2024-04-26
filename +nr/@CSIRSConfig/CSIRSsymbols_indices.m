function [symbols, indices] = CSIRSsymbols_indices(csirs,carrier)
%CSIRSsymbols_indices Generate the CSIRS symbols and indices.
%
% Description:
%   This function aims to generate CSIRS symbols in the resource grid.
%   according to 3GPP TS38.211 v16.4.0 clause 7.4.1.5.
%
%	Developer: Jia. Institution: PML. Date: 2021/08/11

NsymPerSlot = carrier.SymbolsPerSlot;
SlotsPerFrame = carrier.SlotsPerFrame;

if mod( ( SlotsPerFrame * csirs.Nframe + csirs.nslot - csirs.Periodset(2) ), ...
        csirs.Periodset(1) ) == 0;
    if csirs.Nports == 1
        alpha =  csirs.density;
    else
        alpha = 2 * csirs.density;
    end
    L = size( csirs.wf, 1);
    symbols = [];
    indices = [];
    p = zeros( 1, csirs.Nports);
    ptemp = 0;
    for j_ind = 0 : length( csirs.j_gpind ) -1
        j = csirs.j_gpind( j_ind +1);
        for s = 0 : L -1
            if ~( csirs.Row == 1)
                ptemp = ptemp +1;
            else
                ptemp = 1;
            end
            p(ptemp) = 3000 + s + j * L;
            for l_prime = csirs.L_prime
                l = csirs.L_bar( j_ind +1) + l_prime;
                c_init = mod( 2^10 *( carrier.SymbolsPerSlot * csirs.nslot ...
                    +l +1) *( 2 * csirs.n_ID +1 ) + csirs.n_ID, 2^31 );
                M_pn = floor( csirs.NumRB * alpha) + 1 + ...
                    floor( 11 * csirs.density /12 );
                refseq = nr.get_sequence( c_init, 2 *M_pn +2) ;
                for n = 0 : csirs.NumRB -1
                    for k_prime = csirs.K_prime
                        k = n * 12 + csirs.K_bar( j_ind +1) + k_prime;
                        m_prime = floor( n * alpha) + k_prime + floor( ...
                            csirs.K_bar( j_ind +1) * csirs.density /12 );
                        rseq = 1 /sqrt(2) *(1 -2 * refseq( 2 *m_prime +1) )...
                            +1i *1/ sqrt(2) *(1 -2 * refseq( 2 *m_prime +2 ) );
                        symbols_sgl = ( 10^( csirs.beta_csirs /10 ) ) * ...
                            csirs.wf(s +1, k_prime +1) * csirs.wt(s +1, ...
                            l_prime +1) * rseq;
                        symbols = cat( 1, symbols, symbols_sgl);
                        indices_sgl = k +l * csirs.NumRB *12 + ( ptemp -1) * ...
                            csirs.NumRB *12 * NsymPerSlot +1;
                        indices = cat(1, indices, indices_sgl);
                    end
                end
            end
        end
    end
    if strcmp( csirs.ResType, 'ZeroPower')
        symbols = zeros( size( symbols ) );
    end
else
    symbols = [];
    indices = [];
end

end