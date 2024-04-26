function    CRLB=CaculateCLRB_Range(SINR,SCS)
    c = 3 * 10^8; % Speed of light
    N=480;
    M=14;
%     SINR=20;
%     SINR =  10.^(SINR / 10);
    CRLB_temp = 3*c*c/(8*pi*pi*SCS*SCS*M*N*(N*N-1));
    CRLB=CRLB_temp/SINR;
end

