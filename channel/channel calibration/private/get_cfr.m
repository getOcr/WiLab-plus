function hcfr = get_cfr(H, timedelay, Fs, N);
%get_cfr
% Fs in Hz, sample frequency in baseband.
% N FFT point.
% H dim: nPath nRx nTx nsnap
% timedelay dim: nPath * 1 (/nsnap) : unit: ns
% output: hcfr dim: nRx nTx N nsnap
[nPath, nRx, nTx, nsnap] = size(H);
if size(timedelay, 2) == 1
    timedelay = repmat(timedelay, 1, nsnap);
end
H = reshape(H, nPath,[],nsnap);
% reshape
hcfr = zeros( N, nRx * nTx, nsnap);
for isnap = 1 : nsnap
    for iP = 1 : nPath
        delay_p = timedelay( iP, isnap);
        h_p = H( iP, :, isnap);
        cfr_phase_delay = delay_p * Fs * 2 * pi / N .* (-N/2 : N/2 -1).';
        cfr_path_abs = abs( h_p ) .* ones(N, 1);
        cfr_path_phase = angle( h_p ) .* ones(N, 1) - cfr_phase_delay;
        hcfr_path = cfr_path_abs .* exp(1i * cfr_path_phase );
        hcfr(:,:,isnap) = hcfr + hcfr_path;
    end
end
hcfr = reshape(hcfr, [ N nRx nTx nsnap]);
hcfr = permute(hcfr, [ 2 3 1 4 ] );
end