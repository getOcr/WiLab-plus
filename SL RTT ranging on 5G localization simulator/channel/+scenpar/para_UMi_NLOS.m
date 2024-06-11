function para = para_UMi_NLOS(center_frequency,d2,h_UE,h_BS);
% 3GPP 38.901 v16.0 table 7.5-6

% Application range.
% BS antenna height:    10 m
% UE antenna height:    [1.5 22.5] m
% 2-d distance:         [0 5e3] m
% center frequency:     [0.5 100] GHz
fc = center_frequency / 1e9;
if fc <= 2
    fc = 2;
end
% LSP para mean and std
para.DS_mu = -6.83 -0.24 * log10(1 + fc); % Delay spread mean /log10(DS) /DS: s
para.DS_sigma = 0.28 + 0.16 * log10( 1 + fc); % delay spread std. / log10(DS)

para.ASD_mu = 1.53 - 0.23 * log10(1 + fc);
para.ASD_sigma = 0.33 + 0.11 * log10(1 + fc);

para.ASA_mu = 1.81 - 0.08 * log10(1 + fc);
para.ASA_sigma = 0.3 + 0.05 * log10 (1 + fc);

para.ESA_mu = 0.92 - 0.04 * log10( 1 + fc);
para.ESA_sigma = 0.41 - 0.07 * log10( 1 + fc);

para.ESD_mu = max(-0.5, -3.1*(d2/1000) + 0.01 * max(h_UE-h_BS,0) + 0.2 );
para.ESD_sigma = 0.35;
para.EOD_off = -10 ^ (-1.5 * log10(max(10,d2) ) +3.3);

para.SF_sigma = 7.82;

para.KF_mu = -100;
para.KF_sigma = 0;

para.XPR_mu = 8; % cross-polarization ratio [dB]
para.XPR_sigma = 3;

% cluster-wise para
para.r_tau = 2.1; % delay scaling parameter
para.ksi_pcsd = 3;  %per cluster shadowing std [dB]
para.N_Cluster = 19;
para.M_ray = 20;

para.c_DS = 11e-9;
para.c_ASD = 10; % [deg]
para.c_ASA = 22;
para.c_ESA = 7;
para.c_ESD = 3/8 * 10^(para.ESD_mu);

% cross-correlation

% decorrelation distance
%  order = [ SF KF DS ASD ASA ESD ESA ]
para.d_dec(1) = 13; % m
para.d_dec(2) = 10; % m
para.d_dec(3) = 10; % m
para.d_dec(4) = 10; % m
para.d_dec(5) = 9; % m
para.d_dec(6) = 10; % m
para.d_dec(7) = 10; % m
% C_MM correlation matrix
% C_MM = order vs order.'
para.C_MM = [ 1   0 -0.7    0 -0.4    0    0; ... % vs SF
              0   1    0    0    0    0    0; ... % vs KF
           -0.7   0    1    0  0.4 -0.5    0; ... % vs DS
              0   0    0    1    0  0.5  0.5; ... % vs ASD
           -0.4   0  0.4    0    1    0  0.2; ... % vs ASA
              0   0 -0.5  0.5    0    1    0; ... % vs ESD
              0   0    0  0.5  0.2    0    1 ];   % vs ESA
         


end