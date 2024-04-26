function  [hcfr_esti] = gen_estimated_cfr(sysPar,carrier,data);
%gen_estimated_cfr Generate estimated channel frequency response
%
% Description:
%   This function aims to obtain estimated channel frequency response by
%   LS-based channel estimation method.
%   output:   hcfr_esti : nSC * nRx * nTx * nslot * nRr * nTr
%
% Developer: Jia. Institution: PML. Date: 2021/10/28

nTr = sysPar.nTr;
nRr = sysPar.nRr;
nRx = sysPar.nRx;
nTx = sysPar.nTx;
nRSslot = sysPar.nRSslot;
totGridSize = [ carrier.NSizeGrid * 12 nRx nTx nRSslot nRr, nTr ];
hcfr_esti = zeros( totGridSize );
firstSymbol = zeros( nTr );
cdmLengths = nr.RSCDMLengths(sysPar.SignalType, sysPar.SigRes(1));
switch sysPar.SignalType
    case 'SRS'
        for iTr = 1 : sysPar.nTr
            firstSymbol( iTr ) = sysPar.SigRes( iTr ).L_0 +1;
        end
    case 'CSIRS'
        for iTr = 1 : sysPar.nTr
            firstSymbol(iTr) = sysPar.SigRes( iTr ).L0(1) +1;
        end
    case 'PRS'
        for iTr = 1 : sysPar.nTr
            firstSymbol(iTr) = sysPar.SigRes( iTr ).L_start(1) +1;
        end
end
% if strcmpi(sysPar.SignalType, 'SRS') || strcmpi(sysPar.SignalType,'CSIRS')
for iTr = 1 : nTr
    for iRr = 1 : nRr
        for islot = 1 : nRSslot
            idnsym = carrier.SymbolsPerSlot * (islot -1) +1 : ...
                carrier.SymbolsPerSlot * islot;
            rxGrid_s = data.rxGrid(:, idnsym, :, iRr);
            rsIndices_s = squeeze( data.rsIndices(:, islot, :, iTr) );
            rsSymbol_s = squeeze( data.rsSymbols(:, islot, :, iTr) );
            H = nr.channelestimate(carrier, rxGrid_s, rsIndices_s, ...
                rsSymbol_s, nTx, cdmLengths);
            hEst_temp = permute( H(:, firstSymbol(iTr),:,:), [1 3 4 2]);
            %nSC nRx nTx nslot
            hcfr_esti(:,:,:,islot,iRr,iTr) = hEst_temp;
        end
    end
end
% end
end

