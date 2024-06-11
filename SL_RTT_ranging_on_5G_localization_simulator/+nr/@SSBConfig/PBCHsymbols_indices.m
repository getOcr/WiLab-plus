function [symbols, indices] = PBCHsymbols_indices(ssb)
%PBCHsymbols_indices Generate the PBCH symbols and indices.
%
% Description:
%   This function aims to generate PBCH symbols in the resource grid
%   according to 3GPP TS38.211 v16.4.0 clause 7.3.3.
%
%	Developer: Jia. Institution: PML. Date: 2021/08/13

% Symbols
bits = ssb.PBCHbits; % in column;
Mbits = length( bits ); % largest number is 865
v = ssb.i_ssb;
c = nr.get_sequence( ssb.N_cellID, Mbits + v *Mbits );
b_tilde = mod( ( bits + c( v *Mbits +1 : Mbits + v *Mbits ) ) , 2 );
symbols_t = nr.modulationmapper( 'QPSK', b_tilde );
symbols = zeros( 432, 1);
symbols( 1 :length( symbols_t ), 1 ) = 10^( ssb.beta_pbch /10 ) * symbols_t;

% Indices                 
v = mod( ssb.N_cellID, 4 );
DMRSind = [ ( ( 1 :4 :237 ) +v +240 ), ( (1 :4 :45 ) +v +2 *240 ), ...
    ( ( 193 :4 :237 ) +v +2 *240 ), ( ( 1 :4 :237 ) +v +3 *240 ) ].';
indices = [ ( 240 +( 1 :240 ) ), ( 2 *240 +(1 :48 ) ), (2 *240 +(193 :240 ) ),...
    ( 3 *240 +(1 :240 ) ) ].';
for i = 1 : 144
    indices( indices == DMRSind(i) ) = [];
end