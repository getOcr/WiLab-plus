function [Layout, Chan] = ChanSimuConfig(sysPar,carrier);
%ChanSimuConfig Wireless channel simulator configuration
%
% This function aims to configure channel simulator to be consistent with 
% 5G NR signal systems.
%
% Developer: Jia. Institution: PML. Date: 2022/01/13

addpath('.\channel');
Layout = SysLayoutConfig;
Layout.BS_position = sysPar.BSPos;
Layout.BSorientation = [ sysPar.BSorientation; zeros( 1, sysPar.nBS );...
    zeros(1, sysPar.nBS ) ];
Layout.UE_position = sysPar.UEPos;
Layout.UEorientation = [ sysPar.UEorientation; zeros( 1, sysPar.nUE );...
    zeros(1, sysPar.nUE ) ];
Layout.center_frequency = sysPar.center_frequency;
Layout.BSSpacTuple = [2.5 2.5 0.5 0.5];
Layout.BSarrayTuple = [1 1 sysPar.BSArraySize 1];
Layout.UEarrayTuple = [1 1 sysPar.UEArraySize 1];
Layout.UE_speed = sysPar.VelocityUE;
Layout.UE_mov_direction = [2 *pi *rand(1, sysPar.nUE); ...
    pi /2 *ones(1, sysPar.nUE)];
get_BS_UE_array_config( Layout );
Chan = ChannelConfig( Layout );
Chan.scenario = sysPar.Scenario;
Chan.Ind_LOS = 1;
Chan.Ind_uplink = sysPar.IndUplink;
Chan.channeltype = sysPar.UEstate;
Chan.interval_snap = sysPar.RSPeriod * 1e-3 /( carrier.SubcarrierSpacing/15 );
Chan.nsnap = ceil( carrier.SlotsPerFrame * sysPar.nFrames / sysPar.RSPeriod);
%=======================%
