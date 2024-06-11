function pos = ant_pos_calc(obj);
%ant_pos_calc Calculate positions of every antenna elements.

pos_anty = kron( ( (0:(obj.N-1)) -(obj.N-1)/2 ) * obj.dis_h, ones(1,obj.M));
pos_antz = repmat(( (0:(obj.M-1)) -(obj.M-1)/2 ) * obj.dis_v,1,obj.N);
pos_antx = zeros(1, obj.M * obj.N );

pos_pany = kron( ( (0:(obj.Ng-1)) -(obj.Ng-1)/2 ) * obj.dis_hg, ones(1,obj.Mg));
pos_panz = repmat( ((0:(obj.Mg-1) ) -(obj.Mg-1)/2 ) * obj.dis_vg, 1,obj.Ng);
pos_panx = zeros(1, obj.Mg * obj.Ng );

pos_y = repmat( reshape(pos_anty.' + pos_pany, 1,[]), 1,1, obj.P );
pos_z = repmat( reshape(pos_antz.' + pos_panz, 1,[]), 1,1, obj.P );
pos_x = repmat( reshape(pos_antx.' + pos_panx, 1,[]), 1,1, obj.P );

if ~obj.Ind_3_sector
    [pos_x,pos_y,pos_z] = bs.cartXrotate(pos_x+ obj.dis_2pole, pos_y, pos_z, ...
        -obj.Orientation(3));
    [pos_x,pos_y,pos_z] = bs.cartYrotate(pos_x, pos_y, pos_z, -obj.Orientation(2));
    [pos_x,pos_y,pos_z] = bs.cartZrotate(pos_x, pos_y, pos_z, -obj.Orientation(1));
    pos = [pos_x;pos_y;pos_z];
    
else
    [pos_x,pos_y,pos_z] = bs.cartXrotate(pos_x+ obj.dis_2pole, pos_y, pos_z, ...
        -obj.Orientation(3));
    [pos_x,pos_y,pos_z] = bs.cartYrotate(pos_x, pos_y, pos_z, -obj.Orientation(2));
    [pos_x,pos_y,pos_z] = bs.cartZrotate(pos_x, pos_y, pos_z, -obj.Orientation(1));
    [pos_x2,pos_y2,pos_z2] = bs.cartZrotate(pos_x, pos_y, pos_z, -2/3*pi);
    [pos_x3,pos_y3,pos_z3] = bs.cartZrotate(pos_x, pos_y, pos_z, -4/3*pi);
    pos = [[pos_x, pos_x2,pos_x3];[pos_y, pos_y2, pos_y3];...
        [pos_z, pos_z2, pos_z3]];
end
% plot3(pos(1,:),pos(2,:),pos(3,:),'o');grid on;
end
