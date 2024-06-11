function ksi_uif = calc_cro_correl(UE_position, M, d_dec, norsm);
%generate cross-correlation for UEs.
D = 100;
gran_dis = 1; % granularity
UE_pos = round( UE_position /gran_dis ) * gran_dis;
nUE = length( UE_pos(1,:) );
if nUE ~= 1
    gridn = randn(norsm,( max(UE_pos(2,:)) - min(UE_pos(2,:)) ) /gran_dis + 2*D ...
        +1, ( max(UE_pos(1,:)) -min(UE_pos(1,:))) / gran_dis + 2*D +1, M );
    ueind = sub2ind( size(gridn), ( UE_pos(2,:) - min(UE_pos(2,:)) ) ...
        /gran_dis +D +1, (UE_pos(1,:) - min(UE_pos(1,:))) /gran_dis +D +1 );
    d = 0:gran_dis:100;
    h = exp(-1 * repmat(d, M, 1) ./ d_dec(:));
    h = h./ sum(h,2);
    ksi_uif = zeros(M, nUE);
    for iM = 1 : M
        temp = filter(h(iM,:),1,gridn(:,:,iM),[],1);
        ksi_grid = filter(h(iM,:),1,temp,[],2);
%         ksi_grid = zscore(ksi_grid); % standarization 
        ksi_uif(iM,:) = ksi_grid(ueind);
    end
else % pUE = 1
    ksi_uif = randn(norsm, M, 1);
end
end