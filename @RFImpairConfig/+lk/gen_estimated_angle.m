function [Angle_esti] = gen_estimated_angle(sysPar,hcfr_esti,PE);
%gen_estimatedAOA Estimate azimuth angle.
% 
% Description:
%   This function aims to estimate angle(s) of arrival or departure using
%   selected angle estimation methods.
% 
% Input： hcfr_esti : nSC * nRx * nTx * nRSslot * nRr * nTr
% Output:  Angle_esti : nRSslot * nRr * nTr * 2dimAngle
% Note:  Counterclockwise is corresponding to the positive angles, and
% angle 0 is corresponding to the x-axis.
%
% Developer: Jia. Institution: PML. Date: 2021/08/06

nRr = sysPar.nRr;
nTr = sysPar.nTr;
nRSslot = sysPar.nRSslot;
Angle_esti = zeros( nRSslot, nRr, nTr,2);
for iTr = 1 : nTr
    for iRr = 1 : nRr
        for islot = 1 : nRSslot
            if sysPar.IndUplink
                eval(['Angle_esti(islot, iRr, iTr,:) = ', PE.AngEstiMethodSel,...
                    '(PE,hcfr_esti(:, :, 1, islot, iRr, iTr) );']);
            else
                eval(['Angle_esti(islot, iRr, iTr,:) = ', PE.AngEstiMethodSel,...
                    '(PE,permute( hcfr_esti(:, 1, :, islot, iRr, iTr), [1 3 2]) );'] );
            end    
        end
    end
end
end