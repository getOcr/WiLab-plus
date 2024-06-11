function [Range_esti] = gen_estimatedTOA(sysPar,hcfr_esti,PE);
%gen_estimatedTOA Estimate time of arrival.
% 
% Description:
%   This function aims to estimate 1-D TOAs using selected
%   angle estimation methods.
% 
% Input： hcfr_esti : nSC * nRx * nTx * nRSslot * nRr * nTr
% Output:  Range_esti : nRSslot *nRr * nTr 
%
% Developer: Jia. Institution: PML. Date: 2021/08/06

nRr = sysPar.nRr;
nTr = sysPar.nTr;
nRSslot = sysPar.nRSslot;
Range_esti = zeros( nRSslot, nRr, nTr);
for iTr = 1 : nTr
    for iRr = 1 : nRr
        for islot = 1 : nRSslot
            if sysPar.IndUplink
                eval(['Range_esti(islot, iRr, iTr) = ', PE.RngEstiMethodSel,...
                    '(PE,hcfr_esti(:, :, 1, islot, iRr, iTr) );']);
            else
                eval(['Range_esti(islot, iRr, iTr) = ', PE.RngEstiMethodSel,...
                    '(PE,permute( hcfr_esti(:, 1, :, islot, iRr, iTr), [1 3 2]) );'] );
            end    
        end
    end
end
end