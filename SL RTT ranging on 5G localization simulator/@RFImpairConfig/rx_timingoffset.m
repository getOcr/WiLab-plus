function waveout = rx_timingoffset(RFI, wavein);
%rx_timingoffset Add timing offset to the receive waveform.
%
% DESCRIPTION
%   The dimension of wavein is ntime * nlink. 
%
% Developer: Jia. Institution: PML. Date: 2021/07/19
 
del_f = RFI.SCS * 1000;
nfft = RFI.nFFT;
TOsigma = RFI.TOsigma;     
[~, L] = size(wavein);
switch RFI.Ind_TimingOffset
    case 0
        waveout = wavein;
    case 1
        temp = 2 * ones(L, 1); %%
        offset = temp.' * TOsigma;
%         offset = [5 1 7 1];
        rxfreq = fft(wavein, [], 1) .* exp(1i *( 0 : length(wavein) -1).'...
            * offset* 1e-9 * del_f * nfft * 2 * pi / length(wavein) ); 
        waveout = ifft(rxfreq);
    case 2
        temp = zeros(L, 1);
        for i = 1 : L
            temp(i) = randn(RFI.randstream4);
            while temp(i) >=2 || temp(i) <= -2
                temp(i) = randn( RFI.randstream4 );
            end
        end
        offset = temp.' * TOsigma;
        rxfreq = fft(wavein, [], 1) .* exp(1i *( 0 : length(wavein) -1).'...
            * offset* 1e-9 * del_f * nfft * 2 * pi / length(wavein) ); 
        waveout = ifft(rxfreq);
    otherwise
        error('Error: inaccurate configuration of Ind_TimingOffset !');
end
end