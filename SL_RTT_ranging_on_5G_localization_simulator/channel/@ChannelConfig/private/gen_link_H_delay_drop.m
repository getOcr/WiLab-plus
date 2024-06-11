function [hcoef] = gen_link_H_delay_drop(ssp, lsp, BS_position, ...
    UE_position,BS_array, UE_array, UE_speed, UE_dir, lambda_0, ...
    nsnap, interval_snap, v_scatter_max, Ind_ABS_TOA, Ind_uplink,...
    Ind_GR,Ind_gainloss,nBS,nUE,unism,norsm);
%gen_link_H_delay_drop Generate drop-based channel coefficients.
%
% Description:
% Generate channel coefficients according to the drop-based simulations in
% 3GPP TR 38.901 v16.1.0 2019 -- clause 7.5.
% H: dim: ncluster+4 nRx nTx nsnap
% timedelay: dim: ncluster+4 *1
%
% Developer: Jia. Institution: PML. Date: 2021/10/28

% Mapping to rays for two strongest sub-clusters
R_1 = [1 2 3 4 5 6 7 8 19 20];
R_2 = [9 10 11 12 17 18];
R_3 = [13 14 15 16];

hcoef(nBS, nUE).H = 0;
for iBS = 1 : nBS
    for iUE = 1 : nUE
        %----------------------------------------------
        ssp_cluster = ssp(iBS,iUE).cluster; ssp_GR = ssp(iBS,iUE).groundreflect;
        ssp_ray = ssp(iBS, iUE).ray; AOA_LOS = ssp_cluster.AOA_LOS;
        EOA_LOS = ssp_cluster.EOA_LOS; AOD_LOS = ssp_cluster.AOD_LOS;
        EOD_LOS = ssp_cluster.EOD_LOS; Dis_GR = ssp_GR.Dis_GR;
        tau_GR = ssp_GR.tau_GR; GR_EOD = ssp_GR.theta_GR_EOD;
        GR_EOA = ssp_GR.theta_GR_EOA; GR_AOA = ssp_GR.phi_GR_AOA;
        GR_AOD = ssp_GR.phi_GR_AOD; epsilon_GRdiv0 = ssp_GR.epsilon_GRdiv0;
        ncluster = ssp_cluster.ncluster; nray = ssp_ray.nray;
        phi_AOD_nm = ssp_ray.phi_AOD_nm; phi_AOA_nm = ssp_ray.phi_AOA_nm ;
        theta_EOD_nm = ssp_ray.theta_EOD_nm; theta_EOA_nm =  ssp_ray.theta_EOA_nm ;
        tau_n = ssp_cluster.tau_n; kappa_nm = ssp_ray.kappa_nm;
        K_r = ssp_cluster.K_r; P_n = ssp_cluster.P_n;
        Ind_2BCls = ssp_cluster.Ind_2BCls; Ind_weakCls = ssp_cluster.Ind_weakCls;
        tau_2stro = ssp_cluster.tau_2stro; Ind_LOS = lsp.Ind_LOS(iBS, iUE);
        gainloss_dB = lsp.gainloss_dB(iBS, iUE); dis3 = lsp.Dis3(iBS, iUE);
        %----------------------------------------------
        t = (1 : nsnap).' * interval_snap;
        if Ind_uplink
            tx_array = UE_array(iUE); rx_array = BS_array(iBS);
            tx_position = UE_position(:,iUE); rx_position = BS_position(:,iBS);
        else
            rx_array = UE_array(iUE); tx_array = BS_array(iBS);
            rx_position = UE_position(:,iUE); tx_position = BS_position(:,iBS);
        end
        % Dual mobility
        if Ind_uplink
            v_tx_bar = UE_speed(iUE) .* [ sin( UE_dir(2,iUE) ) * ...
                cos( UE_dir(1,iUE) ), sin( UE_dir(2,iUE) ) * ...
                sin( UE_dir(1,iUE) ), cos( UE_dir(2,iUE) ) ].';
            v_rx_bar = zeros(3, 1 );
        else
            v_rx_bar = UE_speed(iUE) .* [ sin( UE_dir(2,iUE) ) *...
                cos( UE_dir(1,iUE) ), sin( UE_dir(2,iUE) ) * ...
                sin( UE_dir(1,iUE) ), cos( UE_dir(2,iUE) )].';
            v_tx_bar = zeros(3,1);
        end
        % Field pattern
        nazim = length(rx_array.grid_azim); nelev = length(rx_array.grid_elev);
        F_rxth_u = reshape( rx_array.Fth, nelev, nazim, []);
        F_rxph_u = reshape( rx_array.Fph, nelev, nazim, []);
        F_txth_s = reshape( tx_array.Fth, nelev, nazim, []);
        F_txph_s = reshape( tx_array.Fph, nelev, nazim, []);
        % Location vec of antenna elem
        d_bar_tx_s = reshape( tx_array.position_ant, 3, [] ) + tx_position;
        d_bar_rx_u = reshape( rx_array.position_ant, 3, [] ) + rx_position;
        % Receive and transmit antenna number
        nRx = length( d_bar_rx_u(1,:) ); % M * N * Mg * Ng * P
        nTx = length( d_bar_tx_s(1,:) ); % M * N * Mg * Ng * P( * 3)
        %----------------------------------------------
        % Step10 Init random phases
        Phi_nm_thth = rand(unism, ncluster, nray ) * 2* pi -pi;
        Phi_nm_phph = rand(unism, ncluster, nray ) * 2* pi -pi;
        Phi_nm_thph = rand(unism, ncluster, nray ) * 2* pi -pi;
        Phi_nm_phth = rand(unism, ncluster, nray ) * 2* pi -pi;
        phi_LOS = 0;
        % Step11 drop based evaluation
        % Spherical unit vectors
        r_rx_nm = [sin(theta_EOA_nm(:) /180 * pi) .* cos(phi_AOA_nm(:) /180 * pi),...
            sin(theta_EOA_nm(:) /180 * pi) .* sin(phi_AOA_nm(:) /180 * pi),...
            cos(theta_EOA_nm(:) /180 * pi)].';
        r_tx_nm = [sin(theta_EOD_nm(:) /180 * pi) .* cos(phi_AOD_nm(:) /180 * pi),...
            sin(theta_EOD_nm(:) /180 * pi) .* sin(phi_AOD_nm(:) /180 * pi),...
            cos(theta_EOD_nm(:) /180 * pi)].';
        % LOS cluster
        r_rx_LOS = [sin(EOA_LOS) * cos(AOA_LOS), sin(EOA_LOS) * sin(AOA_LOS), cos(EOA_LOS)].';
        r_tx_LOS = [sin(EOD_LOS) * cos(AOD_LOS), sin(EOD_LOS) * sin(AOD_LOS), cos(EOD_LOS)].';
        % Ground reflect
        r_rx_GR = [sin(GR_EOA) * cos(GR_AOA), sin(GR_EOA) * sin(GR_AOA), cos(GR_EOA)].';
        r_tx_GR = [sin(GR_EOD) * cos(GR_AOD), sin(GR_EOD) * sin(GR_AOD), cos(GR_EOD)].';
        %         tau_2stro = reshape(tau_2stro,6,[]);
        % Time delay: dim: ncluster +4
        timedelay = [tau_2stro; tau_n(Ind_weakCls)];
        [timedelay, Ind_delay] = sort(timedelay);
        % Absolute time of arrival
        if Ind_ABS_TOA
            % Correlation is not considered.
            del_tau = 10^( randn(norsm) * 0.4 -7.5 );
            timedelay = timedelay + dis3/3e8;
            if Ind_LOS
                timedelay(2:end) = timedelay(2:end) + del_tau;
                if Ind_GR
                    timedelay(2) = tau_GR;
                end
            else
                timedelay= timedelay + del_tau;
            end
        end
        ssp(iBS, iUE).cluster.nPath = length(timedelay);
        
        % Ground reflect coefficients
        R_GR_p = ( epsilon_GRdiv0 * cos( GR_EOD ) + ...
            sqrt( epsilon_GRdiv0 - sin( GR_EOD ).^2 ) ) ...
            / ( epsilon_GRdiv0 * cos( GR_EOD ) - ...
            sqrt( epsilon_GRdiv0 - sin( GR_EOD ).^2 ) );
        R_GR_v = ( cos( GR_EOD ) + sqrt( epsilon_GRdiv0 ...
            - sin( GR_EOD ).^2 ) ) / ( cos( GR_EOD ) - ...
            sqrt( epsilon_GRdiv0 - sin( GR_EOD ).^2 ) );
        
        % Scatters para
        D_nm = rand(unism, ncluster, nray ) * 2 * v_scatter_max  - v_scatter_max;
        alpha_nm = rand(unism, ncluster, nray) < 0.2;
        % Angles --> field pattern indexs
        % Rays
        phi_AOD_nm_id = round( phi_AOD_nm ) + 181;  % + 181
        phi_AOA_nm_id = round( phi_AOA_nm ) + 181;  % + 181
        theta_EOD_nm_id = round( theta_EOD_nm ) + 1;  % + 1
        theta_EOA_nm_id = round( theta_EOA_nm ) + 1;  % + 1
        % LOS cluster
        LOS_AOD_id = round( AOD_LOS /pi *180 ) + 181;  % + 181
        LOS_EOD_id = round( EOD_LOS /pi *180 ) + 1;  % + 1
        LOS_AOA_id = round( AOA_LOS /pi *180 ) + 181;  % + 181
        LOS_EOA_id = round( EOA_LOS /pi *180 ) + 1;  % + 1
        % Ground reflect
        phi_GR_AOD_id = round( GR_AOD /pi *180 ) + 181;  % + 181
        theta_GR_EOD_id = round( GR_EOD /pi *180 ) + 1;  % + 1
        phi_GR_AOA_id = round( GR_AOA /pi *180 ) + 181;  % + 181
        theta_GR_EOA_id = round( GR_EOA /pi *180 ) + 1;  % + 1
        if (ncluster < 2)
            H = zeros( ncluster, nRx, nTx, nsnap );
        else
            H = zeros( ncluster +4, nRx, nTx, nsnap );
        end
        %------------------------------------------
        F_temp = reshape(F_rxth_u,[], nRx);
        F_r_t_u = F_temp(theta_EOA_nm_id + 181*(phi_AOA_nm_id-1),(1:nRx));
        F_temp = reshape(F_rxph_u,[], nRx);
        F_r_p_u = F_temp(theta_EOA_nm_id + 181*(phi_AOA_nm_id-1),(1:nRx));
        F_temp = reshape(F_txth_s,[], nTx);
        F_t_t_s = F_temp(theta_EOD_nm_id + 181*(phi_AOD_nm_id-1),(1:nTx));
        F_temp = reshape(F_txph_s,[], nTx);
        F_t_p_s = F_temp(theta_EOD_nm_id + 181*(phi_AOD_nm_id-1),(1:nTx));
        
        for u = 1 : nRx
            for s = 1 : nTx
                %--------ray-wise channel coeff--------
                h_F_temp = ( ( F_r_t_u(:,u) .* exp(1i*Phi_nm_thth(:) ) +...
                    F_r_p_u(:,u) .* sqrt( kappa_nm(:).^(-1) ).* ...
                    exp(1i * Phi_nm_phth(:) ) ) .* F_t_t_s(:,s) + ...
                    ( F_r_t_u(:,u) .* sqrt( kappa_nm(:).^(-1) ).* ...
                    exp(1i * Phi_nm_thph(:) ) + F_r_p_u(:,u) .* ...
                    exp(1i * Phi_nm_phph(:) ) ) .* F_t_p_s(:,s) );
                h_phase_temp = exp( 1i * 2 * pi * ( r_rx_nm(:,:).' * ...
                    d_bar_rx_u(:,u) ) / lambda_0 ) .* exp( 1i * 2 * pi * ...
                    ( r_tx_nm(:,:).' * d_bar_tx_s(:,s) ) / lambda_0 ) .* ...
                    exp( 1i * 2 * pi * (r_rx_nm(:,:).' * v_rx_bar + ...
                    2 * alpha_nm(:) .* D_nm(:) + r_tx_nm(:,:).'* v_tx_bar) / ...
                    lambda_0 * t.');
                h_ray_temp = h_F_temp .* h_phase_temp;
                h_ray_temp = reshape(h_ray_temp, ncluster, nray, nsnap);
                %-------weak-cluster-wise coeff----------
                h_weak_cluster = ray2cluster(h_ray_temp(Ind_weakCls,:,:) ,P_n(Ind_weakCls) / nray );
                %-------strong-cluster-wise coeff--------
                h_2sc_sub1 = ray2cluster(h_ray_temp(Ind_2BCls,R_1,:) ,P_n(Ind_2BCls) / nray );
                h_2sc_sub2 = ray2cluster(h_ray_temp(Ind_2BCls,R_2,:) ,P_n(Ind_2BCls) / nray );
                h_2sc_sub3 = ray2cluster(h_ray_temp(Ind_2BCls,R_3,:) ,P_n(Ind_2BCls) / nray );
                %-------
                H_temp = cat(1, h_2sc_sub1, h_2sc_sub2, h_2sc_sub3, h_weak_cluster);
                H_temp = H_temp(Ind_delay,1,:);
                H_temp = sqrt( 1/(K_r+1) ) * H_temp;
                if Ind_LOS
                    % LOS path
                    h_LOS = [ F_rxth_u( LOS_EOA_id, LOS_AOA_id, u ),...
                        F_rxph_u( LOS_EOA_id, LOS_AOA_id, u ) ] * ...
                        [ exp(1i*phi_LOS),0; 0 -exp(1i*phi_LOS) ] * ...
                        [F_txth_s( LOS_EOD_id, LOS_AOD_id, s ); ...
                        F_txph_s( LOS_EOD_id, LOS_AOD_id, s ) ] * ...
                        exp( -1i * 2 * pi * dis3 / lambda_0 ) * ...
                        exp( 1i * 2 * pi * ( r_rx_LOS.' * d_bar_rx_u(:,u) )/lambda_0 ) * ...
                        exp( 1i * 2 * pi * ( r_tx_LOS.' * d_bar_tx_s(:,s) )/lambda_0 ) * ...
                        exp( 1i * 2 * pi * (r_rx_LOS.' * v_rx_bar + r_tx_LOS.' ...
                        * v_tx_bar )/lambda_0 * t.' );
                    H_temp(1,1,:) = H_temp(1,1,:)+ sqrt( K_r/(K_r + 1) ) * permute(h_LOS,[1 3 2]);
                    if Ind_GR && length(H_temp(:,1,1)) > 1
                        h_GR = [ F_rxth_u( theta_GR_EOA_id, phi_GR_AOA_id, u ),...
                            F_rxph_u( theta_GR_EOA_id, phi_GR_AOA_id, u ) ] ...
                            * [ R_GR_p,0; 0 -R_GR_v ] * ...
                            [F_txth_s( theta_GR_EOD_id, phi_GR_AOD_id, s ); ...
                            F_txph_s( theta_GR_EOD_id, phi_GR_AOD_id, s ) ] * ...
                            exp( -1i * 2 * pi * Dis_GR / lambda_0 ) * ...
                            exp( 1i * 2 * pi * ( r_rx_GR.' * d_bar_rx_u(:,u) )/lambda_0 ) * ...
                            exp( 1i * 2 * pi * ( r_tx_GR.' * d_bar_tx_s(:,s) )/lambda_0 ) * ...
                            exp( 1i * 2 * pi * ( r_rx_GR.' * v_rx_bar + r_tx_GR.' ...
                            * v_tx_bar )/lambda_0 * t.' );
                        H_temp(2,1,:) = H_temp(2,1,:) + sqrt( K_r/(K_r + 1) ) * permute(h_GR,[1 3 2])* dis3 / Dis_GR;
                    end
                end
                H(:,u,s,:) = permute( H_temp,[1 2 4 3] );
            end
        end
        if Ind_gainloss
            hcoef(iBS,iUE).H = sqrt( 10^( - gainloss_dB /10) ) * H;% dim: ncluster(+4) nRx nTx nsnap
        else
            hcoef(iBS,iUE).H = H;% dim: ncluster(+4) nRx nTx nsnap           
        end
        hcoef(iBS,iUE).timedelay = timedelay;
    end
end
end
