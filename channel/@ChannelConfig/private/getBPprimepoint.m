function d_BP_prime = getBPprimepoint(fc,h_BS, h_UE, d2, scenario );
%getBPprimepoint
% This function is only used for the function calc_pathloss_db.
% Functions are according to 3GPP TR 38.901 v16.1.0 2019 --
% clause 7.4.1 notes.

if strcmpi(scenario(1:3),'RMa')
    d_BP_prime = 2* pi * h_BS * max(h_UE,1) * fc *1e9 / 3e8;
else
    % according to the TR 38.901-table 7.4.1-1 note1
    if strcmpi(scenario(1:3),'UMi')
        h_E = 1;
    elseif strcmpi(scenario(1:3),'UMa')
        h_E = get_h_E(h_UE,d2);
    end
    h_BS_p = h_BS-h_E;
    h_UE_p = h_UE-h_E;
    d_BP_prime = 4 * h_BS_p * h_UE_p * fc * 1e9 / 3e8;
end
%---------------
% sub-function
    function h_E = get_h_E(h_UE, d2);
        %according to the TR 38.901-table 7.4.1-1 note1 for UMa.
        if d2 <= 18
            g_d2 =0;
        else
            g_d2 = 5/4 * (d2/100)^3 * exp(-d2/150);
        end
        if h_UE <13
            C =0;
        elseif h_UE >= 13 && h_UE <=23
            C = ( (h_UE-13)/10 )^1.5 * g_d2;
        else
            error('P_c:h_UE <= 23.');
        end
        P_c = 1/(1 + C);
        Ind = randsrc(1,1,[1 0; P_c (1- P_c)] );
        tuple = [12 15 18 21];
        tuple = tuple( tuple <= ( h_UE - 1.5 ) );
        if Ind == 1
            h_E = 1;
        else
            h_E = randsrc(1, 1, tuple );
        end
    end
end