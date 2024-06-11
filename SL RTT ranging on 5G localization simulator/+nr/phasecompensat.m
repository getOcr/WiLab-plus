function out = phasecompensat(Nfft, Ncp, SCS, fc, Ind)
%phasecompensat perform phase correlation 38.211 v16.1.0 clause 5.4
if Ind == 1
    t_start = (0 : (Nfft +Ncp -1) ).'/ (SCS * Nfft * 1e3);
    t_cp = Ncp / ( SCS * Nfft * 1e3);
    out = 2*pi * fc *( -t_start -t_cp ) ;
else
    out = zeros( Nfft +Ncp, 1);
end
end