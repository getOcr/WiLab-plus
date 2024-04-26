function para = para_UMa_NLOS_O2I(center_frequency,d2,h_UE,h_BS);
% 3GPP 38.901 v16.0 table 7.5-6
%
% Application range.

% 2-d distance:         [10 10000] m
% center frequency:     [0.5 100] GHz
% user antenna height:  [1.5 22.5] m
% BS antenna height:    25 m

fc = center_frequency / 1e9;
if fc <= 6
    fc = 6;
end

% LSP para mean and std
para.DS_mu = -6.62; % Delay spread mean /log10(DS) /DS: s
para.DS_sigma = 0.32; % delay spread std. / log10(DS)

para.ASD_mu = 1.25;
para.ASD_sigma = 0.42;

para.ASA_mu = 1.76;
para.ASA_sigma = 0.16;

para.ESA_mu = 1.01;
para.ESA_sigma = 0.43;

para.ESD_mu = max(-0.5, - 2.1 * (d2/1000) - 0.01*(h_UE-1.5) +0.9);
para.ESD_sigma = 0.49;

para.EOD_off = 7.66 * log10(fc) - 5.96 -10^( ( 0.208*log10(fc) -0.782 ) ...
        *log10( max( 25,d2 ) ) -0.13 * log10(fc) + 2.03 - 0.07*(h_UE -1.5) ) ;

para.SF_sigma = 7;

para.KF_mu = -100;
para.KF_sigma = 0;

para.XPR_mu = 9; % cross-polarization ratio [dB]
para.XPR_sigma = 5;

% cluster-wise para
para.r_tau = 2.2; % delay scaling parameter
para.ksi_pcsd = 4;  %per cluster shadowing std [dB]
para.N_Cluster = 12;
para.M_ray = 20;

para.c_DS = 11e-9;
para.c_ASD = 5; % [deg]
para.c_ASA = 8;
para.c_ESA = 3;
para.c_ESD = 3/8 * 10^(para.ESD_mu);

% cross-correlation

% decorrelation distance
%  order = [ SF KF DS ASD ASA ESD ESA ]
para.d_dec(1) = 7; % m
para.d_dec(2) = 50; % m
para.d_dec(3) = 10; % m
para.d_dec(4) = 11; % m
para.d_dec(5) = 17; % m
para.d_dec(6) = 25; % m
para.d_dec(7) = 25; % m
% C_MM correlation matrix
% C_MM = order vs order.'
para.C_MM = [ 1   0 -0.5  0.2    0    0    0; ... % vs SF
              0   1    0    0    0    0    0; ... % vs KF
           -0.5   0    1  0.4  0.4 -0.6 -0.2; ... % vs DS
            0.2   0  0.4    1    0 -0.2    0; ... % vs ASD
              0   0  0.4    0    1    0  0.5; ... % vs ASA
              0   0 -0.6 -0.2    0    1  0.5; ... % vs ESD
              0   0 -0.2    0  0.5  0.5    1 ];   % vs ESA



end