function [txWaveform] = gen_transmitsignal(sysPar,carrier,data,RFI,BeamSweep);
%gen_transmitsignal Generate transmit signal by OFDM modulation.
% Description:
% The beamforming, IQ imbalance, transmit power, and nonlinearity of power 
% amplifier at the tranmitter are included. 
%   Input:  txGrid: nSC * nSym * nTx * nTr
%   Output: txWaveform: ndtime * nTx * nTr
% 
% Developer: Jia. Institution: PML. Date: 2021/10/28
 
nTr = sysPar.nTr;
txWaveform = [];
for iTr = 1 : nTr
    txWaveform_t = nr.OFDMModulate( carrier, data.txGrid(:,:,:,iTr ),...
        sysPar.center_frequency, 0 );
    txWaveform_t = cat(1, txWaveform_t, zeros(500, size(txWaveform_t, 2) ) );
    % add txbeamforming
    txWaveform_t = tx_beamforming(BeamSweep, txWaveform_t, RFI);
    % add Tx I/Q imbalance
    txWaveform_t = tx_IQimbalance(RFI, txWaveform_t );
    % add Tx transmit power
    txWaveform_t = txWaveform_t * sqrt(10^ (sysPar.powerTr /10) /1000 );
    % add transmit power amplifier nonlinearity
    txWaveform_t = tx_ampnonlinear(RFI,txWaveform_t ); 
    txWaveform = cat(3, txWaveform, txWaveform_t );   
end
end