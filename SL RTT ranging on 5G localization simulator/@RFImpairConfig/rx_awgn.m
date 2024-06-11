function waveout = rx_awgn(RFI, pathloss, wavein, iRr, iTr, sysPar)
%rx_awgn Add AWGN to the receive waveform.
%
% DESCRIPTION
%   The dimension of wavein is ntime * nlink
%
% Developer: Jia. Institution: PML. Date: 2021/07/16
Indup = sysPar.IndUplink;
SNR = sysPar.SNR;
[~, L] = size( wavein );
nfft = RFI.nFFT;
nSamperSlot = sum( RFI.NSa( 1 :RFI.SymbolsPerSlot ) );
SCused = RFI.SubCarrierused;
Pgroundnoise = RFI.Pgroundnoise;
if RFI.IndUplink
    noisefig = RFI.BSnoisefig;
else
    noisefig = RFI.UEnoisefig;
end

switch RFI.Ind_SNR
    case 3
        Pn = 0;
    % case two works only when 1 OFDM used.
    case 2   % SNR calculated after receive beamforming
        Ps = sum( abs( wavein( 1 :nSamperSlot, :) ) .^2, 'all') / SCused /L; 
        Pn = Ps / 10^ ( SNR /10) ;
    case 1   % SNR calculated before receive beamforming
        if Indup
            pathloss = pathloss.';
        end
        gain_pl = 10^( -pathloss( iTr,iRr ) /10 );
        Ps = gain_pl / nfft * 10^(sysPar.powerTr /10) /1000;
        Pn = Ps / ( 10^ (SNR /10) );
    case 0   % according to noise figure
        Pn = 10^( ( Pgroundnoise + noisefig )/10 );
end
noise = sqrt(1/2 * Pn ) * complex( randn( size(wavein) ), randn( size(wavein) ) );
waveout = wavein + noise;
end