function [pathlos_dB, sigma_sf] = calc_pathloss_db(center_frequency, Dis3, ...
    Dis2, scenario, Ind_LOS, h_BS, h_UE, nBS, nUE );
%calc_pathloss_db Generate pathloss for specific scenarios.
%
% Description:
%   This function aims to generate  pathloss
%   for specific scenarios according to 3GPP TR 38.901 v16.1.0 2019 --
%   clause 7.4.1.
%
% Developer: Jia. Institution: PML. Date: 2021/10/28

pathlos_dB = zeros(nBS,nUE);
sigma_sf = zeros(nBS,nUE);
fc = center_frequency/1e9;

for iBS = 1 : nBS
    for iUE = 1 : nUE
        %-------------------------
        d2 = Dis2(iBS, iUE);
        d3 = Dis3(iBS, iUE);
        scenario_s = scenario{iBS, iUE};
        Ind_LOS_s = Ind_LOS(iBS, iUE);
        h_BS_s = h_BS( iBS );
        h_UE_s = h_UE( iUE );
        %--------------------------
        if strcmpi(scenario_s(1:3), 'RMa')
            d_BP = getBPprimepoint(fc, h_BS_s, h_UE_s, d2, scenario_s);
            h = 5; % building height [5 50]
            W = 20; % street width [5 50]
            if d2 >=10 && d2 <= d_BP
                pathloss_LOS_dB = 20* log10( 40* pi* d3 * fc /3) ...
                    + min( 0.03 * h^1.72, 10 ) * log10( d3 ) ...
                    - min( 0.044 * h^1.72, 14.77 ) + 0.002 * log10(h) * d3;
                sigma_SF1 = 4;
            elseif d2 >= d_BP && d2 <= 10e3
                pathloss1 = 20 * log10( 40 * pi * d_BP * fc /3) ...
                    + min( 0.03 * h^1.72, 10 ) * log10( d_BP ) ...
                    -min( 0.044 * h^1.72, 14.77 ) + 0.002 * log10( h ) *d_BP;
                pathloss_LOS_dB = pathloss1 + 40 * log10( d3 / d_BP );
                sigma_SF1 = 6;
            else
                error('pathloss.RMa: d2 must be in [10 10e3].');
            end
            if d2 >= 10 && d2 <= 5e3
                pathloss1 = 161.04 - 7.1 * log10(W) + 7.5 *log10(h) ...
                    - (24.37 - 3.7* ( h/h_BS_s )^2 ) * log10(h_BS_s) ...
                    + ( 43.42 - 3.1*log10( h_BS_s ) ) *( log10(d3) -3 )...
                    + 20*log10(fc) - ( 3.2 * ( log10(11.75 * h_UE_s) )^2 -4.97 );
                pathloss_NLOS_dB = max( pathloss_LOS_dB, pathloss1 );
                sigma_SF1 = 8;
            else
                if ~Ind_LOS_s
                    error('pathloss.RMa: d2 must be in [10 5e3].');
                end
            end
            if Ind_LOS_s
                pathloss_dB = pathloss_LOS_dB;
            else
                pathloss_dB = pathloss_NLOS_dB;
            end
            sigma_SF = sigma_SF1;
        elseif strcmpi(scenario_s(1:3),'UMa')
            d_BP = getBPprimepoint( fc, h_BS_s, h_UE_s, d2, scenario_s );
            if d2 <= d_BP && d2 >= 10
                pathloss_LOS_dB = 28 +  22 * log10(d3) + 20 * log10(fc);
            elseif d2 >= d_BP && d2 <= 5e3
                pathloss_LOS_dB = 28 +  40 * log10(d3) + 20*log10(fc) ...
                    - 9 * log10( d_BP^2 + ( h_BS_s - h_UE_s )^2 );
            end
            if d2 >= 10 && d2 <= 5e3
                pathloss1 = 13.54 + 39.08 * log10(d3) + 20 *log10(fc) ...
                    - 0.6 * ( h_UE_s - 1.5 );
                pathloss_NLOS_dB = max( pathloss_LOS_dB, pathloss1 );
            else
                error('pathloss.UMa: d2 must be in [10 5e3].');
            end
            if Ind_LOS_s
                pathloss_dB = pathloss_LOS_dB;
                sigma_SF = 4;
            else
                pathloss_dB = pathloss_NLOS_dB;
                sigma_SF = 6;
                % optional:pathloss_dB = 32.4 + 20 * log10(fc) + 30 *...
                % log10(d3);sigma_SF = 7.8;
            end
        elseif strcmpi( scenario_s(1:3), 'UMi' )  % street canyon
            d_BP = getBPprimepoint( fc, h_BS_s, h_UE_s, d2, scenario_s );
            if d2 <= d_BP && d2 >= 10
                pathloss_LOS_dB = 32.4 + 21*log10(d3) + 20*log10(fc);
            elseif d2 >= d_BP && d2 <= 5e3
                pathloss_LOS_dB = 32.4 + 40*log10(d3) + 20*log10(fc) ...
                    - 9.5*log10( d_BP^2 + ( h_BS_s - h_UE_s )^2 );
            end
            if d2 >= 10 && d2 <= 5e3
                pathloss1 = 35.3 * log10(d3) + 22.4 + 21.3 * log10(fc) ...
                    - 0.3 * ( h_UE_s - 1.5 );
                pathloss_NLOS_dB = max(pathloss1, pathloss_LOS_dB);
            else
                error('pathloss.UMi: d2 must be in [10 5e3].');
            end
            if Ind_LOS_s
                pathloss_dB = pathloss_LOS_dB;
                sigma_SF = 4;
            else
                pathloss_dB = pathloss_NLOS_dB;
                sigma_SF = 7.82;
                % optional: pathloss_dB = 32.4 + 20*log10(fc) + 31.9*log10(d3);
                % sigma_SF = 8.2;
            end
        elseif length(scenario_s) >= 6 && strcmpi(scenario_s(1:6),'Indoor')
            % InH-office
            pathloss_LOS_dB = 32.4 + 17.3 * log10(d3) + 20 * log10(fc);
            pathloss1 = 38.3 * log10(d3) + 17.3 + 24.9 * log10(fc);
            pathloss_NLOS_dB = max(pathloss1, pathloss_LOS_dB);
            if Ind_LOS_s
                pathloss_dB = pathloss_LOS_dB;
                sigma_SF = 3;
            else
                pathloss_dB = pathloss_NLOS_dB;
                sigma_SF = 8.03;
                % optional: pathloss_dB = 32.4 + 20*log10(fc) + 31.9*log10(d3);
                % sigma_SF = 8.29;
            end
        elseif strcmpi(scenario_s(1:3), 'InF') % need to be modified
            
            pathloss_LOS_dB = 31.84 + 21.50*log10(d3) +19.00 * log10(fc);
            sigma_SF1 = 4;
            if length(scenario_s) >= 6
                if strcmpi( scenario_s(5:6), 'SL') % InF_SL
                    pathloss1 = 33 +25.5 * log10( d3 ) + 20 * log10( fc );
                    sigma_SF1 = 5.7;
                elseif strcmpi( scenario_s(5:6), 'DL') % InF_DL
                    pathloss1 = 18.6 +35.7 * log10( d3 ) + 20 * log10( fc );
                    sigma_SF1 = 7.2;
                elseif strcmpi( scenario_s(5:6), 'SH') % InF_SH
                    pathloss1 = 32.4 + 23 * log10( d3 ) + 20 * log10( fc );
                    sigma_SF1 = 5.9;
                elseif strcmpi( scenario_s(5:6), 'DH') % InF_DH
                    pathloss1 = 33.63 + 21.9 * log10( d3 ) + 20 *log10( fc );
                    sigma_SF1 = 4.0;
                end
            end
            if Ind_LOS_s
                pathloss_dB = pathloss_LOS_dB;               
            else
                pathloss_NLOS_dB = max(pathloss1, pathloss_LOS_dB);
                pathloss_dB = pathloss_NLOS_dB;
            end
            sigma_SF = sigma_SF1;
        end
        pathlos_dB(iBS, iUE) = pathloss_dB;
        sigma_sf(iBS, iUE) = sigma_SF;
    end
    
    
end
end
