function [az, elev, r] = cart2sph(x, y, z)
%sph2cart Transform Cartesian to spherical coordinates. 
% The range of elevation angle is [0 pi] (from the direction of z-axis),
% and the range of azimuth angle is [-pi, pi] (0 is corresponding to x-axis).
%   Note that the range of elev is 0~pi, and begins with +z-axis.
hypotxy = hypot(x, y);
r = hypot( hypot(x, y), z);
elev = atan2( hypotxy, z);
az = atan2(y, x);
end
