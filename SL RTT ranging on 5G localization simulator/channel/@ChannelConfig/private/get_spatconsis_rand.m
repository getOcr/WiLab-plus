function out = get_spatconsis_rand(UE_position,d_dec,var_style, norsm);
%get_spatconsis_rand generate spatial-consistent random variables
% Note: Spatial consistency is not modelled when UE locates on different
% floors.
h_floor = 3;
% UE_position = UE_position -[1;1;0] * d_dec/2;
Ind = user_grouping_flr(UE_position,h_floor);
Y_xy = zeros(1,length(UE_position(1,:) ) );
if d_dec ~= 0
    for igrp = 1 : length(Ind)
        Ind_if = Ind{igrp};
        pos = UE_position(:,Ind_if);
        %----
        axis_min = floor( min(pos((1:2),:),[],2)/d_dec) * d_dec;
        axis_max = ceil( max(pos((1:2),:)+1,[],2)/d_dec) * d_dec;
        Ind_max = prod( (axis_max - axis_min) /d_dec +1 );
        Len_gridx = ( ( axis_max(1)-axis_min(1) )/d_dec+1 );
        pos_ingrid = mod(pos, d_dec);
        pos_00 = pos - pos_ingrid; % Y_00 pos
        sub = (pos_00(1:2,:) - axis_min)/d_dec;
        Ind_00 = sub(1,:)+1 + sub(2,:) * Len_gridx;
        Ind_01 = Ind_00 + Len_gridx;
        Ind_10 = Ind_00 + 1;
        Ind_11 = Ind_00 + Len_gridx + 1;
        Y_rand = randn(norsm, 1,Ind_max) + 1i * randn(norsm,1,Ind_max);
        Y_xy_if = sqrt(1- pos_ingrid(2,:) / d_dec) .* ...
            ( sqrt(1- pos_ingrid(1,:) / d_dec) .*  Y_rand(Ind_00) +...
            sqrt( pos_ingrid(1,:) / d_dec) .*  Y_rand(Ind_10) ) +...
            sqrt(pos_ingrid(2,:) / d_dec) .* ...
            (sqrt(1- pos_ingrid(1,:) / d_dec) .*  Y_rand(Ind_01) +...
            sqrt( pos_ingrid(1,:) / d_dec) .*  Y_rand(Ind_11) );
        Y_xy(1,Ind_if) = Y_xy_if;
    end
end
switch var_style
    case 'uniform'
        out = abs( angle(Y_xy) / pi );
    case 'normal'
        out = real(Y_xy);
end
end