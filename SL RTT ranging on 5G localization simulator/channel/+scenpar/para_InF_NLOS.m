function para = para_InF_NLOS(center_frequency,scenar);
% 3GPP 38.901 v16.0 table 7.5-6
% 
% Application range.

% 3-d distance:         [1 600] m
% center frequency:     [0.5 100] GHz
fc = center_frequency / 1e9;

% LSP para mean and std
% DS spread log10(30(V/S) + 32) -9.44
% According to 3GPP TR 38.857, two Rooms are defined.
% Case 1: W = 60 L = 120 h =10  V = 72000 m3 and s = 18000 m2 >> DS = -7.2582
% Case 2: W = 150 L = 300 h =10  V = 450000 m3 and s = 99000 m2 >> DS = -7.2138
% Case 1 will be the baseline for sparse clutter
% Case 2 will be the baseline for dense clutter

para.DS_mu = -7.2138; % Case 2 is considered
para.DS_sigma = 0.19; % delay spread std. / log10(DS)

para.ASD_mu = 1.57;
para.ASD_sigma = 0.20;

para.ASA_mu = 1.72;
para.ASA_sigma = 0.3;

para.ESA_mu = 1.45 - 0.13 * log10( 1 + fc);
para.ESA_sigma = 0.45;

para.ESD_mu = 1.2;
para.ESD_sigma = 0.55;
para.EOD_off = 0;

if strcmpi(scenar, 'SL')
    para.SF_sigma = 5.7;
elseif strcmpi(scenar, 'SH')
    para.SF_sigma = 5.9;
elseif strcmpi(scenar, 'DL')
    para.SF_sigma = 7.2;
elseif strcmpi(scenar, 'DH')
    para.SF_sigma = 4.0;
end

para.KF_mu = -100;
para.KF_sigma = 0;

para.XPR_mu = 11; % cross-polarization ratio [dB]
para.XPR_sigma = 6;

% cluster-wise para
para.r_tau = 3; % delay scaling parameter
para.ksi_pcsd = 3;  %per cluster shadowing std [dB]
para.N_Cluster = 25;
para.M_ray = 20;

para.c_DS = 3.91e-9;
para.c_ASD = 5; % [deg]
para.c_ASA = 8;
para.c_ESA = 9;
para.c_ESD = 3/8 * 10^(para.ESD_mu);

% cross-correlation

% decorrelation distance
%  order = [ SF KF DS ASD ASA ESD ESA ]
para.d_dec(1) = 10; % m
para.d_dec(2) = 10; % m
para.d_dec(3) = 10; % m
para.d_dec(4) = 10; % m
para.d_dec(5) = 10; % m
para.d_dec(6) = 10; % m
para.d_dec(7) = 10; % m
% C_MM correlation matrix
% C_MM = order vs order.'
para.C_MM = [1 0 0 0 0 0 0; ... % vs SF
     0 1 0 0 0 0 0; ... % vs KF
    0 0 1 0 0 0 0; ... % vs DS
    0 0 0 1 0 0 0; ... % vs ASD
    0 0 0 0 1 0 0; ... % vs ASA
    0 0 0 0 0 1 0; ... % vs ESD
    0 0 0 0 0 0 1]; % vs ESA



end