function [Fth1,Fph1] = antpolarizedfield(A,azim,elev,zeta,mode)
%antpolarizedfield Generate polarized radiation field components.
%
% Description:
%   This function is according to 3GPP TR 38.901 - clause 7.3.2. Polarized
%   antenna modelling.
%
% Developer: Jia. Institution: PML. Date: 2021/10/14
switch mode
    case 1
        Fth11 = sqrt( 10.^(A/10) );
        Fph11 = 0;
        if zeta ~= 0
            cos_psi = ( cos(zeta) * sin(elev) + sin(zeta) * sin(azim) .* ...
                cos(elev) ) ./ sqrt( 1-( cos(zeta) * cos(elev) - sin(zeta) ...
                * sin(azim) .* sin(elev) ).^2 );
            sin_psi = sin(zeta) * cos(azim) ./ sqrt( 1-( cos(zeta) *cos(elev) ...
                - sin(zeta) * sin(azim) .* sin(elev) ).^2 );
        else
            cos_psi = 1;
            sin_psi = 0;
        end
        Fth1 = cos_psi .* Fth11 - sin_psi .* Fph11;
        Fph1 = sin_psi .* Fth11 + cos_psi .* Fph11;
    case 2
        Fth1 = sqrt( 10.^(A /10) ) * cos( zeta );
        Fph1 = sqrt( 10.^(A /10) ) * sin( zeta );
end