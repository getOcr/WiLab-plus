function out = get_cro_cor_coeff(x,y);
%get_cro_cor_coeff Calculate cross-correlation coefficients between x and y.
if isreal(x) && isreal(y)
out = ( mean(x.*y)-mean(x) .* mean(y) ) ./sqrt(mean(x.^2) -mean(x).^2) ...
     ./sqrt(mean(y.^2) -mean(y).^2);
else
    out = abs(( mean(x.*conj(y)) -mean(x) .* conj(mean(y)) )./ ...
        sqrt( mean(x .* conj(x) ) - mean(x).*conj(mean(x)) ) ./...
        sqrt( mean(y .* conj(y) ) - mean(y).*conj(mean(y)) ));
end

