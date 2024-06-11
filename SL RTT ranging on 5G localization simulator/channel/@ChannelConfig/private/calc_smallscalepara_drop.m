function [ssp] = calc_smallscalepara_drop(lsp, BS_position, UE_position, ...
    center_frequency, Ind_O2I, Ind_uplink,c ,nBS, nUE, unism,norsm );
%calc_smallscalepara_drop Generate small scale paras for drop-based simulation.
%
% Description:
%   This function aims to generate small scale paras for drop-based
%   simulation according to 3GPP TR 38.901 v16.1.0. clause 7.5
%
% Developer: Jia. Institution: PML. Date: 2021/10/28

% LOS angles:
if ~Ind_uplink
    pos_temp = permute(BS_position, [2 3 1] ) - permute(UE_position, [3 2 1] );
else
    pos_temp = permute(UE_position, [3 2 1] ) - permute(BS_position, [2 3 1] );
end
[AOA_LOS, EOA_LOS, ~] = bs.cart2sph( pos_temp(:,:,1), pos_temp(:,:,2), pos_temp(:,:,3) );
[AOD_LOS, EOD_LOS, ~] = bs.cart2sph( -pos_temp(:,:,1), -pos_temp(:,:,2), -pos_temp(:,:,3) );
% Ground Reflection
tau_GR = lsp.Dis_GR /c;
theta_GR_EOD = pi - atan( lsp.Dis2 ./(permute(abs(BS_position(3,:)), [2 1] ) ...
    + abs(UE_position(3,:)) ) );
phi_GR_AOD = AOD_LOS;
theta_GR_EOA = theta_GR_EOD;
phi_GR_AOA = phi_GR_AOD + pi;
phi_GR_AOA = mod(phi_GR_AOA +pi, 2*pi) -pi;
epsilon_GRdiv0 = get_permittivity( center_frequency, 7 );
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
% Init.
ssp(nBS,nUE).cluster.nray = 20;
% ssp calc
for iBS = 1 : nBS
    for iUE = 1 : nUE
        %----------------------------------
        % Paras
        para = lsp.para(iBS, iUE); lspar = lsp.lspar(iBS, iUE);
        Ind_LOS = lsp.Ind_LOS(iBS, iUE); ncluster = para.N_Cluster;
        r_tau = para.r_tau; ksi = para.ksi_pcsd; nray = para.M_ray;
        c_DS = para.c_DS; XPR_mu = para.XPR_mu; XPR_sigma = para.XPR_sigma;
        K = lspar.KF; DS = lspar.DS;Ind_O2I_p = Ind_O2I(iUE); K_r = 10^( K/10 );
        ASA = lspar.ASA; ASD = lspar.ASD; ESA = lspar.ESA; ESD = lspar.ESD;
        c_ASA = para.c_ASA; c_ASD = para.c_ASD; c_ESA = para.c_ESA;
        c_ESD = para.c_ESD; ESD_mu = para.ESD_mu;
        ESA_mu = para.ESA_mu;
        if Ind_LOS
            K = K * ~Ind_O2I_p;
            C_r = 0.7705 - 0.0433 * K + 0.0002 * K ^2 + 0.000017 * K^3;
            C_phi = C_phi_NLOS(ncluster) * ...
                (1.1035 -0.028 * K - 0.002 * K^2 + 0.0001 * K^3 );
            C_theta = C_theta_NLOS(ncluster) * (1.3086 + 0.0339 * K ...
                - 0.0077 * K^2 + 0.0002 * K^3 );
        else
            C_r = 1;
            C_phi = C_phi_NLOS(ncluster);
            C_theta = C_theta_NLOS(ncluster);
        end
        
        %-------------------------------------
        % LOS angles
        phi_LOS_AOD = AOD_LOS(iBS, iUE) /pi *180;
        theta_LOS_EOD = EOD_LOS(iBS, iUE) /pi *180;
        phi_LOS_AOA = AOA_LOS(iBS, iUE) /pi *180;
        theta_LOS_EOA = EOA_LOS(iBS, iUE) /pi *180;
        
        % Step5 cluster delay
        tau_n_prime = sort(- r_tau * DS * log( rand(unism, ncluster, 1) ) );
        tau_n =  tau_n_prime - min(tau_n_prime);
        
        % Step6 cluster power
        P_prime = exp( - tau_n * (r_tau -1)/(r_tau * DS) ) .* ...
            10.^( -( randn(norsm, ncluster, 1) * ksi /10 ) );
        P_n = P_prime / sum( P_prime ); % dim: ncluster * 1
        P_n = 1/(1+K_r) * P_n;
        P_n(1) = P_n(1) + K_r/(K_r +1); % for angles generations only.
        % remove weak clusters
        Ind = find(10*log10( P_n / max(P_n) ) < -25);
        P_n(Ind) = []; tau_n(Ind) = []; P_prime(Ind) = [];
        tau_n = tau_n / C_r;
        ncluster = length(P_n); % update the cluster number.
        
        % Step7 gen AOA EOA AOD EOD
        % AOA AOD of clusters
        phi_AOA_prime = 2* ( ASA/1.4 ) * sqrt( -log( P_n/max(P_n) ) ) / C_phi;
        phi_AOD_prime = 2* ( ASD/1.4 ) * sqrt( -log( P_n/max(P_n) ) ) / C_phi;
        phi_AOA_n = randsrc(ncluster,1,[1 -1; 0.5 0.5]) .* phi_AOA_prime ...
            + randn(norsm, ncluster, 1) * ASA/7 + phi_LOS_AOA;
        phi_AOD_n = randsrc(ncluster,1,[1 -1; 0.5 0.5]) .* phi_AOD_prime ...
            + randn(norsm, ncluster, 1) * ASD/7 + phi_LOS_AOD;
        if Ind_LOS
            phi_AOA_n(1) = phi_LOS_AOA;
            phi_AOD_n(1) = phi_LOS_AOD;
        end
        % Range [-180 , 180]
        phi_AOA_n = mod(phi_AOA_n + 180, 360) -180;
        phi_AOD_n = mod(phi_AOD_n + 180, 360) -180;
        % AOA AOD of rays
        phi_AOA_nm = phi_AOA_n + c_ASA * alpha_m.';
        phi_AOD_nm = phi_AOD_n + c_ASD * alpha_m.';
        % Range [-180 , 180]
        phi_AOA_nm = mod(phi_AOA_nm + 180, 360) -180;
        phi_AOD_nm = mod(phi_AOD_nm + 180, 360) -180;
        % EOA EOD
        theta_EOA_prime = -ESA * log(P_n / max(P_n) )/C_theta;
        theta_EOD_prime = -ESD * log(P_n / max(P_n) )/C_theta;
        if Ind_uplink
            if Ind_O2I_p == 1
                theta_EOD_bar = 90;
            else
                theta_EOD_bar = theta_LOS_EOD;
            end
            theta_EOD_n = randsrc(ncluster,1,[1 -1; 0.5 0.5]) .* ...
                theta_EOD_prime + randn(norsm, ncluster,1) * ESD/7 ...
                + theta_EOD_bar;
            theta_EOA_n = randsrc(ncluster,1,[1 -1; 0.5 0.5]) .* ...
                theta_EOA_prime + randn(norsm, ncluster,1) * ESA/7 + ...
                theta_LOS_EOA + para.EOA_off;
            if Ind_LOS
                theta_EOD_n(1) = theta_LOS_EOD;
                theta_EOA_n(1) = theta_LOS_EOA;
            end
            % Range [0,180]
            theta_EOA_n = abs(mod(theta_EOA_n + 180, 360) -180);
            theta_EOD_n = abs(mod(theta_EOD_n + 180, 360) -180);
            % rays
            theta_EOD_nm = theta_EOD_n + c_ESD * alpha_m.';
            theta_EOA_nm = theta_EOA_n + (3/8) * (10^ESA_mu) * alpha_m.';
        else
            if Ind_O2I_p == 1
                theta_EOA_bar = 90;
            else
                theta_EOA_bar = theta_LOS_EOA;
            end
            theta_EOA_n = randsrc(ncluster,1,[1 -1; 0.5 0.5]) .* ...
                theta_EOA_prime + randn(norsm, ncluster,1) * ESA/7 ...
                + theta_EOA_bar;
            theta_EOD_n = randsrc(ncluster,1,[1 -1; 0.5 0.5]) .* ...
                theta_EOD_prime + randn(norsm, ncluster,1) * ESD/7 + ...
                theta_LOS_EOD + para.EOD_off;
            if Ind_LOS
                theta_EOD_n(1) = theta_LOS_EOD;
                theta_EOA_n(1) = theta_LOS_EOA;
            end
            % Range [0,180]
            theta_EOA_n = abs(mod(theta_EOA_n + 180, 360) -180);
            theta_EOD_n = abs(mod(theta_EOD_n + 180, 360) -180);
            % rays
            theta_EOA_nm = theta_EOA_n + c_ESA * alpha_m.';
            theta_EOD_nm = theta_EOD_n + (3/8) * (10^ESD_mu) * alpha_m.';
        end
        % Range [0,180]
        theta_EOA_nm = abs(mod(theta_EOA_nm + 180, 360) -180);
        theta_EOD_nm = abs(mod(theta_EOD_nm + 180, 360) -180);
        
        % Step8 random coupling of rays
        % Select two strongest clusters
        [~,Ind] = sort( P_n );
        Ind_wCls = (1:ncluster);
        if ncluster < 2
            Ind_2BCls = [];
        else
            Ind_2BCls = [ Ind(end) Ind(end-1) ];
            Ind_wCls(Ind_wCls == Ind_2BCls(1)| Ind_wCls == Ind_2BCls(2) ) =[];
        end
        var_temp = rand(unism, ncluster, nray);
        [~,rd_var_cp] = sort(var_temp, 2);
        phi_AOD_nm(Ind_wCls,:) = phi_AOD_nm(rd_var_cp(Ind_wCls,:));
        phi_AOA_nm(Ind_wCls,:) = phi_AOA_nm(rd_var_cp(Ind_wCls,:));
        theta_EOD_nm(Ind_wCls,:) = theta_EOD_nm(rd_var_cp(Ind_wCls,:));
        theta_EOA_nm(Ind_wCls,:) = theta_EOA_nm(rd_var_cp(Ind_wCls,:));
        % Coupling for two strong clusters
        R1 = [1 2 3 4 5 6 7 8 19 20];
        R2 = [9 10 11 12 17 18];
        R3 = [13 14 15 16];
        var_temp = rand(unism, 2, nray);
        [~,ind1] = sort(var_temp(:,(1:10)), 2);
        [~,ind2] = sort(var_temp(:,(11:16)), 2);
        [~,ind3] = sort(var_temp(:,(17:20)), 2);
        rd_var_b2cp = cat(2, R1(ind1), R2(ind2), R3(ind3));
        if ~isempty(Ind_2BCls)
            phi_AOD_nm(Ind_2BCls,:) = phi_AOD_nm(rd_var_b2cp);
            phi_AOA_nm(Ind_2BCls,:) = phi_AOA_nm(rd_var_b2cp);
            theta_EOD_nm(Ind_2BCls,:) = theta_EOD_nm(rd_var_b2cp);
            theta_EOA_nm(Ind_2BCls,:) = theta_EOA_nm(rd_var_b2cp);
        end
        % Delay of two strong clusters
        tau_2stro = [];
        if ~(ncluster < 2)
            tau_2stro(1:2,1) = tau_n(Ind_2BCls);
            tau_2stro(1:2,2) = tau_n(Ind_2BCls) + 1.28 * c_DS;
            tau_2stro(1:2,3) = tau_n(Ind_2BCls) + 2.56 * c_DS;
            tau_2stro = reshape(tau_2stro, 6, [] );
        else
            tau_2stro = [];
        end
        
        % Step9 gen XPR
        kappa_nm = 10.^( ( randn( norsm, ncluster, nray ) * XPR_sigma + XPR_mu )/10 );
        %-----------------------------------
        ssp(iBS, iUE).cluster.phi_AOD_n = phi_AOD_n;
        ssp(iBS, iUE).cluster.phi_AOA_n = phi_AOA_n;
        ssp(iBS, iUE).cluster.theta_EOD_n = theta_EOD_n;
        ssp(iBS, iUE).cluster.theta_EOA_n = theta_EOA_n;
        ssp(iBS, iUE).ray.phi_AOD_nm = phi_AOD_nm;
        ssp(iBS, iUE).ray.phi_AOA_nm = phi_AOA_nm;
        ssp(iBS, iUE).ray.theta_EOD_nm = theta_EOD_nm;
        ssp(iBS, iUE).ray.theta_EOA_nm = theta_EOA_nm;
        ssp(iBS, iUE).ray.kappa_nm = kappa_nm;
        ssp(iBS, iUE).cluster.Ind_2BCls = Ind_2BCls;
        ssp(iBS, iUE).cluster.Ind_weakCls = Ind_wCls;
        ssp(iBS, iUE).cluster.tau_n = tau_n;
        ssp(iBS, iUE).cluster.tau_2stro = tau_2stro;
        ssp(iBS, iUE).cluster.P_n = P_prime / sum(P_prime); % for H coeff only
        ssp(iBS, iUE).cluster.P_n1 = P_n;
        ssp(iBS, iUE).cluster.K_r = K_r;
        ssp(iBS, iUE).cluster.ncluster = ncluster;
        ssp(iBS, iUE).ray.nray = nray;
        ssp(iBS, iUE).cluster.AOA_LOS = AOA_LOS(iBS,iUE);
        ssp(iBS, iUE).cluster.AOD_LOS = AOD_LOS(iBS,iUE);
        ssp(iBS, iUE).cluster.EOD_LOS = EOD_LOS(iBS,iUE);
        ssp(iBS, iUE).cluster.EOA_LOS = EOA_LOS(iBS,iUE);
        ssp(iBS, iUE).groundreflect.tau_GR = tau_GR(iBS,iUE);
        ssp(iBS, iUE).groundreflect.phi_GR_AOA = phi_GR_AOA(iBS,iUE);
        ssp(iBS, iUE).groundreflect.phi_GR_AOD = phi_GR_AOD(iBS,iUE);
        ssp(iBS, iUE).groundreflect.theta_GR_EOA = theta_GR_EOA(iBS,iUE);
        ssp(iBS, iUE).groundreflect.theta_GR_EOD = theta_GR_EOD(iBS,iUE);
        ssp(iBS, iUE).groundreflect.epsilon_GRdiv0 = epsilon_GRdiv0;
        ssp(iBS, iUE).groundreflect.Dis_GR = lsp.Dis_GR(iBS,iUE);
    end
end
end


