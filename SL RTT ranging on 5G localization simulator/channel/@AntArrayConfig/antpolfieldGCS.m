function [Fth,Fph,info] = antpolfieldGCS(azim, elev, antsty, mode, zeta, alpha, ...
    beta, gamma );
%antpolfieldGCS Generate ant polarized field of azim and elev direction in GCS.
%
% Description:
% This function is according to the 3GPP TR 38.901 v16.1.0- clause 7.1.3.
% Note:
% Fth and Fph denote the polarized fields in azim and elev directions in GCS.
% azim and elev denote the range of azim and elev angle, respectively. 
% antsty denotes the ant style as defined in TR38.802 Table A.2.1. Mode
% denotes the polarized antenna modelling. alpha, beta, gamma denote 
% bearing angle (z), downtilt angle (y), and slant angle (x), respectively.
% zeta denotes the polarization slant angle. Note all angle in radians.
%
% Developer: Jia. Institution: PML. Date: 2021/11/10

theta_prime = acos( cos(beta) * cos(gamma) * cos(elev) ...
    + (sin(beta) * cos(gamma) * cos(azim -alpha) - ...
    sin(gamma) * sin(azim -alpha) ) .*sin(elev) );

phi_prime = angle( (cos(beta) * sin(elev) .* cos(azim-alpha) ...
    - sin(beta) * cos(elev) ) ...
    + 1i*( cos(beta) * sin(gamma) *cos(elev) + (sin(beta) * sin(gamma) ...
    * cos(azim-alpha) + cos(gamma) * sin(azim-alpha) ) .* sin(elev) ) );

% Generate antenna power pattern
[A, info] = AntArrayConfig.antpowpattern(phi_prime, theta_prime, antsty);
% Generate field pattern corresponding to theta_prime and phi_prime
[Fth_prime, Fph_prime] = AntArrayConfig.antpolarizedfield(A+info.Gmax, ...
    phi_prime, theta_prime, zeta, mode);
% Rotation angle between sph- LCS and GCS
psi = angle( ( sin(gamma) * cos(elev) .* sin(azim -alpha) + cos(gamma) ...
    * (cos(beta) * sin(elev) - sin(beta) * cos(elev) .* cos(azim -alpha) ) )...
    + 1i* (sin(gamma) * cos(azim -alpha) + sin(beta) *...
    cos(gamma) * sin(azim -alpha) ) );
cos_psi = cos(psi);
sin_psi = sin(psi);
Fth = cos_psi .* Fth_prime - sin_psi .* Fph_prime;   
Fph = sin_psi .* Fth_prime + cos_psi .* Fph_prime;  
end