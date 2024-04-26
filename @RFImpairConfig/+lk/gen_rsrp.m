function [rsrp,rsrp_dbm] = gen_rsrp(sysPar,carrier,data, BeamSweep);
%gen_rsrp Generate RSRP from the receive signal
%
% This function aims to calculate the L1-RSRP from the receive signal
% according to the configurated reference signal or synchronization signal.
% rxGrid   % nSC * nSyms * nRx * nRr
%
% Developer: Jia. Institution: PML. Date: 2021/10/28

nRr = size(data.rxGrid, 4 );
nRx = size(data.rxGrid, 3 );
nTr = sysPar.nTr;
if strcmp(sysPar.SignalType, 'SSB')
    nTxBeam = BeamSweep.nTxBeam;
    if BeamSweep.IndrxBmSweep == 1
        nRxBeam = nTxBeam;
    else
        nRxBeam = 1;
    end
    nSymsPerRxBeam = sysPar.SigRes(1).SSBPeriodicity / 10 * ...
        carrier.SlotsPerFrame * carrier.SymbolsPerSlot;
    rsrp = zeros(nRxBeam, nTxBeam, nRr, nTr);
    for iTr = 1 : nTr
        [sssSym, sssInd] = SSSsymbols_indices( sysPar.SigRes(iTr) );    % SSS indices
        for iRr = 1 : nRr
            for iRxBeam = 1 : nRxBeam
                idrnSyms = nSymsPerRxBeam * (iRxBeam -1 ) + ...
                    1 : nSymsPerRxBeam * iRxBeam;
                rxGrid_r = data.rxGrid(:, idrnSyms, :, iRr);
                for iTxBeam = 1 : nTxBeam
                    iSyms = sysPar.SigRes(1).SSBSymPos( iTxBeam,: );
                    rxSSBGrid = rxGrid_r( sysPar.SigRes(1).SSBSCPos, iSyms, :);
                    rsrpSSS = zeros( nRx, 1);
                    for iRx = 1 : nRx
                        % Extract signals per rx element
                        rxSSBGridperRx = rxSSBGrid(:,:, iRx );
                        rxSSS = rxSSBGridperRx( sssInd );
                        % Average power contributions over all REs for RS
                        rsrpSSS(iRx) = abs( mean(rxSSS .* conj(rxSSS) ) );
                    end
                    rsrp(iRxBeam, iTxBeam, iRr, iTr) = max(rsrpSSS);
                end
            end
        end
    end
else
    if BeamSweep.IndrxBmSweep == 1
        nTxBeam = 1;
        nRxBeam = BeamSweep.nRxBeam;
    else
        nRxBeam = 1;
        nTxBeam = BeamSweep.nTxBeam;
    end
    rsrp = zeros(nRxBeam, nTxBeam, nRr, nTr);
    nlink = size(data.rxGrid, 3);
    for iTr = 1 : nTr
        for iRr = 1 : nRr
            rsrp_nRx = zeros(nlink, BeamSweep.nRxBeam);
            for iRx = 1: nlink
                gridRxAnt = data.rxGrid(:,:, iRx, iRr);
                for iBeam = 1 : BeamSweep.nRxBeam
                    rxSym = reshape( gridRxAnt( data.rsIndices(:, iBeam,1,  iTr) ), [], 1 ); 
                    ReSym = reshape( data.rsSymbols(:, iBeam, 1, iTr ), [], 1 );
                    rsrp_nRx(iRx,iBeam) = ( abs( mean(rxSym .* conj(ReSym) ) ) /2 ).^2;
                end
                rsrp_nRx( isnan( rsrp_nRx ) ) = 0;
                if BeamSweep.IndrxBmSweep
                    rsrp(:,1, iRr, iTr) = sum( rsrp_nRx, 1);
                else
                    rsrp(1,:, iRr, iTr) = sum( rsrp_nRx, 1);
                end
            end
        end
    end
end
rsrp_dbm = 10 * log10( rsrp ) + 30; % dBm
end
