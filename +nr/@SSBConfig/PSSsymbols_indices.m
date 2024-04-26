function [symbols, indices] = PSSsymbols_indices(ssb)
%PSSsymbols_indices Generate the PSS symbols and indices.
%
% Description:
%   This function aims to generate PSS symbols in the resource grid.
%   according to 3GPP TS38.211 v16.4.0 clause 7.4.2.2.
%
%	Developer: Jia. Institution: PML. Date: 2021/08/13

% PSS symbols
x = zeros(127, 1);
x(1:7) = [0 1 1 0 1 1 1];
for i = 1 : 120
    x(i +7 ) = mod( x( i +4 ) + x(i), 2 );
end
n = (1 : 127);
symbols = 10^( ssb.beta_pss /10 ) * ( 1 -2 *x( mod( ( n +43 * ssb.N_ID2 ),...
    127 ) +1 ) );

% PSS indices
indices = (57:183).';