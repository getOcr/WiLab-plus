function [ BS_pos, BS_orient, UE_pos, UE_orient, Ind_O2I ] = ...
    get_BS_UE_layoutinfo(nBS, nUE, ISD, h_BS, min_dis, max_dis,Scenario,ang_etilt)
% This function aims to generate BS and UE layout information for channel
% model calibration -Phase 1. Please see TR 38.901 v16.1.0 and TR 36.873 for
% detail.
% Note: max nBS = 19 for umi and uma and = 12 for indoor;
if ~strcmpi(Scenario,'indoor')
    % BSs positions
    theta_BS = [(0:11) * pi/3, (0:5) * pi/3 + pi/6];
    r_BS = [ISD * ones(1,6), 2*ISD * ones(1,6) sqrt(3)*ISD * ones(1,6)];
    x_BS = r_BS .* cos( theta_BS );
    y_BS = r_BS .* sin( theta_BS );
    BS_pos(1,:) = [ 0, x_BS( 1:( nBS -1) ) ];
    BS_pos(2,:) = [ 0, y_BS( 1:( nBS -1) ) ];
    BS_pos(3,:) = ones(1, nBS) * h_BS;
    Ind_O2I = [ones(1, fix( 0.8*nUE ) ), zeros(1,( nUE - fix( 0.8*nUE )))];
    Ind_O2I( randperm( nUE ) ) = Ind_O2I;
    % UEs positions.
    N_fl = randi([4, 8], 1, sum( Ind_O2I ) );
    n_fl = zeros(1, sum( Ind_O2I ) );
    for iUE = 1 : sum( Ind_O2I )
        n_fl(1,iUE) = randi( N_fl(iUE) );
    end
    h_UE = ones(nUE, 1) * 1.5;
    h_UE(Ind_O2I == 1) = 3 * (n_fl - 1) + 1.5;
    r_UE = sqrt( rand(nUE, 1 ) ) * ( max_dis - min_dis ) + min_dis;
    theta_UE = rand( nUE, 1 ) * 2 * pi;
    x_UE = r_UE .* cos( theta_UE );
    y_UE = r_UE .* sin( theta_UE );
    UE_pos = [ x_UE, y_UE, h_UE ].';
else
    % BSs positions
    BS_pos_temp = [10 + ISD * ( 0: 5) ,10 + ISD * (0: 5);...
        15 * ones(1, 6) ,(15 + ISD) * ones(1, 6); ones(1,12) * h_BS ];
    BS_pos = BS_pos_temp(:,(1:nBS) );
    % UEs positions
    h_UE = ones(nUE, 1);
    x_UE = rand(nUE,1) * 120;
    y_UE = rand(nUE,1) * 50;
    UE_pos = [ x_UE, y_UE, h_UE ].';Ind_O2I = 0;
end
% BSs orientations
BS_orient = [ pi/6 * ones(1,nBS); zeros(1,nBS); zeros(1,nBS)];
UE_orient = [rand(1, nUE) * 2*pi; pi/2*ones(1,nUE); zeros(1,nUE)];
end