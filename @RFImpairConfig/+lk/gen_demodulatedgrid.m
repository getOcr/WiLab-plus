function [rxGrid] = gen_demodulatedgrid(sysPar,carrier,rxWaveform);
%gen_demodulatedgrid Generate receive resource grid (demodulation).
%
% Description:
% This function aims to perform demodulation at the receiver.
% Note: rxGrid: % nSC * nSyms * nRx * nRr
%
% Developer: Jia. Institution: PML. Date: 2021/10/28

nRr = sysPar.nRr;
rxGrid = [];
for iRr = 1 : nRr
    rxGrid_r = nr.OFDMDemodulate( carrier, rxWaveform(:, :,iRr), ...
        sysPar.center_frequency, 0);
    rxGrid = cat(4, rxGrid, rxGrid_r);
end
end

