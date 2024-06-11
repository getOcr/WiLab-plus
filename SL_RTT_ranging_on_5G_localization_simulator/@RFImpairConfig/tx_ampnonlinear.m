function waveout = tx_ampnonlinear(RFI, wavein); 
%tx_ampnonlinear Add power amplifier nonlinearity to the transmit waveform.
%
% Description: 
%   The dimension of wavein is ntime * nlink 
%
% Developer: Jia. Institution: PML. Date: 2021/07/19\

g = RFI.PANg;
s = RFI.PANs;
Asat = RFI.PANAsat;
alpha = RFI.PANalpha;
beta = RFI.PANbeta;
q1 = RFI.PANq1;
q2 = RFI.PANq2;

switch RFI.Ind_PowAmpNonlinear
    case 0
        waveout = wavein;
    case 1 
        Amp = abs( wavein );
        phase = angle( wavein ) /pi *180;  
        Amp_out = g ./ (1 + ( g / Asat .* Amp) .^(2*s) ) .^(1/(2*s)) .* Amp;
        phase_out =alpha ./ (1 + (phase / beta) .^q2 ) .* phase .^ q1;
        waveout = Amp_out .* exp( 1i * phase_out /180 * pi);
end

end