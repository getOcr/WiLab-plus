function waveout = rx_phasenoise(RFI, wavein);
%rx_phasenoise Add phase noise to the receive waveform.
%
% Description: 
%   The dimension of wavein is ntime * nlink.
%
% Developer: Jia. Institution: PML. Date: 2021/07/19
 
[N, L] = size( wavein );
fs = RFI.sampleRate;
rand1 = RFI.randstream2;
switch RFI.Ind_PhaseNoise
    case 0
        waveout = wavein;
    case 1         
        fz = RFI.fz1;
        fp = RFI.fp1;
        f = (fs / N  : fs / N : fs).';
        w1 = randn(rand1, N, L);
        w2 = fft(w1, [], 1);
        hh = 0.7* ( (1 + ( 1i * f / fz) ) ./ (1 + ( 1i * f / fp) ) );
        temp = repmat(hh, [1, L] ) .* w2;
        temp1 = ifft(temp, [], 1);
        waveout = wavein .* exp( 1i * real(temp1) );
    case 2
        fz = RFI.fz1;
        fp = RFI.fp1;
        T = 1/ fs;       
        b = 1e2 * 10^ ( -87 / 20 ) * [ fp / ( fz * ( 1+ pi * fp * T) ) ...
            * ( pi * fz * T +1), fp / (fz * (1+ pi * fp * T) ) * ...
            ( pi * fz * T -1) ];
        a = [1, (pi * fp * T -1) * (1 + pi * fp * T) ];
        w1 = randn(rand1, N, L);
        for l = 1 : L
            temp(:, l) =  filter(b, a, (w1(:, l) ) );
        end
        waveout = wavein .* exp( 1i * real(temp) );
    case 3
        fp = RFI.fp2;
        fz = RFI.fz2;      
        f = (fs / N  : fs / N : fs ).';
        w1 = randn(rand1, N, L);
        w2 = fft(w1, [], 1);
        hh =0.2 * (1+ (1i * f / fz(1) ) ) ./ (1+ (1i* f / fp(1) ) ) ...
            .* (1+ (1i* f / fz(2) ) ) ./ (1+ (1i * f / fp(2) ) ) .* ...
            (1+ (1i* f / fz(3) ) ) ./ (1+ (1i* f / fp(3) ) );
        temp = repmat(hh, [1, L] ) .* w2;
        temp1 = ifft(temp, [], 1);
        waveout = wavein .* exp(1i * real(temp1) );        
    otherwise
        error('Error: inaccurate setting of Ind_PhaseNoise !');   
end
end