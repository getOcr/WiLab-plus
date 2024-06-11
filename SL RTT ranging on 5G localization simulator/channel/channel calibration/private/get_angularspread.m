function sigma_AS = get_angularspread(theta_nm,P_n);
%get_angularspread Generate RMS angular spread according to 3GPP TR 25.996.

P_n_ray = P_n / 20;
tuple = [];
for del = 0 :pi/10 : 2*pi
    theta_nm_del = mod(theta_nm + del +pi,2*pi) -pi;
    mu_del = sum( theta_nm_del .* P_n_ray, 'all' ) / sum( P_n_ray * 20 );
    theta_nm_mu_del = mod(theta_nm_del - mu_del +pi,2*pi) -pi;
    sigma_AS_temp = sqrt(  sum( theta_nm_mu_del.^2 .* P_n_ray, 'all' ) / ...
        sum( P_n_ray * 20 ) );
    tuple = [tuple, sigma_AS_temp];
end
sigma_AS = min(tuple);

% generate AS according to TR 38.901 annex A.1.
% P_n_ray = P_n / 20;
% sigma_AS = sqrt(-2*log( abs( sum(exp(1i*theta_nm) .* P_n_ray,'all') ...
% /(sum(P_n_ray)*20) ) ) );
end