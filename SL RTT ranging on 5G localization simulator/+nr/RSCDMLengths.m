function cdmLengths = RSCDMLengths(RefSigStyle, RSConfPara)
%RSCDMLengths Generate code division multiplexing length for channel
%estimation.
%
% Description:
%   This function aims to generate CDM length of SRS or CSIRS signal, which
%   used for channel estimation method, according to 3GPP TS 38.211 v16.4.0.
%
% Developer: Jia. Institution: PML. Date: 2021/08/18

if strcmp( RefSigStyle, 'SRS')
    if RSConfPara.N_ap == 1
        cdmLengths = [1 1];
    elseif RSConfPara.N_ap == 2
        cdmLengths = [2 1];
    elseif (RSConfPara.KTC == 2 && RSConfPara.N_cycshf >= 4) || ...
            (RSConfPara.KTC == 4 && RSConfPara.N_cycshf >= 6)
        cdmLengths = [2 1];
    else
        cdmLengths = [4 1];
    end
elseif strcmp( RefSigStyle, 'CSIRS')
    num = RSConfPara(1, 1).Row;  %RowNumber
    if num >= 1 && num <= 2
        cdmLengths = [1 1];  % noCDM
    elseif num <= 7 || num == 9 || num == 11 || num == 13 ||  num == 16
        cdmLengths = [2 1];  % FD-CDM2
    elseif  num == 8 || num == 10 || num == 12 || num == 14 || num == 17
        cdmLengths = [2 2];  % FD2-TD2-CDM4
    elseif num == 15 || num == 18
        cdmLengths = [2 4];  % FD2-TD4-CDM8
    end
else
    cdmLengths = [1 1];  % noCDM
end
end