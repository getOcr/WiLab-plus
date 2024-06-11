function para = para_Indoor_LOS_old(center_frequency);
% 3GPP 38.900 v16.0 table 7.5-6

% Application range.

% 3-d distance:         [1 150] m
% center frequency:     [0.5 100] GHz
fc = center_frequency / 1e9;
if fc <= 6
    fc = 6;
end
% LSP para mean and std
para.DS_mu = -7.79 -0.01 * log10(1 + fc); % Delay spread mean /log10(DS) /DS: s
para.DS_sigma = 0.50 - 0.16 * log10(1 + fc); % delay spread std. / log10(DS)

para.ASD_mu = 1.60;
para.ASD_sigma = 0.18;

para.ASA_mu = 1.86 - 0.19 * log10(1 + fc);
para.ASA_sigma =  0.12 * log10 (1 + fc);

para.ESA_mu = 1.21 - 0.26 * log10( 1 + fc);
para.ESA_sigma = 0.17 - 0.04 * log10( 1 + fc);

para.ESD_mu = 2.228 - 1.43 * log10(1 + fc);
para.ESD_sigma = 0.30 + 0.13 * log10( 1 + fc);
para.EOD_off = 0;

para.SF_sigma = 3;

para.KF_mu = 2.12 + 0.84 * log10(1 + fc);
para.KF_sigma = 6.19 - 0.58 * log10(1 + fc);

para.XPR_mu = 15; % cross-polarization ratio [dB]
para.XPR_sigma = 3;

% cluster-wise para
para.r_tau = 2.15; % delay scaling parameter
para.ksi_pcsd = 6;  %per cluster shadowing std [dB]
para.N_Cluster = 8;
para.M_ray = 20;

para.c_DS = 3.91e-9;
para.c_ASD = 7; % [deg]
para.c_ASA = 16.72 - 6.2 * log10(1 + fc);
para.c_ESA = 10.28 - 3.85 * log10(1 + fc);
para.c_ESD = 3/8 * 10^(para.ESD_mu);

% cross-correlation

% decorrelation distance
%  order = [ SF KF DS ASD ASA ESD ESA ]
para.d_dec(1) = 10; % m
para.d_dec(2) = 4; % m
para.d_dec(3) = 8; % m
para.d_dec(4) = 7; % m
para.d_dec(5) = 5; % m
para.d_dec(6) = 3; % m
para.d_dec(7) = 3; % m
% C_MM correlation matrix
% C_MM = order vs order.'
para.C_MM = [1   0.5  -0.8  -0.4  -0.5   0.2 -0.1; ... % vs SF
          0.5     1  -0.5     0     0     0   0.1; ... % vs KF
         -0.8  -0.5     1   0.6   0.8   0.1   0.2; ... % vs DS
         -0.4     0   0.6     1   0.4   0.2   0.2; ... % vs ASD
         -0.5     0   0.8   0.4     1   0.1   0.3; ... % vs ASA
          0.2     0   0.1   0.2   0.1     1   0.2; ... % vs ESD
         -0.1   0.1   0.2   0.2   0.3   0.2     1];    % vs ESA



end