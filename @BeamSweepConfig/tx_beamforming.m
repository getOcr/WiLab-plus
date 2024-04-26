function waveout = tx_beamforming(BSC, wavein, RFI)
%tx_beamforming add transmit beamforming weights to the transmit waveform.
%
% Description:
%   This function aims to perform transmit beamforming at the transmitter.
%   The dimension of wavein shall be ntime * nlink.
%
% Developer: Jia. Institution: PML. Date: 2021/07/26

TxWeight = trx_BeamSteerErr(RFI, BSC.TxWeight);
if BSC.IndBmSweep  && strcmp( BSC.SignalType, 'SSB' )
    nRxBeam = 1 * (~BSC.IndrxBmSweep) + BSC.nRxBeam * (BSC.IndrxBmSweep);
    gridSymLengths = repmat( BSC.NSa,1, BSC.SSBPeriodicity * nRxBeam); %half frame
    waveout = zeros(size(wavein));
    for iRxBeam = 1 : nRxBeam
        for iTxBeam = 1 : BSC.nTxBeam
            blockSymbols = BSC.SSBSymPos(iTxBeam, :) + BSC.SSBPeriodicity / ...
                10 * BSC.SymbolsPerSlot * BSC.SlotsPerFrame * (iRxBeam -1);
            startSSBInd = sum( gridSymLengths(1: blockSymbols(1) -1) ) +1;
            endSSBInd = sum( gridSymLengths(1: blockSymbols(4) ) );
            waveout(startSSBInd : endSSBInd, :) = wavein( ...
                startSSBInd : endSSBInd, :) .* ( TxWeight(:, iTxBeam)' );
        end
    end
elseif BSC.IndBmSweep  && BSC.IndrxBmSweep == false
    waveout = zeros( size( wavein ) );
    for iTxBeam = 1 : BSC.nTxBeam
        idxnSamples = sum(BSC.NSa( 1:iTxBeam -1) ) + ...
            1 : sum( BSC.NSa( 1: iTxBeam ) );
        waveout(idxnSamples, : ) = wavein( idxnSamples, : ) ...
            .* ( TxWeight( :, iTxBeam )' );
    end
else
    waveout = wavein;
end
end