function out = modulationmapper(sigstyle,bits);
%modulationmapper Perform complex-valued modulation mapping for OFDM symbols.
%
% DESCRIPTION
%	This function aims to perform modulation mapper, taking binary digits,
%   0 or 1, as input and producing complex-valued modulation symbols as
%   output following TS 38.211 clause 5.1.
%
%   Developer: Jia. Institution: PML. Date: 2021/08/13

checkbits(bits);
Mbit = length(bits);
switch sigstyle
    case 'QPSK' 
        i = 0 : floor( Mbit /2 ) -1;
        out = 1 /sqrt(2) *(1 -2 *bits( 2 *i +1) ) ...
            +1i *(1 -2 *bits( 2 *i +1 +1) );
    otherwise
        error('Supports QPSK modulation only. ');
end
end

function checkbits(bits);
if any( (bits~=0 & bits~=1)~=0)
    error('The value of bits must be 0 or 1. ');
end
end