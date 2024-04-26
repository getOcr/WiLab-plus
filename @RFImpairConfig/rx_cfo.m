function waveout = rx_cfo(RFI, wavein)
%rx_cfo Add CFO to the receive waveform.
%
% Description: 
%   The dimension of wavein is ntime * nlink. 
%
% Developer: Jia. Institution: PML. Date: 2021/07/17 

nfft = RFI.nFFT;
CFOepsilon = RFI.CFOepsilon;

switch RFI.Ind_CarrFreqOffset
    case 2   
        waveout = wavein .* exp(1i *2 * pi * CFOepsilon / nfft * ...
            (1 :  length(wavein(:,1)) )' );
    case 1
        waveout = wavein .* exp(1i *2 * pi * CFOepsilon / nfft * ...
            (1 :  length(wavein(:,1)) )' );
    case 0   
        waveout = wavein;
end

end