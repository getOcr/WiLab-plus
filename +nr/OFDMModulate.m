function waveform = OFDMModulate(carrier, txGrid, center_frequency, phasecomp);
%OFDMModulate Generate the OFDM modulated waveform.
%
% Description:
%   This function aims to modulate txGrid into OFDM waveform
%   according to 3GPP TS38.211 clause 5.3.
%
%	Developer: Jia. Institution: PML. Date: 2021/08/17

% Para needed.
[~, Ltot, Pant]  = size( txGrid );
Nfft = carrier.Nfft;
Nsym_slot = carrier.SymbolsPerSlot;
SubcarrierSpacing = carrier.SubcarrierSpacing;
mu = log2( carrier.SubcarrierSpacing /15);
CyclicPrefix = carrier.CyclicPrefix;
if strcmpi(CyclicPrefix, 'extended') && mu~=2
    error('Extended CP works only when SCS = 60KHz.');
end
ofdmwave_nfft = ifftcentral( txGrid, Nfft);
N_cp_sf = nr.get_Ncpsamples( CyclicPrefix, mu, Nfft, Nsym_slot);
waveform = zeros( sum( N_cp_sf +Nfft ) * floor( Ltot / length( N_cp_sf ) )+ ...
    sum( N_cp_sf( 1: rem( Ltot, length( N_cp_sf) ) ) +Nfft ), Pant);
for l = 0 : Ltot -1
    l_sub = mod(l, Nsym_slot *2^mu);
    wavepersym = squeeze( cat(1, ofdmwave_nfft( ( end -N_cp_sf( l_sub +1) ...
        +1: end ), l +1 ,:), ofdmwave_nfft(:, l+1,:) ) );
    phaseC_p = nr.phasecompensat( Nfft, N_cp_sf( l_sub +1), SubcarrierSpacing, ...
        center_frequency, phasecomp);
    phaseComp = repmat( phaseC_p, 1, Pant);
    firstsamp = sum( N_cp_sf +Nfft ) * floor( l / length(N_cp_sf) )+ ...
    sum( N_cp_sf(1: rem( l , length(N_cp_sf) ) ) +Nfft ) +1;
    lastsamp = firstsamp -1 + N_cp_sf( mod(l, 28 ) +1) +Nfft;
        waveform(firstsamp:lastsamp, :) = wavepersym .* exp(1i* phaseComp); 
end

end
%-----------------------------------
% sub function
% ifft modulate
function out = ifftcentral(txGrid, NFFT)
[Ktot, Ltot, Pant]  = size( txGrid );
Len_0 = (NFFT -Ktot);
Grid_filled = cat(1, txGrid, zeros( Len_0, Ltot, Pant ) );
Grid_filled = circshift( Grid_filled, -Ktot /2, 1);
out = ifft( Grid_filled, NFFT, 1);
end

 


