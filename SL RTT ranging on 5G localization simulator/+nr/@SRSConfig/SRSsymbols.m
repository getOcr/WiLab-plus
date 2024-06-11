function symbols = SRSsymbols(srs, carrier);
%SRSsymbols Generate the SRS symbols.
%
% Description:
%   This function aims to generate SRS symbols in the resource grid
%   according to 3GPP TS38.211 v16.4.0 clause 6.4.1.4.
%
%	Developer: Jia. Institution: PML. Date: 2021/08/01

NsymPerSlot = carrier.SymbolsPerSlot;
SlotsPerFrame = carrier.SlotsPerFrame;
if mod(( SlotsPerFrame * srs.Nframe + srs.nslot - srs.Periodset(2) ), ...
        srs.Periodset(1) ) == 0
    % cyclicshift
    p = ( 0 : srs.N_ap -1).';
    N_cycshf_i = mod( (srs.N_cycshf + srs.N_cycshf_max * p /srs.N_ap ), ...
        srs.N_cycshf_max);
    alpha = 2 *pi * N_cycshf_i / srs.N_cycshf_max;
    % u & v
    switch srs.groupOrSeqHopping
        case 'neither'
            f_gh( 1: srs.N_symb) = 0;
            v( 1: srs.N_symb) = 0;
        case 'groupHopping'
            refseq = nr.get_sequence( srs.NSRSID, 8 *( SlotsPerFrame ...
                *NsymPerSlot ) +1 );
            l1 = (0 : srs.N_symb-1).';
            m = (0 : 7);
            temp = sum( refseq( 8 * (srs.nslot * NsymPerSlot + srs.L_0 ...
                + l1) +m +1) .* 2.^m, 2);
            f_gh = mod( temp.', 30);
            v( 1 : srs.N_symb) = 0;
        case 'sequenceHopping'
            refseq = nr.get_sequence( srs.NSRSID, ...
                ( SlotsPerFrame * NsymPerSlot ) +1 );
            f_gh( 1 : srs.N_symb ) = 0;
            if srs.M_sc_b( srs.B_SRS +1 ) >= 6 * 12
                l1 = 0 : srs.N_symb -1;
                v = refseq( srs.nslot * NsymPerSlot + srs.L_0 + l1 +1 );
            else
                v(1: srs.N_symb) = 0;
            end
    end
    u = mod(f_gh, 30);
    delta = log2( srs.KTC );
    m = srs.M_sc_b( srs.B_SRS +1) /12 * 2^delta;
    % srs sequence
    symbols = zeros( srs.M_sc_b(srs.B_SRS +1), srs.N_symb, srs.N_ap );
    for p  = 0 : srs.N_ap-1
        r_base = nr.get_basesequence( delta, alpha( p +1), m);  
        for l1 = 0 : srs.N_symb -1
            symbols(:, l1+1, p+1) =  10^( srs.beta_srs /10 ) / ...
                sqrt( srs.N_ap ) * r_base(:, u(l1 +1) +1,v(l1 +1) +1 );
        end
    end
else
    symbols = [];
end
end




