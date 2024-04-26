function sysPar = ParaTransConfig(sysPar);
%ParaTransConfig Transformation from tx-rx to BS-UE system configuration.
%
% This function aims to configure channel simulator to be consistent with 
% 5G NR signal systems.
%
% Developer: Jia. Institution: PML. Date: 2022/01/13

if strcmp( sysPar.SignalType,'SRS') 
    sysPar.TxArraySize = sysPar.UEArraySize;
    sysPar.RxArraySize = sysPar.BSArraySize;
    sysPar.nTx = prod( sysPar.TxArraySize );
    sysPar.nRx = prod( sysPar.BSArraySize );
    sysPar.nTr = sysPar.nUE;
    sysPar.nRr = sysPar.nBS;
    sysPar.IndUplink = true;    
    sysPar.powerTr = sysPar.powerUE;
else
    sysPar.TxArraySize = sysPar.BSArraySize;
    sysPar.RxArraySize = sysPar.UEArraySize;
    sysPar.nTx = prod( sysPar.BSArraySize );
    sysPar.nRx = prod( sysPar.UEArraySize );
    sysPar.nTr = sysPar.nBS;
    sysPar.nRr = sysPar.nUE;
    sysPar.IndUplink = false;
    sysPar.powerTr = sysPar.powerBS;
end
% Constant Config.
sysPar.c = 299792458;
sysPar.wavelength = sysPar.c / sysPar.center_frequency;
end
