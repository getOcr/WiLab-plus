function para = gen_scenario_para(center_frequency, scenario, Ind_LOS, ...
    Ind_O2I, Ind_uplink, Dis2, h_BS, h_UE, nBS, nUE );
%gen_scenario_para Generate paras of statistical characteristics.
%
% Description:
%   This function aims to generate  paras of statistical characteristics
%   for specific scenarios according to 3GPP TR 38.901 v16.1.0 2019 --
%   Table 7.5-6 -- 7.5-11.
%
% Developer: Jia. Institution: PML. Date: 2021/10/28
% addpath channel/@ChannelcoeffGen/private/scenarios_para;
para(2,2) = scenpar.para_RMa_LOS(2e9,5,1,3);
for iBS = 1 : nBS
    for iUE = 1 : nUE
        scenar = scenario{iBS, iUE};
        Ind_O2I_p = Ind_O2I( iUE);
        if strcmpi(scenar(1:3), 'RMa')
            if Ind_O2I_p
                para(iBS, iUE) = scenpar.para_RMa_O2I(center_frequency, ...
                    Dis2(iBS, iUE), h_UE(iUE), h_BS(iBS) );
            elseif Ind_LOS(iBS, iUE)
                para(iBS, iUE) = scenpar.para_RMa_LOS(center_frequency, ...
                    Dis2(iBS, iUE), h_UE(iUE), h_BS(iBS) );
            else
                para(iBS, iUE) = scenpar.para_RMa_NLOS(center_frequency, ...
                    Dis2(iBS, iUE), h_UE(iUE), h_BS(iBS) );
            end
        elseif strcmpi(scenar(1:3), 'UMa')
            if Ind_O2I_p
                if Ind_LOS(iBS, iUE)
                    para(iBS, iUE) = scenpar.para_UMa_LOS_O2I(center_frequency, ...
                        Dis2(iBS, iUE), h_UE(iUE), h_BS(iBS) );
                else
                    para(iBS, iUE) = scenpar.para_UMa_NLOS_O2I(center_frequency, ...
                        Dis2(iBS, iUE), h_UE(iUE), h_BS(iBS) );
                end
            else
                if Ind_LOS(iBS, iUE)
                    para(iBS, iUE) = scenpar.para_UMa_LOS(center_frequency, ...
                        Dis2(iBS, iUE), h_UE(iUE), h_BS(iBS) );
                else
                    para(iBS, iUE) = scenpar.para_UMa_NLOS(center_frequency, ...
                        Dis2(iBS, iUE), h_UE(iUE), h_BS(iBS) );
                end
            end
        elseif strcmpi(scenar(1:3), 'UMi')
            if Ind_O2I_p
                if Ind_LOS(iBS, iUE)
                    para(iBS, iUE) = scenpar.para_UMi_LOS_O2I(center_frequency, ...
                        Dis2(iBS, iUE), h_UE(iUE), h_BS(iBS) );
                else
                    para(iBS, iUE) = scenpar.para_UMi_NLOS_O2I(center_frequency, ...
                        Dis2(iBS, iUE), h_UE(iUE), h_BS(iBS) );
                end
            else
                if Ind_LOS(iBS, iUE)
                    para(iBS, iUE) = scenpar.para_UMi_LOS(center_frequency, ...
                        Dis2(iBS, iUE), h_UE(iUE), h_BS(iBS) );
                else
                    para(iBS, iUE) = scenpar.para_UMi_NLOS(center_frequency, ...
                        Dis2(iBS, iUE), h_UE(iUE), h_BS(iBS) );
                end
            end
        elseif strcmpi(scenar(1:3), 'InF')
            if Ind_LOS(iBS, iUE)
                para(iBS, iUE) = scenpar.para_InF_LOS( center_frequency );
            else
                para(iBS, iUE) = scenpar.para_InF_NLOS(center_frequency, scenar(5:6));
            end
        elseif strcmpi(scenar(1:6), 'Indoor')
            if Ind_LOS(iBS, iUE)
                para(iBS, iUE) = scenpar.para_Indoor_LOS(center_frequency );
            else
                para(iBS, iUE) = scenpar.para_Indoor_NLOS(center_frequency );
            end
        end
    end
end
for iBS = 1 : nBS
    for iUE = 1 : nUE
        % ---------------
        % Swapping arrival and departure parameters for the uplink case.
        if Ind_uplink
            temp = para(iBS, iUE).c_ASA;
            para(iBS, iUE).c_ASA = para(iBS, iUE).c_ASD;
            para(iBS, iUE).c_ASD = temp;
            
            temp = para(iBS, iUE).c_ESA;
            para(iBS, iUE).c_ESA = para(iBS, iUE).c_ESD;
            para(iBS, iUE).c_ESD = temp;
            
            temp = para(iBS, iUE).ESA_mu;
            para(iBS, iUE).EOA_off = para(iBS, iUE).EOD_off;
            para(iBS, iUE).ESA_mu = para(iBS, iUE).ESD_mu;
            
            para(iBS, iUE).ESD_mu = temp;
            para(iBS, iUE).EOD_off =[];
        end
    end
end
end