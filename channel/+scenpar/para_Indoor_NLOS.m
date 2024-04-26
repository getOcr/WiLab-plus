function para = para_Indoor_NLOS(center_frequency);
% 3GPP 38.901 v16.0 table 7.5-6
 
% Application range.

% 3-d distance:         [1 150] m
% center frequency:     [0.5 100] GHz
fc = center_frequency / 1e9;
if fc <= 6
    fc = 6;
end
% LSP para mean and std
para.DS_mu = -7.173 -0.28 * log10(1 + fc); % Delay spread mean /log10(DS) /DS: s
para.DS_sigma = 0.055 + 0.10 * log10(1 + fc); % delay spread std. / log10(DS)

para.ASD_mu = 1.62;
para.ASD_sigma = 0.25;

para.ASA_mu = 1.863 - 0.11 * log10(1 + fc);
para.ASA_sigma = 0.059 + 0.12 * log10(1 + fc);

para.ESA_mu = 1.387 - 0.15 * log10( 1 + fc);
para.ESA_sigma = 0.746 - 0.09 * log10( 1 + fc);

para.ESD_mu = 1.08;
para.ESD_sigma = 0.36;
para.EOD_off = 0;

para.SF_sigma = 8.03;

para.KF_mu = -100;
para.KF_sigma = 0;

para.XPR_mu = 10; % cross-polarization ratio [dB]
para.XPR_sigma = 4;

% cluster-wise para
para.r_tau = 3; % delay scaling parameter
para.ksi_pcsd = 3;  %per cluster shadowing std [dB]
para.N_Cluster = 19;
para.M_ray = 20;

para.c_DS = 3.91e-9;
para.c_ASD = 5; % [deg]
para.c_ASA = 11;
para.c_ESA = 9;
para.c_ESD = 3/8 * 10^(para.ESD_mu);

% cross-correlation

% decorrelation distance
%  order = [ SF KF DS ASD ASA ESD ESA ]
para.d_dec(1) = 6; % m
para.d_dec(2) = 4; % m  % for calc
para.d_dec(3) = 5; % m
para.d_dec(4) = 3; % m
para.d_dec(5) = 3; % m
para.d_dec(6) = 4; % m
para.d_dec(7) = 4; % m
% C_MM correlation matrix
% C_MM = order vs order.'
para.C_MM = [1    0   -0.5    0  -0.4     0     0; ... % vs SF
            0    1      0    0     0     0     0; ... % vs KF
         -0.5    0      1  0.4     0 -0.27 -0.06; ... % vs DS
            0    0    0.4    1     0  0.35  0.23; ... % vs ASD
         -0.4    0      0    0     1 -0.08  0.43; ... % vs ASA
            0    0  -0.27 0.35 -0.08     1  0.42; ... % vs ESD
            0    0  -0.06 0.23  0.43  0.42     1]; % vs ESA



end