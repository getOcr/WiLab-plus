function plotArray(ArrayConf,NodePos)
%plotArray plot array shape.
% alpha denotes bearing angle, beta denotes downtilt angle

M = ArrayConf.M;
N = ArrayConf.N;
Mg = ArrayConf.Mg;
Ng = ArrayConf.Ng;
d_h = ArrayConf.d_h;
d_v = ArrayConf.d_v;
d_hg = ArrayConf.d_hg;
d_vg = ArrayConf.d_vg;
pos_antx = zeros(1, M * N );
pos_anty = kron( ( (0:(N-1)) -(N-1)/2 ) * d_h, ones(1,M) );
pos_antz = repmat(( (0:(M-1)) -(M-1)/2 ) * d_v, 1, N );

pos_panx = zeros(1, Mg * Ng );
pos_pany = kron( ( ( 0:(Ng-1) ) -(Ng-1)/2 ) * d_hg, ones(1, Mg) );
pos_panz = repmat( ( ( 0:(Mg-1) ) -(Mg-1)/2 ) * d_vg, 1, Ng );

pos_xo = reshape(pos_antx.' + pos_panx, 1,[]);
pos_yo = reshape(pos_anty.' + pos_pany, 1,[]);
pos_zo = reshape(pos_antz.' + pos_panz, 1,[]);

% elem shape
x_e = [0 0 0 0 0] * 0.15;
y_e = [-1 1 1 -1 -1] * 0.15;
z_e = [-1 -1 1 1 -1] * 0.15;
pos_x = x_e' + pos_xo ;
pos_y = y_e' + pos_yo ;
pos_z = z_e' + pos_zo ;
[pos_x,pos_y,pos_z] = rotatedpos(pos_x,pos_y,pos_z,ArrayConf);
h = fill3( pos_x + NodePos(1,1), pos_y + NodePos(2,1), pos_z + NodePos(3,1),...
    [0.5 0.4 0.3]);
set(h,'handlevisibility','off');
% x_e = [0 -1 0 0 0 -1 0 0 0 0 -1 -1] * ( N ) * d_hg *0.1;
% y_e = [-1 0 1 1 -1 0 1 -1 -1 1 0 0] * ( ( ( Ng -1) * d_hg )...
%     + d_h *0.8 * N );
% z_e = [1 1 1 -1 -1 -1 -1 -1 1 1 1 -1] * ( ( ( Ng -1) * d_hg )...
%     + d_h *0.5 * N );
x_e = [0 0 0 0 0 0 0 -1 -1 0 -1 -1 0 0 -1] * ( N ) * d_hg *0.1;
y_e = [-1 -1 1 1 -1 1 1 0 0 1 0 0 -1 -1 0] * ( ( ( Ng -1) * d_hg )...
    + d_h *0.8 * N );
z_e = [-1 1 1 -1 -1 -1 1 1 -1 -1 -1 1 1 -1 -1 ] * ( ( ( Ng -1) * d_hg )...
    + d_h *0.5 * N );
[pos_x,pos_y,pos_z] = rotatedpos( x_e', y_e', z_e', ArrayConf );
h = plot3( pos_x+ NodePos(1,1),pos_y+ NodePos(2,1),pos_z+ NodePos(3,1),...
    'Color','#2F4F4F');
set(h,'handlevisibility','off');
end
%------------------
% sub function
%------------------
function [pos_x,pos_y,pos_z] = rotatedpos(pos_xo,pos_yo,pos_zo,ArrayConf)
if ~ArrayConf.Ind_3_sector
    [pos_xo,pos_yo,pos_zo] = bs.cartXrotate(pos_xo, pos_yo, pos_zo,...
        -ArrayConf.Orientation(3));
    [pos_xo,pos_yo,pos_zo] = bs.cartYrotate(pos_xo, pos_yo, pos_zo, ...
        -ArrayConf.Orientation(2));
    [pos_x,pos_y,pos_z] = bs.cartZrotate(pos_xo, pos_yo, pos_zo, ...
        -ArrayConf.Orientation(1));    
else
    [pos_xo,pos_yo,pos_zo] = bs.cartXrotate(pos_xo+ ArrayConf.Ng, pos_yo, pos_zo,...
        -ArrayConf.Orientation(3));
    [pos_xo,pos_yo,pos_zo] = bs.cartYrotate(pos_xo, pos_yo, pos_zo, ...
        -ArrayConf.Orientation(2));
    [pos_xo,pos_yo,pos_zo] = bs.cartZrotate(pos_xo, pos_yo, pos_zo, ...
        -ArrayConf.Orientation(1));
    [pos_x2,pos_y2,pos_z2] = bs.cartZrotate(pos_xo, pos_yo, pos_zo, -2/3*pi);
    [pos_x3,pos_y3,pos_z3] = bs.cartZrotate(pos_xo, pos_yo, pos_zo, -4/3*pi);
    pos_x = [pos_xo, pos_x2,pos_x3];
    pos_y = [pos_yo, pos_y2, pos_y3];
    pos_z = [pos_zo, pos_z2, pos_z3];
end
end