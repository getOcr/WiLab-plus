function  [hcoef,info]  = channelcoeff_LOSonly(Layout,Chan);
%channelcoeff_static Generate LOSonly channel coefficients.
%
% Description:
% Generate LOSonly channel coefficients according to 3GPP TR 38.901 v16.1.0
% 2019. The fast fading channel model is not considered.
% Note: This function mainly aims to model calibration.
%
% Developer: Jia. Institution: PML. Date: 2021/10/29

% Paras assignment
Ind_uplink = Chan.Ind_uplink;
UE_position = Layout.UE_position;
BS_position = Layout.BS_position;
BS_array = Layout.BS_array;
UE_array = Layout.UE_array;
UE_speed = Layout.UE_speed;
UE_dir = Layout.UE_mov_direction;
nBS = Layout.nBS;
nUE = Layout.nUE;
nsnap = Chan.nsnap;
lambda0 = Chan.wavelength;
interval_snap = Chan.interval_snap;
% % Large scale parameters
lsp = calc_largescalepara( Chan.center_frequency, BS_position, ...
    UE_position, Chan.Ind_LOS,  Chan.Ind_spatconsis, Chan.Ind_O2I, ...
    Chan.p_indoor, Chan.p_lowloss, Chan.Ind_uplink, Chan.scenario, ...
    nBS, nUE,Chan.normrndsm,Chan.unirndsm);
info.lsp = lsp;
% LOS-case angles:
if ~Ind_uplink
    pos_temp = permute(BS_position, [2 3 1] ) - permute(UE_position, [3 2 1]);
else
    pos_temp = permute(UE_position, [3 2 1]) - permute(BS_position, [2 3 1] );
end
[AOA_LOS, EOA_LOS, ~] = bs.cart2sph( pos_temp(:,:,1),...
    pos_temp(:,:,2), pos_temp(:,:,3) );
[AOD_LOS, EOD_LOS, ~] = bs.cart2sph( - pos_temp(:,:,1), ...
    - pos_temp(:,:,2), - pos_temp(:,:,3) );

hcoef(nBS, nUE).H = 0;
for iBS = 1 : nBS
    for iUE = 1 : nUE
        gainloss_dB = lsp.para(iBS, iUE).SF_sigma * randn ...
            + lsp.pathloss_dB(iBS, iUE) + lsp.O2Iloss_dB(iBS, iUE);
        dis3 = lsp.Dis3(iBS, iUE);
        AOD_LOS_p = AOD_LOS(iBS, iUE);
        AOA_LOS_p = AOA_LOS(iBS, iUE);
        EOD_LOS_p = EOD_LOS(iBS, iUE);
        EOA_LOS_p = EOA_LOS(iBS, iUE);
        t = (1:nsnap).' * interval_snap;
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
            v_tx_bar = zeros(3, 1);
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
        nRx = length( d_bar_rx_u(1,:) ); % M * N * Mg * Ng * P( * 3)
        nTx = length( d_bar_tx_s(1,:) ); % M * N * Mg * Ng * P( * 3)
        % LOS cluster
        r_rx_LOS = [ sin(EOA_LOS_p) .* cos(AOA_LOS_p), sin(EOA_LOS_p) ...
            .* sin(AOA_LOS_p), cos(EOA_LOS_p) ].';
        r_tx_LOS = [ sin(EOD_LOS_p) .* cos(AOD_LOS_p), sin(EOD_LOS_p) ...
            .* sin(AOD_LOS_p), cos(EOD_LOS_p) ].';
        % Generate channel coefficents
        % Init
        H_LOS = zeros(nRx, nTx, nsnap );
        % LOS cluster
        phi_LOS_AOD_id = round( AOD_LOS_p /pi *180 ) + 181;  % + 181
        theta_LOS_EOD_id = round( EOD_LOS_p /pi *180 ) + 1;  % + 1
        phi_LOS_AOA_id = round( AOA_LOS_p /pi *180 ) + 181;  % + 181
        theta_LOS_EOA_id = round( EOA_LOS_p /pi *180 ) + 1;  % + 1
        for u = 1 : nRx
            for s = 1 : nTx
                 % LOS path
                h_LOS = [ F_rxth_u( theta_LOS_EOA_id, phi_LOS_AOA_id, u ),...
                    F_rxph_u( theta_LOS_EOA_id, phi_LOS_AOA_id, u ) ] ...
                    * [ 1,0; 0, -1 ] * ...
                    [F_txth_s( theta_LOS_EOD_id, phi_LOS_AOD_id, s ); ...
                    F_txph_s( theta_LOS_EOD_id, phi_LOS_AOD_id, s ) ] * ...
                    exp( -1i * 2 * pi * dis3 / lambda0 ) * ...
                    exp( 1i * 2 * pi * ( r_rx_LOS.' * d_bar_rx_u(:,u) ) ...
                    /lambda0 ) * ...
                    exp( 1i * 2 * pi * ( r_tx_LOS.' * d_bar_tx_s(:,s) ) ...
                    /lambda0 ) * ...
                    exp( 1i * 2 * pi * (r_rx_LOS.' * v_rx_bar + r_tx_LOS.' ...
                    * v_tx_bar )/lambda0 * t );
                H_LOS(u,s,:) =   h_LOS;
            end
        end
         % Step12 add path loss and shadow fading
        H = sqrt( 10^( -gainloss_dB/10) ) * H_LOS;  % dim: nRx nTx nsnap
        hcoef(iBS,iUE).H = H;
        hcoef(iBS,iUE).timedelay = dis3/3e8;
    end
end


end


