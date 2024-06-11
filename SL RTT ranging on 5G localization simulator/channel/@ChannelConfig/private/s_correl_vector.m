function s_M = s_correl_vector(UE_position, para,Ind_spatconsis, nBS, nUE, norsm);
%s_correl_vector generate multiuser and intra-para correlated s-vector.
%
% Description:
%   This function is used for the function calc_largescalepara only.
%   Functions are according to WINNER II Del. 1.1.2 v.1.2 section 3.3.1.
%   Considering ordered LSP: SF KF DS ASD ASA ESD ESA.
%   Ref 1: Change the channel: a new model for the IMT-advanced system[J].
%   IEEE vehicular technology magazine, 2011.
%   Developer: Jia. Institution: PML. Date: 2021/10/28
M = 7;
h_floor = 3; % floor height
if Ind_spatconsis
    Ind = user_grouping_flr(UE_position,h_floor);
    ksi_M = zeros(M, nBS, nUE);
    for iBS = 1 : nBS
        for igrp = 1 : length(Ind)
            Ind_if = Ind{igrp};
            ksi_M(:,iBS,Ind_if) = calc_cro_correl( UE_position(:,Ind_if), ...
                M, para(iBS,Ind_if(1)).d_dec, norsm);
        end
    end
else
    ksi_M = randn(norsm, M, nBS, nUE);
end
s_M = zeros(M, nBS, nUE);
for iBS = 1 : nBS
    for iUE = 1 : nUE
        Q = sqrtm(para(iBS,iUE).C_MM);
        mu = [0 para(iBS,iUE).KF_mu para(iBS,iUE).DS_mu ...
            para(iBS,iUE).ASD_mu para(iBS,iUE).ASA_mu ...
            para(iBS,iUE).ESD_mu para(iBS,iUE).ESA_mu ].';
        sigma = [para(iBS,iUE).SF_sigma para(iBS,iUE).KF_sigma ...
            para(iBS,iUE).DS_sigma para(iBS,iUE).ASD_sigma ...
            para(iBS,iUE).ASA_sigma para(iBS,iUE).ESD_sigma ...
            para(iBS,iUE).ESA_sigma].';
        s_M_temp = Q * ksi_M(:, iBS, iUE);
        % According to mean ans std of each LSP
        s_M(:,iBS, iUE) = s_M_temp .* sigma + mu;
        s_M(3:end, iBS, iUE) = 10.^(s_M(3:end, iBS, iUE));
    end
end
% Limit random RMS angle spread values to 104 and 52;
s_M(4,:,:) = min(s_M(4,:,:), 104);
s_M(5,:,:) = min(s_M(5,:,:), 104);
s_M(6,:,:) = min(s_M(6,:,:), 52);
s_M(7,:,:) = min(s_M(7,:,:), 52);
end
