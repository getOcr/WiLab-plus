function para = para_UMi_LOS(center_frequency,d2,h_UE,h_BS);
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
para.DS_mu = -7.14 -0.24 * log10(1 + fc); % Delay spread mean /log10(DS) /DS: s
para.DS_sigma = 0.38; % delay spread std. / log10(DS)

para.ASD_mu = 1.21 - 0.05 * log10(1 + fc);
para.ASD_sigma = 0.41;

para.ASA_mu = 1.73 - 0.08 * log10(1 + fc);
para.ASA_sigma = 0.28 + 0.014 * log10 (1 + fc);

para.ESA_mu = 0.73 - 0.1 * log10( 1 + fc);
para.ESA_sigma = 0.34 - 0.04 * log10( 1 + fc);

para.ESD_mu = max(-0.21, -14.8*(d2/1000) + 0.01 * abs(h_UE-h_BS) + 0.83 );
para.ESD_sigma = 0.35;
para.EOD_off = 0;

para.SF_sigma = 4;

para.KF_mu = 9;
para.KF_sigma = 5;

para.XPR_mu = 9; % cross-polarization ratio [dB]
para.XPR_sigma = 3;

% cluster-wise para
para.r_tau = 3; % delay scaling parameter
para.ksi_pcsd = 3;  %per cluster shadowing std [dB]
para.N_Cluster = 12;
para.M_ray = 20;

para.c_DS = 5e-9;
para.c_ASD = 3; % [deg]
para.c_ASA = 17;
para.c_ESA = 7;
para.c_ESD = 3/8 * 10^(para.ESD_mu);

% cross-correlation

% decorrelation distance
%  order = [ SF KF DS ASD ASA ESD ESA ]
para.d_dec(1) = 10; % m
para.d_dec(2) = 15; % m
para.d_dec(3) = 7; % m
para.d_dec(4) = 8; % m
para.d_dec(5) = 8; % m
para.d_dec(6) = 12; % m
para.d_dec(7) = 12; % m
% C_MM correlation matrix
% C_MM = order vs order.'
para.C_MM = [   1   0.5  -0.4  -0.5  -0.4     0     0 ; ... % vs SF
             0.5     1  -0.7  -0.2  -0.3     0     0 ; ... % vs KF
            -0.4  -0.7     1   0.5   0.8     0   0.2 ; ... % vs DS
            -0.5  -0.2   0.5     1   0.4   0.5   0.3 ; ... % vs ASD
            -0.4  -0.3   0.8   0.4     1     0     0 ; ... % vs ASA
               0     0     0   0.5     0     1     0 ; ... % vs ESD
               0     0   0.2   0.3     0     0     1 ];    % vs ESA
         


end