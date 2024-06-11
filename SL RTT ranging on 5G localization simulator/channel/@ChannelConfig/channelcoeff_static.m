function  [hcoef,info]  = channelcoeff_static(Layout,Chan);
%channelcoeff_static Generate drop-based channel coefficients.
%
% Description:
% Generate channel coefficients according to the drop-based simulations
% in 3GPP TR 38.901 v16.1.0 2019 -- clause 7.5
%
% Developer: Jia. Institution: PML. Date: 2021/10/28

% Large scale parameters
lsp = calc_largescalepara( Chan.center_frequency, Layout.BS_position, ...
    Layout.UE_position, Chan.Ind_LOS, Chan.Ind_spatconsis, Chan.Ind_O2I,...
    Chan.p_indoor, Chan.p_lowloss, Chan.Ind_uplink, Chan.scenario, Chan.nBS, ...
    Chan.nUE,Chan.normrndsm,Chan.unirndsm);
info.lsp = lsp;

% Small scale parameters
[ ssp ] = calc_smallscalepara_drop(lsp, Layout.BS_position, Layout.UE_position,...
    Chan.center_frequency, lsp.Ind_O2I, Chan.Ind_uplink, Layout.c, Chan.nBS,...
    Chan.nUE, Chan.unirndsm, Chan.normrndsm );
info.ssp = ssp;

% Channel coefficients
[ hcoef ] = gen_link_H_delay_drop(ssp, lsp, Layout.BS_position, ...
    Layout.UE_position, Layout.BS_array, Layout.UE_array, Layout.UE_speed, ...
    Layout.UE_mov_direction, Chan.wavelength, Chan.nsnap, Chan.interval_snap, ...
    Chan.v_scatter_max, Chan.Ind_ABS_TOA, Chan.Ind_uplink,Chan.Ind_GR,...
    Chan.Ind_gainloss, Chan.nBS,Chan.nUE, Chan.unirndsm, Chan.normrndsm);
end



