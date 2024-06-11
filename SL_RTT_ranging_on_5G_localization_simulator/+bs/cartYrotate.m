function [xb, yb, zb] = cartYrotate(xa, ya, za, beta);
%cartYrotate Rotate clockwise around the y-axis.
% beta denotes downtilt angle.
xb = cos( beta ) .* xa - sin( beta ) .* za;
yb = ya;
zb = sin( beta ) .* xa + cos( beta ) .* za;
end