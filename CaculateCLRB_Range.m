function    CRLB=CaculateCLRB_Range(SINR,SCS)
    %SCS = 15;
    c = 3 * 10^8; % Speed of light
    N=480;
    M=14;
%     SINR=20;
%     SINR =  10.^(SINR / 10);
    %CRLB_temp = 3*c*c/(8.*SINR*pi*pi*SCS*SCS*M*N*(N*N-1));
    %SINR = [100 200 300 400];
    CRLB = 3*c*c./(8*SINR*pi*pi*SCS*SCS*M*N*(N*N-1));
    %CRLB=CRLB_temp./SINR;

    %loglog(SINR, sqrt(CRLB), 'b-', 'linewidth',1,'MarkerFaceColor', 'blue', 'DisplayName', 'MCS: 5, SCS: 30 kHz');
end

