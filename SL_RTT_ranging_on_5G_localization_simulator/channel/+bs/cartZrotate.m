function [xb, yb, zb] = cartZrotate(xa, ya, za, alpha);
%cartZrotate Rotate clockwise around the z-axis.
% alpha denotes bearing angle.
xb = cos( alpha ) .* xa + sin( alpha ) .* ya;
yb = -sin( alpha ) .* xa + cos( alpha ) .* ya;
zb = za;
end