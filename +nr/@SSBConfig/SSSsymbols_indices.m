function [symbols, indices] = SSSsymbols_indices(ssb)
%SSSsymbols_indices Generate the SSS symbols and indices.
%
% Description:
%   This function aims to generate SSS symbols in the resource grid.
%   according to 3GPP TS38.211 v16.4.0 clause 7.4.2.3.
%
%	Developer: Jia. Institution: PML. Date: 2021/08/13

% SSS symbols
x0 = zeros(127, 1);
x1 = zeros(127, 1);
x0(1:7) = [1 0 0 0 0 0 0];
x1(1:7) = [1 0 0 0 0 0 0];
for i = 1 : 120
   x0(i +7) = mod( x0(i +4) + x0(i), 2 );
   x1(i +7) = mod( x1(i +1) + x1(i), 2 );
end
m0 = 15 *floor( ssb.N_ID1 /112 ) +5 *ssb.N_ID2;
m1 = mod( ssb.N_ID1, 112);
n = 0:126;
symbols = 10^( ssb.beta_sss /10 ) * (1 -2 *x0( mod( n +m0, 127 ) +1 ) ) ...
    .* ( 1 -2 *x1( mod( n +m1, 127 ) +1 ) );

%SSS indices
indices = (57:183).' + 2 * 240;
end