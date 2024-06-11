function [H, timedelay_nt] = gen_link_H_delay_segment(ssp, BS_array, UE_array, ...
    Ind_LOS, gainloss_dB, lambda_0, v_scatter_max, nsnap, del_t, ...
    epsilon_GRdiv0, Ind_uplink, Ind_GR, Ind_gainloss, unism);
%gen_link_H_delay_segment Generate segment-based channel coefficients.
%
% Description:
% Generate channel coefficients according to the segment-based simulations in
% 3GPP TR 38.901 v16.1.0 2019 -- clause 7.6.3
% H: dim: ncluster  nRx nTx nsnap
% timedelay: dim: ncluster *nsnap
%
% Developer: Jia. Institution: PML. Date: 2021/10/28

%--------------------------------------------
% Paras align
ncluster = ssp.cluster.ncluster; nray = ssp.cluster.nray;
phi_AOD_nmt = ssp.ray.phi_AOD_nmt; phi_AOA_nmt = ssp.ray.phi_AOA_nmt;
theta_EOD_nmt = ssp.ray.theta_EOD_nmt; theta_EOA_nmt =  ssp.ray.theta_EOA_nmt;
tau_nt = ssp.cluster.tau_n_tilde; kappa_nmt = ssp.ray.kappa_nmt;
K_r = ssp.cluster.K_r; P_nt = ssp.cluster.P_nt; Ind_2BCls = ssp.cluster.Ind_2BCls;
Ind_weakCls = ssp.cluster.Ind_weakCls; tau_2stro = ssp.cluster.tau_2stro;
phi_LOS_AOD_t = ssp.bs.AOD_LOS_t; phi_LOS_AOA_t = ssp.bs.AOA_LOS_t;
theta_LOS_EOD_t = ssp.bs.EOD_LOS_t; theta_LOS_EOA_t = ssp.bs.EOA_LOS_t;
Dis3_t = ssp.bs.Dis3_t; Dis_GR_t = ssp.groundreflect.Dis_GR_t;
tau_GR_t = ssp.groundreflect.tau_GR_t; phi_GR_AOA_t = ssp.groundreflect.phi_GR_AOA_t;
phi_GR_AOD_t = ssp.groundreflect.phi_GR_AOD_t;
theta_GR_EOA_t = ssp.groundreflect.theta_GR_EOA_t;
theta_GR_EOD_t = ssp.groundreflect.theta_GR_EOD_t;
t = ( 0: ( nsnap-1 ) ).' * del_t;
if Ind_uplink
    tx_array = UE_array; rx_array = BS_array;
else
    rx_array = UE_array; tx_array = BS_array;
end
% Field pattern
nazim = length(rx_array.grid_azim);  nelev = length(rx_array.grid_elev);
F_rxth_u = reshape( rx_array.Fth, nelev, nazim, []);
F_rxph_u = reshape( rx_array.Fph, nelev, nazim, []);
F_txth_s = reshape( tx_array.Fth, nelev, nazim, []);
F_txph_s = reshape( tx_array.Fph, nelev, nazim, []);
v_rx_bar_t = ssp.bs.v_rx_bar_t;
v_tx_bar_t = ssp.bs.v_tx_bar_t;

% Location vec of antenna elem
% dim: 3 * nsnap * nTx
d_bar_tx_s = reshape( tx_array.position_ant, 3, 1, [] ) ...
    + ssp.bs.tx_positions_t;
% dim: 3 * nsnap * nRx
d_bar_rx_u = reshape( rx_array.position_ant, 3, 1, [] ) ...
    + ssp.bs.rx_positions_t;
% Receive and transmit antenna number
nRx = size( d_bar_rx_u, 3 ); % M * N * Mg * Ng * P 
nTx = size( d_bar_tx_s, 3 ); % M * N * Mg * Ng * P( * 3)

% Step10 Init random phases
Phi_nmt_thth = ssp.ray.Phi_nmt_thth;
Phi_nmt_phph = ssp.ray.Phi_nmt_phph;
Phi_nmt_thph = ssp.ray.Phi_nmt_thph;
Phi_nmt_phth = ssp.ray.Phi_nmt_phth;

% Spatial consistent simulation
% Spherical unit vectors
r_rx_nmt = [sin(theta_EOA_nmt(:) /180 * pi) .* cos(phi_AOA_nmt(:) /180 * pi),...
    sin(theta_EOA_nmt(:) /180 * pi) .* sin(phi_AOA_nmt(:) /180 * pi),...
    cos(theta_EOA_nmt(:) /180 * pi)].';
r_tx_nmt = [sin(theta_EOD_nmt(:) /180 * pi) .* cos(phi_AOD_nmt(:) /180 * pi),...
    sin(theta_EOD_nmt(:) /180 * pi) .* sin(phi_AOD_nmt(:) /180 * pi),...
    cos(theta_EOD_nmt(:) /180 * pi)].';
r_rx_nmt = reshape(r_rx_nmt, 3, ncluster, nray, nsnap);
r_rx_nmt = permute(r_rx_nmt, [1 4 2 3]);
r_tx_nmt = reshape(r_tx_nmt, 3, ncluster, nray, nsnap);
r_tx_nmt = permute(r_tx_nmt, [1 4 2 3]);
% LOS cluster
r_rx_LOS_t = [sin(theta_LOS_EOA_t) .* cos(phi_LOS_AOA_t); sin(theta_LOS_EOA_t) ...
    .* sin(phi_LOS_AOA_t); cos(theta_LOS_EOA_t)];
r_tx_LOS_t = [sin(theta_LOS_EOD_t) .* cos(phi_LOS_AOD_t); sin(theta_LOS_EOD_t) ...
    .* sin(phi_LOS_AOD_t); cos(theta_LOS_EOD_t)];
% Ground reflect
r_rx_GR_t = [ sin( theta_GR_EOA_t ) .* cos( phi_GR_AOA_t ); sin( theta_GR_EOA_t ) ...
    .* sin( phi_GR_AOA_t ); cos( theta_GR_EOA_t ) ];
r_tx_GR_t = [ sin( theta_GR_EOD_t ) .* cos( phi_GR_AOD_t ); sin( theta_GR_EOD_t ) ...
    .* sin( phi_GR_AOD_t ); cos( theta_GR_EOD_t )];

% Time delay: dim ncluster+4 * nsnap
timedelay_nt = cat(1, reshape(tau_2stro, [6, nsnap]), tau_nt(Ind_weakCls, :) );
[~, Ind_delay] = sort(timedelay_nt(:,1));
timedelay_nt = timedelay_nt(Ind_delay,:);
timedelay_nt(2,:) = tau_GR_t;

% Ground reflect
R_GR_p_t = ( epsilon_GRdiv0 * cos( theta_GR_EOD_t ) + ...
    sqrt( epsilon_GRdiv0 - sin( theta_GR_EOD_t ).^2 ) ) ...
    ./ ( epsilon_GRdiv0 * cos( theta_GR_EOD_t ) - ...
    sqrt( epsilon_GRdiv0 - sin( theta_GR_EOD_t ).^2 ) );
R_GR_v_t = ( cos( theta_GR_EOD_t ) + sqrt( epsilon_GRdiv0 ...
    - sin( theta_GR_EOD_t ).^2 ) ) ./ ( cos( theta_GR_EOD_t ) - ...
    sqrt( epsilon_GRdiv0 - sin( theta_GR_EOD_t ).^2 ) );

% Scatters para
D_nm = rand(unism, ncluster, nray ) * 2 * v_scatter_max  - v_scatter_max;
D_nmt = repmat(D_nm,[1,1,nsnap]);
alpha_nm = rand(unism, ncluster, nray) < 0.2;
alpha_nmt = repmat(alpha_nm, [1,1,nsnap] );
% Angles --> field pattern indexs
% Rays
phi_AOD_nmt_id = round( phi_AOD_nmt ) + 181;  % + 181
phi_AOA_nmt_id = round( phi_AOA_nmt ) + 181;  % + 181
theta_EOD_nmt_id = round( theta_EOD_nmt ) + 1;  % + 1
theta_EOA_nmt_id = round( theta_EOA_nmt ) + 1;  % + 1
% LOS cluster
phi_LOS_AOD_t_id = round( phi_LOS_AOD_t /pi *180 ) + 181;  % + 181
theta_LOS_EOD_t_id = round( theta_LOS_EOD_t /pi *180 ) + 1;  % + 1
phi_LOS_AOA_t_id = round( phi_LOS_AOA_t /pi *180 ) + 181;  % + 181
theta_LOS_EOA_t_id = round( theta_LOS_EOA_t /pi *180 ) + 1;  % + 1
% Ground reflect
phi_GR_AOD_t_id = round( phi_GR_AOD_t /pi *180 ) + 181;  % + 181
theta_GR_EOD_t_id = round( theta_GR_EOD_t /pi *180 ) + 1;  % + 1
phi_GR_AOA_t_id = round( phi_GR_AOA_t /pi *180 ) + 181;  % + 181
theta_GR_EOA_t_id = round( theta_GR_EOA_t /pi *180 ) + 1;  % + 1
% Mapping to rays for two strongest sub-clusters
R_1 = [1 2 3 4 5 6 7 8 19 20];
R_2 = [9 10 11 12 17 18];
R_3 = [13 14 15 16];
H = zeros( ncluster +4, nRx, nTx, nsnap );
%------------------------------------------
F_temp = reshape(F_rxth_u,[], nRx);
F_r_t_u = F_temp(theta_EOA_nmt_id + 181*(phi_AOA_nmt_id -1), (1:nRx) );
F_r_t_u_LOS = F_temp(theta_LOS_EOA_t_id + 181*(phi_LOS_AOA_t_id -1),(1:nRx) );
F_r_t_u_GR = F_temp(theta_GR_EOA_t_id + 181*(phi_GR_AOA_t_id -1),(1:nRx) );
F_temp = reshape(F_rxph_u,[], nRx);
F_r_p_u = F_temp(theta_EOA_nmt_id + 181*(phi_AOA_nmt_id -1), (1:nRx) );
F_r_p_u_LOS = F_temp(theta_LOS_EOA_t_id + 181*(phi_LOS_AOA_t_id -1),(1:nRx) );
F_r_p_u_GR = F_temp(theta_GR_EOA_t_id + 181*(phi_GR_AOA_t_id -1),(1:nRx) );
F_temp = reshape(F_txth_s,[], nTx);
F_t_t_s = F_temp(theta_EOD_nmt_id + 181*(phi_AOD_nmt_id -1),(1:nTx) );
F_t_t_s_LOS = F_temp(theta_LOS_EOD_t_id + 181*(phi_LOS_AOD_t_id -1),(1:nTx) );
F_t_t_s_GR = F_temp(theta_GR_EOD_t_id + 181*(phi_GR_AOD_t_id -1),(1:nTx) );
F_temp = reshape(F_txph_s,[], nTx);
F_t_p_s = F_temp(theta_EOD_nmt_id + 181*(phi_AOD_nmt_id -1),(1:nTx));
F_t_p_s_LOS = F_temp(theta_LOS_EOD_t_id + 181*(phi_LOS_AOD_t_id -1),(1:nTx) );
F_t_p_s_GR = F_temp(theta_GR_EOD_t_id + 181*(phi_GR_AOD_t_id -1),(1:nTx) );
for u = 1 : nRx
    for s = 1 : nTx
        % ----- time-vary/invariant doppler------------
        v_doppler_tv = zeros(ncluster, nray, nsnap);
        for it = 1 : nsnap
            v_doppler_tv(:,:,it) = permute( sum( r_rx_nmt(:,1:it,:,:)...
                .* v_rx_bar_t(:,1:it), [1 2] ) + sum( r_tx_nmt(:,1:it,:,:) ...
                .* v_tx_bar_t(:,1:it), [1 2] ), [3 4 2 1] ) * del_t  + ...
                2 * alpha_nmt(:,:,it) .* D_nmt(:,:,it) * t(it);
        end
        %--------ray-wise channel coeff--------
        h_F_temp = ( ( F_r_t_u(:,u) .* exp(1i * Phi_nmt_thth(:) ) +...
            F_r_p_u(:,u) .* sqrt( kappa_nmt(:).^(-1) ).* ...
            exp(1i * Phi_nmt_phth(:) ) ) .* F_t_t_s(:,s) + ...
            ( F_r_t_u(:,u) .* sqrt( kappa_nmt(:).^(-1) ).* ...
            exp(1i * Phi_nmt_thph(:) ) + F_r_p_u(:,u) .* ...
            exp(1i * Phi_nmt_phph(:) ) ) .* F_t_p_s(:,s) );
        h_F_temp = reshape(h_F_temp, ncluster, nray, nsnap);
        h_phase_temp = permute( exp( 1i * 2 * pi * sum( r_rx_nmt .* ...
            d_bar_rx_u(:,:,u), 1)/lambda_0 ) .* exp( 1i * 2 * pi * ...
            sum( r_tx_nmt .* d_bar_tx_s(:,:,s), 1)/lambda_0 ), [3 4 2 1] ) ...
            .* exp( 1i * 2 * pi * ( v_doppler_tv  )/ lambda_0 );
        h_ray_temp = h_F_temp .* h_phase_temp;
        %-------weak-cluster-wise coeff----------
        h_weak_cluster = ray2cluster(h_ray_temp(Ind_weakCls,:,:) ,P_nt(Ind_weakCls,:) / nray );
        %-------strong-cluster-wise coeff--------
        h_2sc_sub1 = ray2cluster(h_ray_temp(Ind_2BCls,R_1,:) ,P_nt(Ind_2BCls,:) / nray );
        h_2sc_sub2 = ray2cluster(h_ray_temp(Ind_2BCls,R_2,:) ,P_nt(Ind_2BCls,:) / nray );
        h_2sc_sub3 = ray2cluster(h_ray_temp(Ind_2BCls,R_3,:) ,P_nt(Ind_2BCls,:) / nray );
        %-------
        H_temp = cat(1, h_2sc_sub1, h_2sc_sub2, h_2sc_sub3, h_weak_cluster);
        H_temp = H_temp(Ind_delay,1,:);
        H_temp = sqrt( 1/(K_r+1) ) * H_temp;
        %-----------------------
        if Ind_LOS
            v_doppler_tv_LOS = zeros(1, nsnap);
            v_doppler_tv_GR = zeros(1, nsnap);
            for it = 1 : nsnap
                % ----- time-vary/invariant doppler------------
                v_doppler_tv_LOS(it) = ( sum( r_rx_LOS_t(:, 1:it) .* ...
                    v_rx_bar_t(:,1:it),'all' ) + sum( r_tx_LOS_t(:,1:it) .* ...
                    v_tx_bar_t(:,1:it),'all' ) ) * del_t;
                v_doppler_tv_GR(it) = ( sum( r_rx_GR_t(:, 1:it) .* ...
                    v_rx_bar_t(:,1:it),'all' ) + sum( r_tx_GR_t(:,1:it) .* ...
                    v_tx_bar_t(:,1:it),'all' ) ) * del_t;
            end
            h_phase_temp = exp( -1i * 2 * pi * Dis3_t / lambda_0 ) .* ...
                exp( 1i * 2 * pi * sum( r_rx_LOS_t .* d_bar_rx_u(:,:,u),1 )/lambda_0 ) .* ...
                exp( 1i * 2 * pi * sum( r_tx_LOS_t .* d_bar_tx_s(:,:,s),1 )/lambda_0 ) .* ...
                exp( 1i * 2 * pi * (v_doppler_tv_LOS )/lambda_0 );
            h_F_temp = ( F_r_t_u_LOS(:,u) .* F_t_t_s_LOS(:,s) - ...
                F_r_p_u_LOS(:,u) .* F_t_p_s_LOS(:,s) );
            h_LOS =  permute(h_F_temp, [2 3 1]) .* permute(h_phase_temp, [1 3 2]);
            H_temp(1,1,:) = H_temp(1,1,:)+ sqrt( K_r/(K_r + 1) ) * h_LOS;
            if Ind_GR
                h_phase_temp = exp( -1i * 2 * pi * Dis_GR_t / lambda_0 ) .* ...
                    exp( 1i * 2 * pi * sum( r_rx_GR_t .* d_bar_rx_u(:,:,u),1 )/lambda_0 ) .* ...
                    exp( 1i * 2 * pi * sum( r_tx_GR_t .* d_bar_tx_s(:,:,s),1 )/lambda_0 ) .* ...
                    exp( 1i * 2 * pi * (v_doppler_tv_GR )/lambda_0 );
                h_F_temp = ( F_r_t_u_GR(:,u) .* R_GR_p_t(:) .* F_t_t_s_GR(:,s) - ...
                    F_r_p_u_GR(:,u) .* R_GR_v_t(:) .* F_t_p_s_GR(:,s) );
                h_GR =  permute(h_F_temp, [2 3 1]) .* permute(h_phase_temp, [1 3 2]);
                H_temp(2,1,:) = H_temp(2,1,:)+ sqrt( K_r/(K_r + 1) ) * h_GR ...
                    .* permute( Dis3_t ./ Dis_GR_t, [1,3,2]);
            end
        end
        H(:,u,s,:) = permute( H_temp,[1 2 4 3] );
    end
end
if Ind_gainloss
    % Step12 add path loss and shadow fading
    H = sqrt( 10^( -gainloss_dB/10) ) * H ; % dim: ncluster+4 nRx nTx nsnap
end
end
