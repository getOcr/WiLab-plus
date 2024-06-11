function [out, s_M] = get_ls_paras(UE_position, para, Ind_spatconsis, ...
    Ind_uplink, nBS, nUE, norsm );
%get_ls_paras generate LSPs, i.e., SF KF DS ASD ASA ESD ESA.
% Lsps s-vector calc
% s_M = [s_SF s_K s_DS s_ASD s_ASA s_ESD s_ESA ].'
s_M = s_correl_vector(UE_position, para, Ind_spatconsis, nBS, nUE, norsm );
% Init.
out(nBS,nUE).SF = s_M(1,nBS, nUE);
for iBS = 1 : nBS
    for iUE = 1 : nUE
        out(iBS, iUE).SF = s_M(1, iBS, iUE);
        out(iBS, iUE).KF = s_M(2, iBS, iUE);
        out(iBS, iUE).DS = s_M(3, iBS, iUE);
        if Ind_uplink
            out(iBS, iUE).ASA = s_M(4, iBS, iUE);
            out(iBS, iUE).ASD = s_M(5, iBS, iUE);
            out(iBS, iUE).ESA = s_M(6, iBS, iUE);
            out(iBS, iUE).ESD = s_M(7, iBS, iUE);
        else
            out(iBS, iUE).ASD = s_M(4, iBS, iUE);
            out(iBS, iUE).ASA = s_M(5, iBS, iUE);
            out(iBS, iUE).ESD = s_M(6, iBS, iUE);
            out(iBS, iUE).ESA = s_M(7, iBS, iUE);
        end   
    end
end
end