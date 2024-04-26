function weightout = trx_BeamSteerErr(RFI, weightin)
%trx_BeamSteerErr Apply beamsteering error to the beamforming weight.
%
% Developer: Jia. Institution: PML. Date: 2022/05/07 
switch RFI.Ind_BeamStrErr
    case 1
        ndim = size( weightin );
        rand_amp = randn(ndim);
        rand_pha = randn(ndim);
        LSB =2*pi / ( 2^RFI.Nbit );
        weightout = 10.^(RFI.Del_amp * rand_amp/20 ) .* ...
            exp(1i*(round( mod( angle( weightin ), 2*pi) / LSB ) ...
            * LSB + RFI.Del_amp * rand_pha) );
    case 0
        weightout = weightin;
end
end
