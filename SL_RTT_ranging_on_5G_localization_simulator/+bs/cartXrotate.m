function [xb, yb, zb] = cartXrotate(xa, ya, za, gamma );
%cartXrotate Rotate clockwise around the x-axis.
% gamma denotes slant angle.
xb = xa;
yb = cos( gamma ) .* ya + sin( gamma ) .* za;
zb = -sin( gamma ) .* ya + cos( gamma ) .* za;
end