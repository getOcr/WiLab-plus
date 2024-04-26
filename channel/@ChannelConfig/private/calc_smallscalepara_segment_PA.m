function ssp = calc_smallscalepara_segment_PA(para, lspar, Ind_LOS, Ind_O2I, ...
    BS_position, UE_position, UE_speed, UEAcceSpeed, UE_dir, nsnap, del_t, ...
    c, Ind_uplink, norsm, unism, r);
%calc_smallscalepara_segment_PA Generate segment-based small scale parameters.
%
% Description:
% Generate small scale parameters according to the segment-based simulations
% in 3GPP TR 38.901 v16.1.0 2019 -- clause 7.6.3 procedure A.
% Spatial consistent mobility modelling (powers, delays, and angles)
% according to TR38.901 clause 7.6.3.2
%
% Developer: Jia. Institution: PML. Date: 2021/10/28

%% -------------------------------------------------------------
% Paras align
ncluster = para.N_Cluster; r_tau = para.r_tau; ksi = para.ksi_pcsd;
nray = para.M_ray; c_DS = para.c_DS; XPR_mu = para.XPR_mu;
XPR_sigma = para.XPR_sigma; K = lspar.KF; DS = lspar.DS; 
ASA = lspar.ASA; ASD = lspar.ASD; ESA = lspar.ESA; ESD = lspar.ESD;
c_ASA = para.c_ASA; c_ASD = para.c_ASD; c_ESA = para.c_ESA;
c_ESD = para.c_ESD; ESD_mu = para.ESD_mu;ESA_mu = para.ESA_mu;
K_r = 10^( K/10 );
% tables
% Table 7.5-2 in 3GPP TR 38.901 v16.1.0.
C_phi_NLOS = [0.398,0.552,0.677,0.779,0.860,0.924,0.976,1.018,1.054,...
    1.090, 1.123,1.146,1.168,1.190,1.211,1.226,1.241,1.257,1.273,1.289,...
    1.3044,1.319,1.333,1.346,1.358];
% Table 7.5-4 in 3GPP TR 38.901 v16.1.0.
C_theta_NLOS = [0 0 0 0 0 0 0 0.889 0 0.957 1.031 1.104 0 0 1.1088 ...
    0 0 0 1.184 1.178 0 0 0 0 1.282 ];
% Table 7.5-3 in 3GPP TR 38.901 v16.1.0.
alpha_m = [0.0447 -0.0447 0.1413 -0.1413 0.2492 -0.2492 0.3715 ...
    -0.3715 0.5129 -0.5129 0.6797 -0.6797 0.8844 -0.8844 1.1481 ...
    -1.1481 1.5191 -1.5195 2.1551 -2.1551].';
%--------
% tx_positions, rx_positions, v_bar_tx and v_bar_rx calc
t = ( 0: ( nsnap -1 ) ).' * del_t;
if Ind_uplink
    v_tx_bar_t = ( UE_speed + 1/2 * UEAcceSpeed * (t.').^2  ) .*...
        [ sin( UE_dir(2) ) * cos( UE_dir(1) ), sin( UE_dir(2) ) * ...
        sin( UE_dir(1) ), cos( UE_dir(2) ) ].';
    v_rx_bar_t = zeros( 3, nsnap );
    tx_positions_t = UE_position + (UE_speed * t.' + 1/2 * UEAcceSpeed ...
        * (t.').^2 ) .* [ sin( UE_dir(2) ) * cos( UE_dir(1) ), ...
        sin( UE_dir(2) ) * sin( UE_dir(1) ), cos( UE_dir(2) )].';
    rx_positions_t = repmat( BS_position, 1, nsnap );
else
    v_rx_bar_t = ( UE_speed + 1/2 * UEAcceSpeed * (t.').^2  ) .*...
        [ sin( UE_dir(2) ) * cos( UE_dir(1) ), sin( UE_dir(2) ) *...
        sin( UE_dir(1) ), cos( UE_dir(2) )].';
    v_tx_bar_t = zeros(3,nsnap);
    rx_positions_t = UE_position + ( UE_speed * t.' + 1/2 * UEAcceSpeed ...
        * (t.').^2 ) .* [ sin( UE_dir(2) ) * cos( UE_dir(1) ), ...
        sin( UE_dir(2) ) * sin( UE_dir(1) ), cos( UE_dir(2) )].';
    tx_positions_t = repmat( BS_position, 1, nsnap );
end
ssp.bs.v_rx_bar_t = v_rx_bar_t;
ssp.bs.v_tx_bar_t = v_tx_bar_t;
ssp.bs.rx_positions_t = rx_positions_t;
ssp.bs.tx_positions_t = tx_positions_t;
% LOS angles
pos_temp = tx_positions_t - rx_positions_t; % dim: 3 * nsnap
% LOS-AOA and EOA of current BS-UE link
[AOA_LOS_t, EOA_LOS_t, ~] = bs.cart2sph( pos_temp(1,:), pos_temp(2,:), ...
    pos_temp(3,:) );
% LOS-AOD and EOD of current BS-UE link
[AOD_LOS_t, EOD_LOS_t, ~] = bs.cart2sph( -pos_temp(1,:), -pos_temp(2,:), ...
    -pos_temp(3,:) );
ssp.bs.AOD_LOS_t = AOD_LOS_t;
ssp.bs.AOA_LOS_t = AOA_LOS_t;
ssp.bs.EOD_LOS_t = EOD_LOS_t;
ssp.bs.EOA_LOS_t = EOA_LOS_t;
% 3-dimension dis per snap % dim: 1 * nsnap
Dis3_t = sqrt( sum( ( tx_positions_t - rx_positions_t ).^2, 1 ) );
% 2-dimension dis per snap % dim: 1 * nsnap
Dis2_t = sqrt( sum( ( tx_positions_t(1:2,:) - rx_positions_t(1:2,:) ).^2, 1 ) );
ssp.bs.Dis2_t = Dis2_t;
ssp.bs.Dis3_t = Dis3_t;
% Ground reflect distance
Dis_GR_t = sqrt( Dis2_t.^2 + ( abs(tx_positions_t(3,:)) +...
    abs(rx_positions_t(3,:)) ).^2 );
tau_GR_t = Dis_GR_t /c;
% angles --> ground reflect
theta_GR_EOD_t = pi - atan( Dis2_t ./ ( abs( tx_positions_t(3,:) ) + ...
    abs( rx_positions_t(3,:) ) ) );
phi_GR_AOD_t = AOD_LOS_t;
theta_GR_EOA_t = theta_GR_EOD_t;
phi_GR_AOA_t = phi_GR_AOD_t + pi;
phi_GR_AOA_t = mod(phi_GR_AOA_t +pi, 2*pi) -pi;
%-----------------------
ssp.groundreflect.Dis_GR_t = Dis_GR_t;
ssp.groundreflect.tau_GR_t = tau_GR_t;
ssp.groundreflect.phi_GR_AOA_t = phi_GR_AOA_t;
ssp.groundreflect.phi_GR_AOD_t = phi_GR_AOD_t;
ssp.groundreflect.theta_GR_EOA_t = theta_GR_EOA_t;
ssp.groundreflect.theta_GR_EOD_t = theta_GR_EOD_t;

if Ind_LOS
    K = K * ~Ind_O2I;
    C_r = 0.7705 - 0.0433 * K + 0.0002 * K ^2 + 0.000017 * K^3;
    C_phi = C_phi_NLOS(ncluster) * ...
        (1.1035 -0.028 * K - 0.002 * K^2 + 0.0001 * K^3 );
    C_theta = C_theta_NLOS(ncluster) * (1.3086 + 0.0339 * K ...
        - 0.0077 * K^2 + 0.0002 * K^3 );
else
    C_r = 1;
    C_phi = C_phi_NLOS( ncluster );
    C_theta = C_theta_NLOS( ncluster );
end
% ---------------------------------------------------------------
% Step5 cluster delay 
tau_n_prime = - r_tau * DS * log( r.rd_var_tau(1:ncluster ) );
tau_n = tau_n_prime - min( tau_n_prime );
% Step6 cluster power
P_prime = exp( - tau_n * ( r_tau -1)/( r_tau * DS ) ) .*  ...
    10.^( -( r.rd_var_pow(1: ncluster) * ksi /10 ) );
P_n = P_prime / sum( P_prime ); % dim: ncluster * 1
P_n = 1/(1 + K_r) * P_n;
P_n(1) = P_n(1) + K_r / ( K_r + 1 );
% Step7 gen AOA EOA AOD EOD
AOA_LOS_init = AOA_LOS_t(1) * 180 /pi;
EOA_LOS_init = EOA_LOS_t(1) * 180 /pi;
AOD_LOS_init = AOD_LOS_t(1) * 180 /pi;
EOD_LOS_init = EOD_LOS_t(1) * 180 /pi;
% AOA AOD
phi_AOA_prime = 2* ( ASA /1.4 ) * sqrt( -log( P_n/max( P_n ) ) ) / C_phi;
phi_AOD_prime = 2* ( ASD /1.4 ) * sqrt( -log( P_n/max( P_n ) ) ) / C_phi;
phi_AOA_n = r.rd_var_sign( (1:ncluster ), 1 ) .* phi_AOA_prime ...
    + r.rd_var_offset( (1:ncluster ), 1 ) * ASA/7 + AOA_LOS_init;
phi_AOD_n = r.rd_var_sign( (1:ncluster ), 2 ) .* phi_AOD_prime ...
    + r.rd_var_offset( (1:ncluster ), 2 ) * ASD/7 + AOD_LOS_init;
if Ind_LOS
    phi_AOA_n(1) = AOA_LOS_init;
    phi_AOD_n(1) = AOD_LOS_init;
end
% EOA EOD
theta_EOA_prime = -ESA * log( P_n / max( P_n ) ) / C_theta;
theta_EOD_prime = -ESD * log( P_n / max( P_n ) ) / C_theta;
if Ind_uplink
    if Ind_O2I == 1
        theta_EOD_bar = 90;
    else
        theta_EOD_bar = EOD_LOS_init;
    end
    theta_EOD_n = r.rd_var_sign( (1:ncluster ), 3 ) .* ...
        theta_EOD_prime + r.rd_var_offset( (1:ncluster ), 3 ) * ESD/7 + theta_EOD_bar;
    theta_EOA_n = r.rd_var_sign( (1:ncluster ), 4 ) .* ...
        theta_EOA_prime + r.rd_var_offset( (1:ncluster ), 4 ) * ESA/7 + ...
        EOA_LOS_init + para.EOA_off;
    if Ind_LOS
        theta_EOD_n(1) = EOD_LOS_init;
        theta_EOA_n(1) = EOA_LOS_init;
    end
else
    if Ind_O2I == 1
        theta_EOA_bar = 90;
    else
        theta_EOA_bar = EOA_LOS_init;
    end
    theta_EOA_n = r.rd_var_sign( (1:ncluster ), 4 ) .* ...
        theta_EOA_prime + r.rd_var_offset( (1:ncluster ), 4 ) * ESA/7 + theta_EOA_bar;
    theta_EOD_n = r.rd_var_sign( (1:ncluster ), 3 ) .* ...
        theta_EOD_prime + r.rd_var_offset( (1:ncluster ), 3 ) * ESD/7 + ...
        EOD_LOS_init + para.EOD_off;
    if Ind_LOS
        theta_EOA_n(1) = EOA_LOS_init;
        theta_EOD_n(1) = EOD_LOS_init;
    end
end
% Range [-180 , 180]
phi_AOA_n = mod(phi_AOA_n + 180, 360) -180;
phi_AOD_n = mod(phi_AOD_n + 180, 360) -180;
% Range [0,180]
theta_EOA_n = abs( mod( theta_EOA_n + 180, 360 ) -180 );
theta_EOD_n = abs( mod( theta_EOD_n + 180, 360 ) -180 );
%------------------------------------------
ssp.cluster.nray = nray;
ssp.cluster.ncluster = ncluster;
%
ssp.cluster.nPath = ncluster + 4;
ssp.cluster.nsnap = nsnap;
ssp.cluster.K_r = K_r;
% Calc time-evolution paras
[para_TC] = gen_spat_consis_paras( v_tx_bar_t, v_rx_bar_t, phi_AOD_n,...
    phi_AOA_n, theta_EOD_n, theta_EOA_n, ncluster, nsnap, c, del_t, ...
    Dis3_t(1), tau_n_prime, r_tau, ksi, DS, C_r, Ind_LOS,...
    norsm, unism, r.rd_var_ata);
tau_n_t_tilde = para_TC.tau_n_t_tilde;
ssp.cluster.tau_n_tilde = tau_n_t_tilde;
ssp.cluster.tau_n = tau_n;
P_nt = para_TC.P_nt;
ssp.cluster.P_n1 = P_n;
ssp.cluster.P_nt = P_nt;
phi_AOD_nt = para_TC.phi_AOD_nt;
ssp.cluster.phi_AOD_nt = phi_AOD_nt;
phi_AOA_nt = para_TC.phi_AOA_nt;
ssp.cluster.phi_AOA_nt = phi_AOA_nt;
theta_EOD_nt = para_TC.theta_EOD_nt;
ssp.cluster.theta_EOD_nt = theta_EOD_nt;
theta_EOA_nt = para_TC.theta_EOA_nt;
ssp.cluster.theta_EOA_nt = theta_EOA_nt;
% For the two strongest clusters
[~, Ind] = sort( P_nt(:,1) );
Ind_2BCls = [Ind(end) Ind(end-1) ];
ssp.cluster.Ind_2BCls = Ind_2BCls;
tau_2stro(:,:,1) = tau_n_t_tilde(Ind_2BCls,:);
tau_2stro(:,:,2) = tau_n_t_tilde(Ind_2BCls,:) + 1.28 * c_DS;
tau_2stro(:,:,3) = tau_n_t_tilde(Ind_2BCls,:) + 2.56 * c_DS;
ssp.cluster.tau_2stro = permute(tau_2stro, [1 3 2]);
% Ray-wise angles
phi_AOA_nmt = permute(phi_AOA_nt, [1 3 2]) + c_ASA * alpha_m.';
phi_AOD_nmt = permute(phi_AOD_nt, [1 3 2]) + c_ASD * alpha_m.';
% Range [-180, 180]
phi_AOA_nmt = mod(phi_AOA_nmt + 180, 360) -180;
phi_AOD_nmt = mod(phi_AOD_nmt + 180, 360) -180;
if Ind_uplink
    theta_EOD_nmt = permute(theta_EOD_nt, [1 3 2]) + c_ESD * alpha_m.';
    theta_EOA_nmt = permute(theta_EOA_nt, [1 3 2]) + (3/8) * (10^ESA_mu) * alpha_m.';
else
    theta_EOA_nmt = permute(theta_EOA_nt, [1 3 2]) + c_ESA * alpha_m.';
    theta_EOD_nmt = permute(theta_EOD_nt, [1 3 2]) + (3/8) * (10^ESD_mu) * alpha_m.';
end
% Range [0,180]
theta_EOA_nmt = abs(mod(theta_EOA_nmt + 180, 360) -180);
theta_EOD_nmt = abs(mod(theta_EOD_nmt + 180, 360) -180);
% Step8 random coupling of rays
% Coupling for weak clusters
Ind_wCls = ( 1 : ncluster );
Ind_wCls( Ind_wCls == Ind_2BCls(1) | Ind_wCls == Ind_2BCls(2) ) = [];
ssp.cluster.Ind_weakCls = Ind_wCls;
phi_AOD_nmt(Ind_wCls,:,:) = phi_AOD_nmt(r.rd_var_cp(Ind_wCls,:,:));
phi_AOA_nmt(Ind_wCls,:,:) = phi_AOA_nmt(r.rd_var_cp(Ind_wCls,:,:));
theta_EOD_nmt(Ind_wCls,:,:) = theta_EOD_nmt(r.rd_var_cp(Ind_wCls,:,:));
theta_EOA_nmt(Ind_wCls,:,:) = theta_EOA_nmt(r.rd_var_cp(Ind_wCls,:,:));
% Coupling for two strongest clusters
phi_AOD_nmt(Ind_2BCls,:,:) = phi_AOD_nmt(r.rd_var_b2cp );
phi_AOA_nmt(Ind_2BCls,:,:) = phi_AOA_nmt(r.rd_var_b2cp );
theta_EOD_nmt(Ind_2BCls,:,:) = theta_EOD_nmt(r.rd_var_b2cp );
theta_EOA_nmt(Ind_2BCls,:,:) = theta_EOA_nmt(r.rd_var_b2cp );
ssp.ray.phi_AOD_nmt = phi_AOD_nmt;
ssp.ray.phi_AOA_nmt = phi_AOA_nmt;
ssp.ray.theta_EOD_nmt = theta_EOD_nmt;
ssp.ray.theta_EOA_nmt = theta_EOA_nmt;

% Step9 gen XPR
kappa_nmt = 10.^( ( r.rd_var_spr((1:ncluster ),:,:) * XPR_sigma + XPR_mu )/10 );
ssp.ray.kappa_nmt = kappa_nmt;

% Step10 Init random phases
ssp.ray.Phi_nmt_thth = r.rd_var_rndphs((1:ncluster ),:,:,1) * 2* pi -pi;
ssp.ray.Phi_nmt_phph = r.rd_var_rndphs((1:ncluster ),:,:,2) * 2* pi -pi;
ssp.ray.Phi_nmt_thph = r.rd_var_rndphs((1:ncluster ),:,:,3) * 2* pi -pi;
ssp.ray.Phi_nmt_phth = r.rd_var_rndphs((1:ncluster ),:,:,4) * 2* pi -pi;
end