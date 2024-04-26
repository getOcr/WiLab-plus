function    CRLB=CaculateCLRB_Velocity(SINR,SCS)
    c = 3 * 10^8; % Speed of light
    N=180;
    M=14;
    fc=5.9*10^9;
    Tsym = 1/(SCS);
    CRLB=3*c*c/(SINR.*8*pi*pi*Tsym^2*fc^2*M*N*(M*M-1));
end