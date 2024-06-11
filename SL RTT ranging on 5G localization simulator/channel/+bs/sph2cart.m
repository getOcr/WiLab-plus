function [x,y,z] = sph2cart(azim, elev, r)
%sph2cart Transform spherical to Cartesian coordinates.
%   [X,Y,Z] = SPH2CART(azim,elev,R) transforms corresponding elements of
%   Note that the range of elev is 0~pi, and begins with +z-axis.
z = r .* cos( elev );
x = r .* sin( elev ) .* cos( azim );
y = r .* sin( elev ) .* sin( azim );
end
