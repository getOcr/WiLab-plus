function para = para_RMa_NLOS(center_frequency,d2,h_UE,h_BS);
% 3GPP 38.901 v16.0 table 7.5-6
% 
% Application range.

% 2-d distance:         [10 10000] m
% center frequency:     [0.5 7] GHz
% user antenna height:  [1.5 22.5] m
% BS antenna height:    [10 150] m


% LSP para mean and std
para.DS_mu = -7.43; % Delay spread mean /log10(DS) /DS: s
para.DS_sigma = 0.48; % delay spread std. / log10(DS)

para.ASD_mu = 0.95;
para.ASD_sigma = 0.45;

para.ASA_mu = 1.52;
para.ASA_sigma = 0.13;

para.ESA_mu = 0.58;
para.ESA_sigma = 0.37;

para.ESD_mu = max(-1, - 0.19 * (d2/1000) - 0.01*(h_UE-1.5) +0.28);
para.ESD_sigma = 0.30; 
para.EOD_off = atan( (35-3.5)/d2 ) - atan( (35-1.5)/d2 );

para.SF_sigma = 8;

para.KF_mu = -100;
para.KF_sigma = 0;

para.XPR_mu = 7; % cross-polarization ratio [dB]
para.XPR_sigma = 3;

% cluster-wise para
para.r_tau = 1.7; % delay scaling parameter
para.ksi_pcsd = 3;  %per cluster shadowing std [dB]
para.N_Cluster = 10;
para.M_ray = 20;

para.c_DS = 3.91e-9;
para.c_ASD = 2; % [deg]
para.c_ASA = 3;
para.c_ESA = 3;
para.c_ESD = 3/8 * 10^(para.ESD_mu);

% cross-correlation

% decorrelation distance
%  order = [ SF KF DS ASD ASA ESD ESA ]
para.d_dec(1) = 120; % m
para.d_dec(2) = 40; % m
para.d_dec(3) = 36; % m
para.d_dec(4) = 30; % m
para.d_dec(5) = 40; % m
para.d_dec(6) = 50; % m
para.d_dec(7) = 50; % m
% C_MM correlation matrix
% C_MM = order vs order.'
para.C_MM = [1    0 -0.5   0.6     0 -0.04 -0.25; ... % vs SF
            0    1    0     0     0     0     0; ... % vs KF
         -0.5    0    1  -0.4     0  -0.1  -0.4; ... % vs DS
          0.6    0 -0.4     1     0  0.42 -0.27; ... % vs ASD
            0    0    0     0     1 -0.18  0.26; ... % vs ASA
        -0.04    0 -0.1  0.42 -0.18     1 -0.27; ... % vs ESD
        -0.25    0 -0.4 -0.27  0.26 -0.27    1]; % vs ESA



end