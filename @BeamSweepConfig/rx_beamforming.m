function waveout = rx_beamforming(BSC, wavein, RFI)
%rx_beamforming add receive beamforming weights to the receive waveform.
%
% Description:
%   This function aims to perform receive beamforming at the recevier.
%   The dimension of wavein shall be ntime * nlink.
RxWeight = trx_BeamSteerErr(RFI, BSC.RxWeight);
if BSC.IndBmSweep && BSC.IndrxBmSweep
    if strcmp( BSC.SignalType,'SSB' ) 
        nSamperbeam = BSC.SSBPeriodicity /10 * 10 * sum(BSC.NSa);
        waveout = zeros( size( wavein(:,1) ) );
        for iRxBeam = 1 : BSC.nRxBeam
            idxnSamples = nSamperbeam * (iRxBeam -1) +1 : nSamperbeam * iRxBeam;
            waveout(idxnSamples, :) = wavein(idxnSamples, :) ...
                * conj( RxWeight(:, iRxBeam) );
        end
    else
        waveout = zeros(size(wavein(:,1)));
        for iRxBeam = 1 : BSC.nRxBeam
            idxnSamples = sum(BSC.NSa( 1 : iRxBeam -1) ) +1 : sum(...
                BSC.NSa(1: iRxBeam) );
            waveout(idxnSamples,:) = wavein(idxnSamples, :) ...
                * conj(RxWeight(:,iRxBeam));
        end
    end
else
    waveout = wavein;
end
end