function [epsilon_GRdiv0] = get_permittivity(center_frequency,Ind);
%get_permittivity according to 3GPP TR 38.901 v16.1.0 Table 7.6.8
epsilon_0 = 8.854187817e-12;
switch Ind
    case 1 % concrete   for f = [1,100] GHz
        a_eps = 5.31; b_eps = 0; c_sig = 0.0326; d_sig = 0.8095;
    case 2 % brick   for f = [1,10] GHz
        a_eps = 3.75; b_eps = 0; c_sig = 0.038; d_sig = 0;
    case 3 % plasterboard  for f = [1,100] GHz
        a_eps = 2.94; b_eps = 0; c_sig = 0.0116; d_sig = 0.7076;
    case 4 % wood   for f = [0.001,100] GHz
        a_eps = 1.99; b_eps = 0; c_sig = 0.0047; d_sig = 1.0718;
    case 5 % floorboard   for f = [50,100] GHz
        a_eps = 3.66; b_eps = 0; c_sig = 0.0044; d_sig = 1.3515;
    case 6 % metal   for f = [1,100] GHz
        a_eps = 1; b_eps = 0; c_sig = 1e7; d_sig = 0;
    case 7 % very dry ground    for f = [1,10] GHz
        a_eps = 3; b_eps = 0; c_sig = 0.00015; d_sig = 2.52;
    case 8 % medium dry ground   for f = [1,10] GHz
        a_eps = 15; b_eps = -0.1; c_sig = 0.035; d_sig = 1.63;
    case 9 % wet ground    for f = [1,10] GHz
        a_eps = 30; b_eps = -0.4; c_sig = 0.15; d_sig = 1.30;
end
epsilon_r = a_eps * (center_frequency/1e9)^b_eps;
sigma = c_sig * (center_frequency/1e9)^d_sig;
epsilon_GRdiv0 = epsilon_r - 1i * sigma / ...
    ( 2*pi * center_frequency * epsilon_0 );
end
