function O2Iloss_ext = get_O2I_PenLoss(UE_position, center_frequency, ...
    d2_in, Ind_lowloss, Ind_spatconsis, norsm);
%get_O2I_PenLoss
% According to the TR38.901 7.4.3.
subscen = 1;
%PL_tw % ext wall
%PL_in % into building
if subscen == 1 % O2I building penetration loss
    fc = center_frequency / 1e9;
    L_glass = 2 + 0.2 *fc;
    L_IIRg = 23 + 0.3 *fc;
    L_concrete = 5 + 4 *fc;
    %     L_wood = 4.85 + 0.12 * fc;
    PL_tw_low = 5 - 10 * log10(0.3 * 10^(- L_glass /10 ) + 0.7 * ...
        10^( - L_concrete /10) );
    PL_tw_high = 5 - 10 * log10(0.7 * 10^(- L_IIRg /10 ) + 0.3 * ...
        10^( - L_concrete /10) );
    O2IPL_ext = PL_tw_low * (Ind_lowloss) + PL_tw_high * (~Ind_lowloss) + ...
        0.5 * d2_in;
    norm_var = randn(norsm, 1, length(Ind_lowloss));
    if Ind_spatconsis
        norm_var(Ind_lowloss) = get_spatconsis_rand( ...
            UE_position(:,Ind_lowloss), 50, 'normal',norsm );
        norm_var(~Ind_lowloss) = get_spatconsis_rand( ...
            UE_position(:,~Ind_lowloss), 50, 'normal',norsm );
    end
    O2ISF_ext = norm_var .* (4.4 * Ind_lowloss + 6.5 * ~Ind_lowloss);
    O2Iloss_ext = O2IPL_ext + O2ISF_ext;
elseif subscen == 2 % O2I car penetration loss
    mu = 9; sigma_p = 5; %optional: mu =20 for metallized car window.
    norm_var = randn(norsm, 1, length(d2_in));
    if Ind_spatconsis
        norm_var = get_spatconsis_rand( UE_position, 50, 'normal',norsm );
    end
    O2Iloss_ext = norm_var * sigma_p + mu;
end
end