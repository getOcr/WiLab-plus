function rxGrid = OFDMDemodulate(carrier, rxWaveform, center_frequency, phasecomp)
%OFDMDemodulate Generate the OFDM demodulated grid.
%
% Description:
%   This function aims to demodulate rxWaveform into OFDM receive Grid
%   according to 3GPP TS38.211 clause 5.3.
%
%	Developer: Jia. Institution: PML. Date: 2021/08/17

% symoff = 0;
Nfft = carrier.Nfft;
[~,Pant]  = size(rxWaveform);
NSizeGrid = carrier.NSizeGrid;
Nsym_slot = carrier.SymbolsPerSlot;
SubcarrierSpacing = carrier.SubcarrierSpacing;
mu = log2( carrier.SubcarrierSpacing /15 );
CyclicPrefix = carrier.CyclicPrefix;
N_cp_sf = nr.get_Ncpsamples( CyclicPrefix, mu, Nfft, Nsym_slot );
%--------------------------
N_wave = length( rxWaveform(:,1) );
N_sample = sum( N_cp_sf + Nfft );
L = length( N_cp_sf ) * floor( N_wave / N_sample );
Ncum = cumsum(N_cp_sf + Nfft );
N_res = N_wave - N_sample * floor( N_wave / N_sample );
L_res = find( Ncum > N_res, 1 ) -1; 
L = L + L_res;
rxGrid = zeros(NSizeGrid * 12, L, length( rxWaveform(1,:) ));
nshiftsamp = 0;
for l = 1 : L
    l_sub = mod(l-1,Nsym_slot*2^mu);
    phaseC_p = nr.phasecompensat(Nfft,N_cp_sf(l_sub+1),SubcarrierSpacing, ...
        center_frequency,phasecomp);
    phaseComp = repmat(phaseC_p,1,Pant); 
    rxWaveform_l = rxWaveform(nshiftsamp+1:nshiftsamp+N_cp_sf(l_sub+1)+Nfft,: ) ...
        .* exp(-1i*phaseComp);
    % symoff should be small than time offset.
    symoff = N_cp_sf(l_sub+1)/2;
    wave_cpremoved = rxWaveform_l([ (N_cp_sf(l_sub+1)+1):(Nfft+symoff), ...
        (symoff+1):N_cp_sf(l_sub+1)],:);
    rxGrid_sym = fftdecentral(wave_cpremoved, Nfft, NSizeGrid);
    rxGrid_sym = permute(rxGrid_sym, [1 3 2]);
    rxGrid(:,l, :) = rxGrid_sym;
    nshiftsamp = nshiftsamp + N_cp_sf(l_sub+1)+Nfft;
end
%-------------------------
end
% fft demodulate
function out = fftdecentral(waveform,Nfft,NSizeGrid)
fftsig = fft(waveform,Nfft,1);
Grid_sym = circshift(fftsig,NSizeGrid*12/2,1);
out = Grid_sym(1:NSizeGrid*12,:);
end

