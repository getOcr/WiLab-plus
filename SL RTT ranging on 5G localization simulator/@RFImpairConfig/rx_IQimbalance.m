function waveout = rx_IQimbalance(RFI,wavein);
%rx_IQimbalance Add IQ imbalance to the receive waveform.
%
% DESCRIPTION
%   The dimension of wavein is ntime * nlink 
% 
% Developer: Jia. Institution: PML. Date: 2021/07/18

QGainRx = RFI.QGainRx;       % gain      1 for perfect IQ
QPhaseRx = RFI.QPhaseRx;     % degree    0 for perfect IQ
h_RxI = RFI.h_RxI;                 % Rx I path impulse response
h_RxQ = RFI.h_RxQ;              % Rx Q path impulse response
[N, L] = size(wavein);
waveout = zeros(N, L);
switch RFI.Ind_IQImbalance
    case 0        
        waveout = wavein;
    case 1
        waveout = (1 + QGainRx * exp(-1i * QPhaseRx  /180 * pi ) ) /2 * wavein ...
            + (1 - QGainRx * exp( 1i * QPhaseRx /180 * pi ) ) /2 *  ( conj( wavein) );
    case 2
        for l = 1 : L
            waveout(:, l) = conv( wavein(:, l), ( h_RxI + h_RxQ ) /2, 'same' ) ...
                + conv( conj( wavein(:, l) ), ( h_RxI - h_RxQ ) /2, 'same' );
        end
    case 3
        for l = 1 : L
            waveout(:, l) = conv( wavein(:, l),  ( h_RxI +  QGainRx ...
                * exp( -1i * QPhaseRx /180 * pi ) * h_RxQ ) /2, 'same' ) ...
                + conv( conj( wavein(:, l) ), ( h_RxI - QGainRx ...
                * exp( 1i * QPhaseRx /180 * pi )  * h_RxQ ) /2, 'same' );
        end
end
end