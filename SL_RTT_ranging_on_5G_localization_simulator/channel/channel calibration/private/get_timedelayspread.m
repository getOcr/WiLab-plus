function sigma_DS = get_timedelayspread(timedelay, P_n);
%get_timedelayspread Generate RMS delay spread.

delay_mean = sum( timedelay .* P_n, 'all' ) / sum( P_n );
sigma_DS = sqrt( sum( (timedelay - delay_mean).^2 .* P_n ,'all' ) ...
    / sum( P_n) );
end