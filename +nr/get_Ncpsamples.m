function out = get_Ncpsamples(CyclicPrefix,mu,Nfft,Nsym_slot)
%get_Ncpsamples Generate CP samples within a subframe following 3GPP TS
%38.211 v16.4.0

kappa = 64;
rat = 2048 *kappa *2^( -mu) /Nfft;
if strcmpi( CyclicPrefix, 'extended')
    out = 512 *kappa *2^( -mu) /rat * ones( 1, Nsym_slot *2^mu);
elseif strcmpi( CyclicPrefix, 'normal')
    out = [ ( 144 *kappa *2^( -mu) +16 *kappa ) /rat, 144 *kappa *2^( -mu)...
        /rat * ones(1, 7*2^mu -1), ( 144 *kappa *2^( -mu) +16 *kappa ) /rat,...
        144 *kappa *2^( -mu) /rat * ones(1, 7 *2^mu -1 ) ];
end
end