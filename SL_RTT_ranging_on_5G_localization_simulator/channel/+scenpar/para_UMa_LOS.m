function para = para_UMa_LOS(center_frequency,d2,h_UE,h_BS);
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
para.DS_mu = -6.955 -0.0963 * log10(fc); % Delay spread mean /log10(DS) /DS: s
para.DS_sigma = 0.66; % delay spread std. / log10(DS)

para.ASD_mu = 1.06 + 0.1114 * log10(fc);
para.ASD_sigma = 0.28;

para.ASA_mu = 1.81;
para.ASA_sigma = 0.20;

para.ESA_mu = 0.95;
para.ESA_sigma = 0.16;

para.ESD_mu = max(-0.5, - 2.1 * (d2/1000) - 0.01*(h_UE-1.5) +0.75);
para.ESD_sigma = 0.40;
para.EOD_off = 0;

para.SF_sigma = 4;

para.KF_mu = 9;
para.KF_sigma = 3.5;

para.XPR_mu = 8; % cross-polarization ratio [dB]
para.XPR_sigma = 4;

% cluster-wise para
para.r_tau = 2.5; % delay scaling parameter
para.ksi_pcsd = 3;  %per cluster shadowing std [dB]
para.N_Cluster = 12;
para.M_ray = 20;

para.c_DS = max(0.25,6.5622 -3.4084 * log10(fc) ) * 1e-9 ;
para.c_ASD = 5; % [deg]
para.c_ASA = 11;
para.c_ESA = 7;
para.c_ESD = 3/8 * 10^(para.ESD_mu);

% cross-correlation

% decorrelation distance
%  order = [ SF KF DS ASD ASA ESD ESA ]
para.d_dec(1) = 37; % m
para.d_dec(2) = 12; % m
para.d_dec(3) = 30; % m
para.d_dec(4) = 18; % m
para.d_dec(5) = 15; % m
para.d_dec(6) = 15; % m
para.d_dec(7) = 15; % m
% C_MM correlation matrix
% C_MM = order vs order.'
para.C_MM = [ 1    0 -0.4 -0.5 -0.5    0 -0.8; ... % vs SF
             0    1 -0.4    0 -0.2    0    0; ... % vs KF
          -0.4 -0.4    1  0.4  0.8 -0.2    0; ... % vs DS
          -0.5    0  0.4    1    0  0.5    0; ... % vs ASD
          -0.5 -0.2  0.8    0    1 -0.3  0.4; ... % vs ASA
             0    0 -0.2  0.5 -0.3    1    0; ... % vs ESD
          -0.8    0    0    0  0.4    0    1 ];   % vs ESA

end