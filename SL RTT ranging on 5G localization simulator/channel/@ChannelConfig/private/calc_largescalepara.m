function lsp = calc_largescalepara(center_frequency, BS_position, ...
    UE_position, Ind_LOS, Ind_spatconsis, Ind_O2I, p_indoor,p_lowloss, ...
    Ind_uplink, scenario, nBS, nUE, norsm, unism);
%calc_largescalepara Generate lsp for specific scenarios.
%
% Description:
%   This function aims to generate  pathloss
%   for specific scenarios according to 3GPP TR 38.901 v16.1.0 2019 --
%   clause 7.5.
%   Developer: Jia. Institution: PML. Date: 2021/10/28
scen = scenario{1,1};
if strcmpi( scen(1:3), 'umi')
    d2inmax = 25; d2outmin = 10; d_dec_LOS = 50;
elseif strcmpi( scen(1:3), 'uma')
    d2inmax = 25; d2outmin = 35; d_dec_LOS = 50;
elseif strcmpi( scen(1:3), 'rma')
    d2inmax = 25; d2outmin = 35; d_dec_LOS = 60;
elseif strcmpi( scen(1:3), 'ind')
    d2inmax = 0; d2outmin = 0; d_dec_LOS = 10;
elseif strcmpi( scen(1:5), 'InF_S')
    d2inmax = 0; d2outmin = 0; d_dec_LOS = 5;
elseif strcmpi( scen(1:5), 'InF_D')
    d2inmax = 0; d2outmin = 0; d_dec_LOS = 1;
end
%---------------------------------
% Height of BSs and UEs
h_UE = abs( UE_position(3,:) );
lsp.h_UE = h_UE;
h_BS = abs( BS_position(3,:) );
lsp.h_BS = h_BS;
% 2-dimension distance calc
Dis2 = sqrt( sum( (permute( BS_position(1:2, :), [2 3 1] ) ...
    -permute( UE_position(1:2, :), [3 2 1]) ).^2, 3 ) );
lsp.Dis2 = Dis2;
% 3-dimension distance calc
Dis3 = sqrt( sum( (permute( BS_position, [2 3 1] ) ...
    -permute( UE_position, [3 2 1]) ).^2, 3 ) );
lsp.Dis3 = Dis3;
% Ground reflection distances
Dis_GR = sqrt( Dis2.^2 + ( permute( abs( BS_position(3,:) ), [2 1] ) ...
    + abs( UE_position(3,:) ) ).^2 );
lsp.Dis_GR = Dis_GR;
lsp.epsilon_GRdiv0 = get_permittivity( center_frequency, 7 );
% Scenarios
lsp.scenario = scenario;% dim: nBS * nUE
%--------------------------------------------------
% O2I states
if (Ind_O2I(1,1) > 1) && ~(strcmpi( scen(1:3), 'ind') ...
        || strcmpi( scen(1:3), 'InF'))
    if Ind_spatconsis
        uni_var_O2I = get_spatconsis_rand(UE_position, 50, 'uniform', norsm);
    else
        uni_var_O2I = rand(unism, 1, nUE);
    end
    Ind_O2I = uni_var_O2I < p_indoor;
elseif (strcmpi( scen(1:3), 'ind') || strcmpi( scen(1:3), 'InF'))
    Ind_O2I = zeros(1, nUE); % no O2I ext. loss.
end
Ind_O2I = logical( Ind_O2I );
lsp.Ind_O2I = Ind_O2I;
% Indoor distances calc.
if Ind_spatconsis
    uni_var1_d2in = get_spatconsis_rand(UE_position, d2inmax, 'uniform', norsm);
    uni_var2_d2in = get_spatconsis_rand(UE_position, d2inmax, 'uniform', norsm);
else
    uni_var1_d2in = rand(unism, 1, nUE) * d2inmax;
    uni_var2_d2in = rand(unism, 1, nUE) * d2inmax;
end
Dis2in = min(uni_var1_d2in,uni_var2_d2in);
Dis2in( Ind_O2I ~= 1 ) = 0;
Dis2out = Dis2 - Dis2in;
Dis2out( Dis2out <= d2outmin ) = d2outmin;
Dis3in = Dis2in ./ Dis2 .* Dis3;
Dis3out = Dis3 - Dis3in;
lsp.Dis2out = Dis2out;
lsp.Dis3out = Dis3out;
% LOS states
if (Ind_LOS(1,1) > 1) && Ind_spatconsis
    for iBS = 1 : nBS
        uni_var = zeros(1,nUE);
        uni_var(Ind_O2I) = get_spatconsis_rand( UE_position(:,Ind_O2I)...
            , d_dec_LOS, 'uniform', norsm );
        uni_var(~Ind_O2I) = get_spatconsis_rand( UE_position(:,~Ind_O2I) ...
            , d_dec_LOS, 'uniform', norsm );
        p_LOS = get_Pr_LOS( scen, Dis2out(iBS, :), h_UE, h_BS(iBS) );
        Ind_LOS_pBS = uni_var < p_LOS;
        Ind_LOS(iBS,:) = Ind_LOS_pBS;
    end
elseif (Ind_LOS(1,1) > 1) && ~Ind_spatconsis
    p_LOS = get_Pr_LOS( scen, Dis2out, h_UE, h_BS );
    uni_var = rand(unism, nBS, nUE);
    Ind_LOS = uni_var < p_LOS;
end
lsp.Ind_LOS = Ind_LOS; % dim: nBS * nUE
% O2I penetration.
if Ind_spatconsis
    uni_var_lowloss = get_spatconsis_rand( UE_position(:,Ind_O2I), 50,...
        'uniform', norsm );
else
    uni_var_lowloss = rand(unism, 1, sum(Ind_O2I));
end
Ind_lowloss = logical( uni_var_lowloss < p_lowloss );
O2Iloss_dB = zeros(1, nUE);
O2Iloss_dB(Ind_O2I) = get_O2I_PenLoss(UE_position(:,Ind_O2I), ...
    center_frequency, Dis2in(1, Ind_O2I), Ind_lowloss, Ind_spatconsis, norsm);
O2Iloss_dB = repmat(O2Iloss_dB, nBS, 1);
lsp.O2Iloss_dB = O2Iloss_dB;
% Paras for scenarios
para = gen_scenario_para(center_frequency, scenario, Ind_LOS, Ind_O2I, ...
   Ind_uplink, Dis2out, h_BS, h_UE, nBS, nUE );
lsp.para = para;
% Pathloss calc
[pathloss_dB, ~] = calc_pathloss_db(center_frequency, Dis3, Dis2, scenario, ...
    Ind_LOS, h_BS, h_UE, nBS, nUE );
lsp.pathloss_dB = pathloss_dB;
% Generate LSPs, i.e., SF KF DS ASD ASA ESD ESA.
[lspar, s_M] = get_ls_paras(UE_position, para, Ind_spatconsis, Ind_uplink, nBS, nUE,norsm );
lsp.lspar = lspar; 
% Gainloss for Step11
lsp.gainloss_dB = permute(s_M(1,:,:),[2 3 1]) + pathloss_dB + O2Iloss_dB;
end
