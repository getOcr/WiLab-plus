function [symbols, indices] = DMRS_PBCHsymbols_indices(ssb)
%DMRS_PBCHsymbols_indices Generate the DMRS( for PBCH ) symbols and indices.
%
% Description:
%   This function aims to generate DMRS( for PBCH ) symbols in resource grid
%   according to 3GPP TS38.211 v16.4.0 clause 7.4.1.4.
%
%	Developer: Jia. Institution: PML. Date: 2021/08/13

% Symbols
M_pn =144;
c_init = 2^11 * ( ssb.i_ssb_bar +1 ) * ( floor( ssb.N_cellID /4 ) +1 ) + ...
    2^6 * ( ssb.i_ssb_bar +1 ) + mod( ssb.N_cellID, 4 );
refseq = nr.get_sequence( c_init, 2 *M_pn +2 ) ;
symbols = 10^( ssb.beta_dmrs /10 ) * ( 1 / sqrt(2) * (1 -2 * refseq( 2 ...
    *M_pn +1) ) + 1i *1 / sqrt(2) * ( 1 -2 * refseq( 2 *M_pn +2 ) ) );

% Indices                 
v = mod( ssb.N_cellID, 4 );
indices = [ ( ( 1 :4 :237 ) +v +240 ), ( (1 :4 :45 ) +v +2 *240), ...
    ( ( 193 :4 :237 ) +v +2 *240 ), ( ( 1 :4 :237 ) +v +3 *240 ) ].';
end