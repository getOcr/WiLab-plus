function  waveout = tx_IQimbalance(RFI, wavein );
%tx_IQimbalance Add IQ imbalance to the transmit waveform.
%
% DESCRIPTION 
%   The dimension of wavein is ntime * nlink 
%
% Developer: Jia. Institution: PML. Date: 2021/07/19

QGainTx = RFI.QGainTx;   % gain     1 for perfect IQ
QPhaseTx = RFI.QPhaseTx;    % degree    0 for perfect IQ
h_TxI = RFI.h_TxI;   % Tx I path impulse response
h_TxQ = RFI.h_TxQ;   % Tx Q path impulse response
[N, L] = size(wavein);
waveout = zeros(N,L);
switch RFI.Ind_IQImbalance
    case 0     
        waveout = wavein;
    case 1
        waveout = (1 + QGainTx * exp(-1i * QPhaseTx  /180 * pi ) ) /2 * ...
            wavein + (1 - QGainTx * exp( 1i * QPhaseTx /180 * pi ) ) /2 ...
            * ( conj( wavein) );
    case 2
        for l = 1 : L
            waveout(:,l) = conv( wavein(:,l), ( h_TxI + h_TxQ) /2, 'same') ...
                + conv( conj( wavein(:,l) ), ( h_TxI - h_TxQ ) /2, 'same');
        end
    case 3
        for l = 1 : L
            waveout( :, l) = conv( wavein( :, l),  ( h_TxI +  QGainTx ...
                * exp( -1i * QPhaseTx /180 * pi ) * h_TxQ ) /2, 'same' ) ...
                + conv( conj( wavein( :, l) ), ( h_TxI - QGainTx ...
                * exp( 1i * QPhaseTx /180 * pi )  * h_TxQ ) /2, 'same' );
        end
end