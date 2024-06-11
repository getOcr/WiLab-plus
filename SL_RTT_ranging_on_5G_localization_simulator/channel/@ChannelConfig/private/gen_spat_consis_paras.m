function [para_TC] = gen_spat_consis_paras( v_tx_bar, v_rx_bar, phi_AOD_n,...
    phi_AOA_n, theta_EOD_n, theta_EOA_n, ncluster, nsnap, c, del_t, Dis3, ...
    tau_n_prime, r_tau, ksi, DS, C_r, Ind_LOS, norsm, unism, ...
    rd_var_ata)
%gen_spat_consis_paras Generate segment-based small scale parameters.
%
% Description:
% Generate small scale parameters according to the segment-based simulations
% in 3GPP TR 38.901 v16.1.0 2019 -- clause 7.6.3 procedure A.
% Spatial consistent mobility modelling (powers, delays, and angles)
% according to TR38.901 clause 7.6.3.2.
%
% Note: this function supports segment-based simulation while long range
% evolution has not been considered.
%
% Developer: Jia. Institution: PML. Date: 2021/10/28

% Initial of delay
tau_n_t_tilde = zeros( ncluster, nsnap); % dim: n * nsnap
tau_n = tau_n_prime - min( tau_n_prime );
if Ind_LOS
    tau_n_t_tilde(:,1) = tau_n + Dis3/c;
elseif ~logical(rd_var_ata)
    % L should be the largest dim of the InF, i.e., L = max(length, width,
    % height).
    L = 200; % by default
    tau_n_t_tilde(:,1) = tau_n + min(10^( rd_var_ata * 0.4 - 7.5 ) ,L)...
        + Dis3/c;
else
    tau_n_t_tilde(:,1) = tau_n_prime / C_r + Dis3/c;
end

% Initial of cluster powers
% Normalized tau_n used for power generation
P_nt = zeros( ncluster, nsnap );
tau_n1 = ( tau_n_t_tilde(:,1) - min( tau_n_t_tilde(:,1) ) ) * C_r;
Z_n = randn(norsm, ncluster, 1) * ksi /10;
P_prime = exp( - tau_n1 * (r_tau -1)/(r_tau * DS) ) .* ...
    10.^( -( Z_n /10 ) );
P_nt(:,1) = P_prime / sum( P_prime );
% Initial of angles
phi_AOD_nt = zeros(ncluster, nsnap);
phi_AOA_nt = zeros(ncluster, nsnap);
theta_EOD_nt = zeros(ncluster, nsnap);
theta_EOA_nt = zeros(ncluster, nsnap);
phi_AOD_nt(:,1) = phi_AOD_n * pi /180;
phi_AOA_nt(:,1) = phi_AOA_n * pi /180;
theta_EOD_nt(:,1) = theta_EOD_n * pi /180;
theta_EOA_nt(:,1) = theta_EOA_n * pi /180;
% Initial of v_n_tx_bar_pri and v_n_rx_bar_pri
if Ind_LOS
    v_n_rx_temp = v_rx_bar - v_tx_bar;
    v_n_tx_temp = v_tx_bar - v_rx_bar;
    v_n_rx_bar_pri = permute( repmat(v_n_rx_temp, 1, 1, ncluster), [1 3 2] );
    v_n_tx_bar_pri = permute( repmat(v_n_tx_temp, 1, 1, ncluster), [1 3 2] );
else
    X_n = (rand(unism, ncluster, 1) < 0.5) *2 -1;
    % 60 15 50 10 for RMa, UMi, UMa, and Indoor, respectively.
    v_n_rx_bar_pri = zeros(3, ncluster, nsnap);
    v_n_tx_bar_pri = zeros(3, ncluster, nsnap);
    R_n_rx = func_R_n_rx( X_n, phi_AOD_n, phi_AOA_n, ...
        theta_EOA_n, theta_EOD_n );
    R_n_tx = func_R_n_tx( X_n, phi_AOD_n, phi_AOA_n, ...
        theta_EOA_n, theta_EOD_n );
    for n = 1 : ncluster
        v_n_rx_bar_pri(:,n,1) = R_n_rx(:,:,n) *v_rx_bar(:,1) -v_tx_bar(:,1);
        v_n_tx_bar_pri(:,n,1) = R_n_tx(:,:,n) *v_tx_bar(:,1) -v_rx_bar(:,1);
    end
end
for it = 2 : nsnap
    % departure and arrival angles calc in radians
    phi_AOD_nt(:,it) = phi_AOD_nt(:,it-1) + reshape( sum( v_n_rx_bar_pri(:,:,it-1) ...
        .* UniVec_phi_hat( phi_AOD_nt(:, it-1) ),1 ), ncluster, 1) ./ ...
        ( c* tau_n_t_tilde(:, it-1) .* sin( theta_EOD_nt(:, it-1) ) ) * del_t;
    phi_AOA_nt(:,it) = phi_AOA_nt(:,it-1) + reshape( sum( v_n_tx_bar_pri(:,:,it-1) ...
        .* UniVec_phi_hat( phi_AOA_nt(:, it-1) ),1 ),ncluster, 1)./ ...
        ( c* tau_n_t_tilde(:,it-1) .* sin( theta_EOA_nt(:,it-1) ) ) * del_t;
    theta_EOD_nt(:,it) = theta_EOD_nt(:,it-1) + reshape( sum( v_n_rx_bar_pri(:,:,it-1) ...
        .* UniVec_theta_hat( theta_EOD_nt(:,it-1), phi_AOD_nt(:,it-1) ),1 ), ncluster, 1)...
        ./ ( c* tau_n_t_tilde(:, it-1) ) * del_t;
    theta_EOA_nt(:,it) = theta_EOA_nt(:,it-1) + reshape( sum( v_n_tx_bar_pri(:,:,it-1) ...
        .* UniVec_theta_hat( theta_EOA_nt(:,it-1), phi_AOA_nt(:,it-1) ),1 ), ncluster, 1)./ ...
        ( c* tau_n_t_tilde(:, it-1) ) * del_t;
    % v_n_tx_bar_pri and v_n_rx_bar_pri calc
    if ~Ind_LOS
        R_n_rx = func_R_n_rx( X_n, phi_AOD_nt(:,it), phi_AOA_nt(:,it), ...
            theta_EOA_nt(:,it), theta_EOD_nt(:,it) );
        R_n_tx = func_R_n_tx( X_n, phi_AOD_nt(:,it), phi_AOA_nt(:,it), ...
            theta_EOA_nt(:,it), theta_EOD_nt(:,it) );
        for n = 1 : ncluster
            v_n_rx_bar_pri(:,n,it) = R_n_rx(:,:,n) *v_rx_bar(:,it) -v_tx_bar(:,it);
            v_n_tx_bar_pri(:,n,it) = R_n_tx(:,:,n) *v_tx_bar(:,it) -v_rx_bar(:,it);
        end
    end
    % Clusters delay calc
    tau_n_t_tilde(:,it) = tau_n_t_tilde(:,it-1) - ...
        ( (func_r_n_hat( theta_EOA_nt(:,it-1), phi_AOA_nt(:,it-1) )).' * ...
        v_rx_bar(:,it-1) + (func_r_n_hat( theta_EOD_nt(:,it-1), ...
        phi_AOD_nt(:,it-1) )).' * v_tx_bar(:,it-1) ) /c * del_t;
    tau_nt = ( tau_n_t_tilde(:,it) - min( tau_n_t_tilde(:,it) ) ) * C_r;
    P_prime = exp( - tau_nt * (r_tau -1) / (r_tau * DS) ) .* ...
        10.^( -( Z_n /10 ) );
    P_nt(:,it) = P_prime / sum(P_prime);
end
para_TC.tau_n_t_tilde = tau_n_t_tilde;
para_TC.P_nt = P_nt;
para_TC.phi_AOD_nt = phi_AOD_nt /pi *180;
para_TC.phi_AOA_nt = phi_AOA_nt /pi *180;
para_TC.theta_EOD_nt = theta_EOD_nt /pi *180;
para_TC.theta_EOA_nt = theta_EOA_nt /pi *180;
end
%------------------------------------------------------------------
% sub-functions

function out = func_r_n_hat(theta_n,phi_n)
out(1,:) = sin(theta_n) .* cos(phi_n);
out(2,:) = sin(theta_n) .* sin(phi_n);
out(3,:) = cos(theta_n);
end

function out = UniVec_theta_hat(theta_n,phi_n)
% out = [cos(theta)*cos(phi) cos(theta)*sin(phi) -sin(theta)].';
out(1,:) = cos(theta_n) .* cos(phi_n);
out(2,:) = cos(theta_n) .* sin(phi_n);
out(3,:) = -sin(theta_n);
end

function out = UniVec_phi_hat(phi_n);
% out = [-sin(phi) cos(phi) 0].';
out(1,:) = -sin(phi_n);
out(2,:) = cos(phi_n);
out(3,:) = zeros(1,length(phi_n) );
end

function out = func_R_n_rx(X_n,phi_AOD_n,phi_AOA_n,theta_EOA_n,theta_EOD_n);
out = zeros( 3,3,length( phi_AOD_n(:,1) ) );
for n = 1 : length( phi_AOD_n(:,1) )
    out(:,:,n) = func_R_z(phi_AOD_n(n)+pi) * func_R_y( pi/2 - theta_EOD_n(n) ) ...
        * [1 0 0; 0 X_n(n) 0; 0 0 1] * ...
        func_R_y(pi/2 - theta_EOA_n(n)) * func_R_z( -phi_AOA_n(n) );
end
end

function out = func_R_n_tx(X_n,phi_AOD_n,phi_AOA_n,theta_EOA_n,theta_EOD_n);
out = zeros( 3,3,length( phi_AOD_n(:,1) ) );
for n = 1 : length( phi_AOD_n(:,1) )
    out(:,:,n) = func_R_z( -phi_AOD_n(n) ) * func_R_y( pi/2 - theta_EOD_n(n) ) * ...
        [1 0 0; 0 X_n(n) 0; 0 0 1] * ...
        func_R_y( pi/2 - theta_EOA_n(n) ) * func_R_z( pi + phi_AOA_n(n) );
end
end

function out = func_R_y(beta);
out = [cos(beta) 0 sin(beta); 0 1 0; -sin(beta) 0 cos(beta) ];
end

function out = func_R_z(alpha);
out = [cos(alpha) -sin(alpha) 0; sin(alpha) cos(alpha) 0; 0 0 1];
end
