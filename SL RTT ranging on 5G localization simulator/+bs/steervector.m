function out = steervector(ArraySize, azim, elev, d, lambda, num);
%steering vectors
% array is in yoz plane.
mzaxis = ( 0 :(ArraySize(1) -1) ).' -(ArraySize(1) -1) /2;
myaxis = ( 0 :(ArraySize(2) -1) ).' -(ArraySize(2) -1) /2;
switch num
    case 1 % UPA or ULA
        out = kron( exp(myaxis *1i *2 *pi *d *sin( azim ) *sin( elev ) ...
            /lambda), exp(mzaxis *1i *2 *pi *d * cos(elev) /lambda) );
end

end