function [Angle_esti,theta] = gen_estimated_angle(sysPar,hcfr_esti,PE);
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

nRr = sysPar.nRr; %目前为2
nTr = sysPar.nTr; %目前为1
nRSslot = sysPar.nRSslot;
Angle_esti = zeros( nRSslot, nRr, nTr,1);
for iTr = 1 : nTr
    for iRr = 1 : nRr
        for islot = 1 : nRSslot
            if sysPar.IndUplink
                %eval(['Angle_esti(islot, iRr, iTr,:) = ', PE.AngEstiMethodSel,...
                    %'(PE,hcfr_esti(:, :, 1, islot, iRr, iTr) );']); 
                %其实就是执行Angle_esti(islot, iRr, iTr,:) =PE.AngEstiMethodSel(PE,hcfr_esti(:, :, 1, islot, iRr, iTr) );
                [Angle_esti(islot, iRr, iTr,:), theta] =music1(PE,hcfr_esti(:, :, 1, islot, iRr, iTr) );
            else
                eval(['Angle_esti(islot, iRr, iTr,:) = ', PE.AngEstiMethodSel,...
                    '(PE,permute( hcfr_esti(:, 1, :, islot, iRr, iTr), [1 3 2]) );'] );
            end    
        end
    end
end
end