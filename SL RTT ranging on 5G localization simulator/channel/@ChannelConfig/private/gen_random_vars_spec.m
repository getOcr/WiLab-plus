function r = gen_random_vars_spec(scenario, UE_position, Ind_O2I, ...
    Ind_LOS, Ind_spatconsis, nBS, nUE, nsnap, unism, norsm);
%gen_random_vars_spec generate random variables for cluster-and-ray
% specific ssps.
% sub-cluster rays
R1 = [1 2 3 4 5 6 7 8 19 20];
R2 = [9 10 11 12 17 18];
R3 = [13 14 15 16];
nray = 20;
if strcmpi(scenario(1:3), 'umi')
    d_dec = [12 15 15]; % LOS NLOS O2I
    ncluster_max = 19;
elseif strcmpi(scenario(1:3), 'uma')
    d_dec = [40 50 15];
    ncluster_max = 20;
elseif strcmpi(scenario(1:3), 'rma')
    d_dec = [50 60 15];
    ncluster_max = 11;
elseif strcmpi(scenario(1:3), 'ind')
    d_dec = [10 10 10];
    ncluster_max = 19;
elseif strcmpi(scenario(1:3), 'inf')
    d_dec = [10 10 10];
    ncluster_max = 25;
    if strcmpi(scenario(6), 'L')
        d_dec_ata = 6;
    else
        d_dec_ata = 11;
    end
end
if ~Ind_spatconsis
    rd_var_tau = rand(unism, nBS, nUE, ncluster_max, 1);
    rd_var_pow = randn(norsm, nBS, nUE, ncluster_max, 1);
    rd_var_offset = randn(norsm, nBS, nUE, ncluster_max, 4);
    rd_var_sign = (rand(unism, nBS, nUE, ncluster_max, 4) < 0.5) *2 -1;
    var_temp = rand(unism, nBS, nUE, ncluster_max, nray);
    [~,rd_var_cp] = sort(var_temp, 4);
    rd_var_cp = repmat(rd_var_cp, [1 1 1 1 nsnap]);
    var_temp = rand(unism, nBS, nUE, 2, nray);
    [~,ind1] = sort(var_temp(:,:,:,(1:10)), 4);
    [~,ind2] = sort(var_temp(:,:,:,(11:16)), 4);
    [~,ind3] = sort(var_temp(:,:,:,(17:20)), 4);
    rd_var_b2cp = cat(4, R1(ind1), R2(ind2), R3(ind3));
    rd_var_b2cp = repmat(rd_var_b2cp, [1 1 1 1 nsnap]);
    rd_var_spr = randn( norsm, nBS, nUE, ncluster_max, nray, nsnap );
    rd_var_rndphs = rand(unism, nBS, nUE, ncluster_max, nray, nsnap, 4 );
else
    rd_var_tau = get_site_spat_cons_rand(UE_position, Ind_O2I, Ind_LOS, ...
        d_dec, nBS, nUE, ncluster_max, 'uniform', norsm);
    rd_var_pow = get_site_spat_cons_rand(UE_position, Ind_O2I, Ind_LOS, ...
        d_dec, nBS, nUE, ncluster_max, 'normal', norsm);
    rd_var_offset = get_site_spat_cons_rand(UE_position, Ind_O2I, Ind_LOS, ...
        d_dec, nBS, nUE, ncluster_max * 4, 'normal', norsm);
    rd_var_offset = reshape(rd_var_offset, [nBS nUE ncluster_max 4]);
    rd_var_sign = ( get_site_spat_cons_rand(UE_position, Ind_O2I, Ind_LOS, ...
        d_dec, nBS, nUE, ncluster_max * 4, 'normal', norsm) < 0.5 ) * 2 -1;
    rd_var_sign = reshape(rd_var_sign, [nBS, nUE, ncluster_max 4]);
    var_temp = get_site_spat_cons_rand(UE_position, Ind_O2I, Ind_LOS, ...
        d_dec, nBS, nUE, ncluster_max * nray, 'uniform', norsm);
    var_temp = reshape(var_temp, [nBS nUE ncluster_max nray]);
    [~,rd_var_cp] = sort(var_temp, 4);
    rd_var_cp = repmat(rd_var_cp, [1 1 1 1 nsnap]);
    var_temp = get_site_spat_cons_rand(UE_position, Ind_O2I, Ind_LOS, ...
        d_dec, nBS, nUE, 2 * nray, 'uniform', norsm);
    var_temp = reshape(var_temp, [nBS nUE 2 nray]);
    [~,ind1] = sort(var_temp(:,:,:,(1 : 10)), 4);
    [~,ind2] = sort(var_temp(:,:,:,(11 : 16)), 4);
    [~,ind3] = sort(var_temp(:,:,:,(17 : 20)), 4);
    rd_var_b2cp = cat(4, R1(ind1), R2(ind2), R3(ind3));
    rd_var_b2cp = repmat(rd_var_b2cp, [1 1 1 1 nsnap]);
    rd_var_spr = get_site_spat_cons_rand(UE_position, Ind_O2I, Ind_LOS, ...
        d_dec, nBS, nUE, ncluster_max * nray * nsnap, 'normal', norsm);
    rd_var_spr = reshape(rd_var_spr, [nBS nUE ncluster_max nray nsnap]);
    rd_var_rndphs = get_site_spat_cons_rand(UE_position, Ind_O2I, Ind_LOS, ...
        d_dec, nBS, nUE, ncluster_max * nray * nsnap * 4, 'uniform', norsm);
    rd_var_rndphs = reshape(rd_var_rndphs, [nBS nUE ncluster_max nray nsnap 4]);
end
% Note: Paras for absolute time of arrival considers InF case only. See
% 38.901 clause 7.6.9.
if Ind_spatconsis && strcmpi(scenario(1:3), 'inf')
    rd_var_ata = get_spatconsis_rand( UE_position, d_dec_ata, 'normal', norsm);
else
    rd_var_ata = zeros(1,nUE);
end
% transform
r(nBS,nUE).rd_var_tau = 0;
for iBS = 1 : nBS
    for iUE = 1 : nUE
        r(iBS, iUE ).rd_var_tau = permute( rd_var_tau(iBS,iUE,:), [3 1 2] );
        r(iBS, iUE ).rd_var_pow = permute( rd_var_pow(iBS,iUE,:), [3 1 2] );
        r(iBS, iUE ).rd_var_offset = permute( rd_var_offset(iBS,iUE,:,: ), [3 4 1 2] );
        r(iBS, iUE ).rd_var_sign = permute( rd_var_sign(iBS,iUE,:,: ), [3 4 1 2] );
        r(iBS, iUE ).rd_var_cp = permute( rd_var_cp(iBS,iUE,:,:,: ), [3 4 5 1 2] );
        r(iBS, iUE ).rd_var_b2cp = permute( rd_var_b2cp(iBS,iUE,:,:,: ), [3 4 5 1 2] );
        r(iBS, iUE ).rd_var_spr = permute( rd_var_spr(iBS,iUE,:,:,: ), [ 3 4 5 1 2 ] );
        r(iBS, iUE ).rd_var_rndphs = permute( rd_var_rndphs(iBS,iUE,:,:, :,: ), [ 3 4 5 6 1 2 ] );
        r(iBS,iUE).rd_var_ata = rd_var_ata(iUE);
    end
end
end
%------------------------
% sub functions
%------------------------
function rd_var = get_site_spat_cons_rand(UE_position, Ind_O2I, Ind_LOS, ...
    d_dec, nBS, nUE, num, varstyle, norsm );              
rd_var = zeros(nBS, nUE, num);
for iBS = 1 : nBS
    Ind_Od_LOS = ~Ind_O2I & Ind_LOS(iBS, :);
    Ind_Od_NLOS = ~Ind_O2I & ~Ind_LOS(iBS, :);
    for inum = 1 : num
        rd_var(iBS,Ind_O2I,inum) = get_spatconsis_rand(...
            UE_position(:,Ind_O2I), d_dec(3), varstyle, norsm);
        rd_var(iBS,Ind_Od_LOS,inum) = get_spatconsis_rand(...
            UE_position(:,Ind_Od_LOS), d_dec(1), varstyle, norsm);
        rd_var(iBS,Ind_Od_NLOS,inum) = get_spatconsis_rand(...
            UE_position(:,Ind_Od_NLOS), d_dec(2), varstyle, norsm);
    end
end
rd_var = reshape(rd_var, [nBS, nUE, num]);
end
