function sysPar = SigResConfig(sysPar, carrier);
%ParaTransConfig Transformation from tx-rx to BS-UE system configuration.
%
% This function aims to configure channel simulator to be consistent with 
% 5G NR signal systems.
%
% Developer: Jia. Institution: PML. Date: 2022/01/13

if sysPar.BeamSweep
    switch sysPar.SignalType
        case 'SSB'
            ssb = nr.SSBConfig(sysPar, carrier);
            if sysPar.IndrxBeam == true;
                sysPar.nFrames = ssb(1).SSBPeriodicity * 8 / 10;
            else
                sysPar.nFrames = ssb(1).SSBPeriodicity / 10;
            end
            ssb.nframe_tot = sysPar.nFrames;
            ssb = repmat( ssb, 1, sysPar.nBS);
            for i = 2 : sysPar.nBS
                ssb(i).N_ID1 = i -1; % considering time-position shift only
            end
            sysPar.SubCarrierused = 20 * 12;
            sysPar.SigRes = ssb;
            sysPar.RSPeriod = 1;
        case 'CSIRS'
            sysPar.RSPeriod = 4;
            csirs = nr.CSIRSConfig;
            csirs.Periodset = [sysPar.RSPeriod, 0];
            csirs.NumRB = carrier.NSizeGrid;
            csirs.Row = 2;
            csirs = repmat(csirs, 1, sysPar.nBS);
            if sysPar.nBS > 1
                for i = 2 : sysPar.nBS
                    csirs(i).n_ID = i -1;
                    csirs(i).K0 = i -1;
                end
            end
            sysPar.SubCarrierused = csirs(1).NumRB*12/6;
            sysPar.nFrames = 1/ carrier.SlotsPerFrame;
            sysPar.SigRes = csirs;
        case 'SRS'
            sysPar.RSPeriod = 1;
            srs = nr.SRSConfig;
            srs.Periodset = [sysPar.RSPeriod, 0] ;
            srs.N_ap = 1;
            srs.KTC = 2;
            srs.N_symb = 1;
            srs.L_0 = 0;
            sysPar.SubCarrierused = srs(1).M_sc_b( srs.B_SRS +1);
            srs = repmat(srs, 1, sysPar.nUE);
            if sysPar.nUE > 1
                for i = 2: sysPar.nUE
                    srs(i).K_0 = i -1;
                end
            end
            
            sysPar.nFrames = 1/ carrier.SlotsPerFrame;
            sysPar.SigRes = srs;
        case 'PRS'
            sysPar.RSPeriod = 8;
            prs = nr.PRSConfig;
            prs.NumRB = carrier.NSizeGrid;
            prs.Periodset = [ sysPar.RSPeriod, 0];
            prs.L_start = 0;
            prs.L_prs = 12; % usually consisent with number of sweeping beams
            sysPar.SubCarrierused = carrier.NSizeGrid *12 /prs.KTC;
            prs = repmat(prs, 1, sysPar.nBS);
            if sysPar.nBS > 1
                for i = 2 :sysPar.nBS
                    prs(i).K_offset = i -1;
                end
            end
            sysPar.nFrames = 1/ carrier.SlotsPerFrame *sysPar.RSPeriod;
            sysPar.SigRes = prs;
    end
else
    switch sysPar.SignalType
        case 'CSIRS'
            csirs = nr.CSIRSConfig;
            csirs.Periodset = [ sysPar.RSPeriod, 0];
            csirs.NumRB = carrier.NSizeGrid;
            csirs.Row = 5; % Correspongding to ports = 4;
            sysPar.SubCarrierused = csirs.NumRB *12 /6;
            csirs = repmat(csirs, 1, sysPar.nBS);
            for i = 2 : sysPar.nBS
                csirs(i).L0(1) = i *2; % considering time-position shift only
            end
            sysPar.SigRes = csirs;
        case 'SRS'
            srs = nr.SRSConfig;
            srs.N_ap = sysPar.nTx;
            srs.Periodset = [ sysPar.RSPeriod, 0];
            sysPar.SubCarrierused = srs.M_sc_b( srs.B_SRS +1);
            srs = repmat(srs, 1, sysPar.nUE);
            for i = 2 : sysPar.nUE
                srs(i).L_0 = 13 -i +1; % considering time-position shift only
            end
            sysPar.SigRes = srs;
        case 'PRS'
            sysPar.RSPeriod = 8;
            prs = nr.PRSConfig;
            prs.NumRB = carrier.NSizeGrid;
            prs.Periodset = [ sysPar.RSPeriod, 0];
            prs.L_start = 0;
            prs.L_prs = 12;
            prs.KTC = 12;
            sysPar.SubCarrierused = carrier.NSizeGrid *12 /prs.KTC;
            prs = repmat( prs, 1, sysPar.nBS);
            if sysPar.nBS > 1
                for i = 2 :sysPar.nBS
                    prs(i).K_offset = i -1;
                end
            end
            sysPar.nFrames = 1/ carrier.SlotsPerFrame *sysPar.RSPeriod;
            sysPar.SigRes = prs;
        otherwise
            error('Unknown signal config.');
    end
end
sysPar.nRSslot = ceil( carrier.SlotsPerFrame * sysPar.nFrames / sysPar.RSPeriod);
end
