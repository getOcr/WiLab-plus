function para = para_RMa_LOS(center_frequency,d2,h_UE,h_BS);
% 3GPP 38.901 v16.0 table 7.5-6
% 
% Application range.

% 2-d distance:         [10 10000] m
% center frequency:     [0.5 7] GHz
% user antenna height:  [1.5 22.5] m
% BS antenna height:    [10 150] m


% LSP para mean and std
para.DS_mu = -7.49; % Delay spread mean /log10(DS) /DS: s
para.DS_sigma = 0.55; % delay spread std. / log10(DS)

para.ASD_mu = 0.9;
para.ASD_sigma = 0.38;

para.ASA_mu = 1.52;
para.ASA_sigma = 0.24;

para.ESA_mu = 0.47;
para.ESA_sigma = 0.4;


para.ESD_mu = max(-1, - 0.17 * (d2/1000) - 0.01*(h_UE-1.5) +0.22);
para.ESD_sigma = 0.34;
para.EOD_off = 0;

para.SF_sigma = 5;

para.KF_mu = 7;
para.KF_sigma = 4;

para.XPR_mu = 12; % cross-polarization ratio [dB]
para.XPR_sigma = 4;

% cluster-wise para
para.r_tau = 3.8; % delay scaling parameter
para.ksi_pcsd = 3;  %per cluster shadowing std [dB]
para.N_Cluster = 11;
para.M_ray = 20;

para.c_DS = 3.91e-9;
para.c_ASD = 2; % [deg]
para.c_ASA = 3;
para.c_ESA = 3;
para.c_ESD = 3/8 * 10^(para.ESD_mu);

% cross-correlation

% decorrelation distance
%  order = [ SF KF DS ASD ASA ESD ESA ]
para.d_dec(1) = 37; % m
para.d_dec(2) = 40; % m
para.d_dec(3) = 50; % m
para.d_dec(4) = 25; % m
para.d_dec(5) = 35; % m
para.d_dec(6) = 15; % m
para.d_dec(7) = 15; % m
% C_MM correlation matrix
% C_MM = order vs order.'
para.C_MM = [1     0  -0.5     0     0  0.01 -0.17; ... % vs SF
            0     1     0     0     0     0 -0.02; ... % vs KF
         -0.5     0     1     0     0 -0.05  0.27; ... % vs DS
            0     0     0     1     0  0.73 -0.14; ... % vs ASD
            0     0     0     0     1  -0.2  0.24; ... % vs ASA
         0.01     0 -0.05  0.73  -0.2     1 -0.07; ... % vs ESD
        -0.17 -0.02  0.27 -0.14  0.24 -0.07     1]; % vs ESA

end