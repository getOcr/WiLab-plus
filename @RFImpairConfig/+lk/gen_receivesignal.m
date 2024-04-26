function [rxWaveform] = gen_receivesignal(sysPar, carrier, data, RFI, BeamSweep);
%GEN_RECEIVESIGNAL Generate receive signal by adding wireless channels and noise
%
% Description:
% The wireless channel, beamforming, CFO, IQ imbalance, phase noise, timing
% offset, and AWGN at the receiver are included. Note that agc function
% can be used if necessary.
% input:
%    txWaveform   dimension:   nDtime * nTx * nTr
%    CIR_cell{nRr,nTr}  %CIR{1,1} : nDelayx * nTx * nRx * nRSslot
% Output: rxWaveform:   nDtime * nRx * nRr
%
% Developer: Jia. Institution: PML. Date: 2021/10/28

nRr = sysPar.nRr;
nTr = sysPar.nTr;
nRx = sysPar.nRx;
nTx = sysPar.nTx;
nRSslot = sysPar.nRSslot;
[nDtime ,~] = size(  data.txWaveform(:,:,1) );
rxWaveform = [ ];
for iRr = 1 : nRr
    rxWaveform_r = zeros(nDtime, nRx );
    for iTr = 1 : nTr
        CIR_temp = data.CIR_cell{iRr, iTr};
        rxWaveform_u = zeros(nDtime, nRx );
        for islot = 1 : nRSslot
            nSampPerSlot = nr.get_nSamPerSlot(islot, carrier, sysPar.RSPeriod);
            idxnSamples =  nSampPerSlot * (islot -1) +1 : nSampPerSlot * islot;
            % channel filtering
            for iRx = 1 : nRx
                for iTx = 1 : nTx
                    rxWaveform_u( idxnSamples, iRx ) = rxWaveform_u( idxnSamples, iRx) ...
                        + filter( ( CIR_temp(:, iTx, iRx, islot) ), ...
                        1, data.txWaveform( idxnSamples, iTx, iTr) );
                end
            end
        end
        rxWaveform_r = rxWaveform_r + rxWaveform_u;
    end
    % add rxbeamforming
    rxWaveform_r = rx_beamforming(BeamSweep, rxWaveform_r, RFI);
    % add CFO
    rxWaveform_r = rx_cfo(RFI, rxWaveform_r);
    % add Rx I/Q imbalance
    rxWaveform_r = rx_IQimbalance(RFI,rxWaveform_r);
    % add phase noise
    rxWaveform_r = rx_phasenoise(RFI, rxWaveform_r);
    % add timing offset
    rxWaveform_r = rx_timingoffset(RFI,rxWaveform_r);
    % add noise
    rxWaveform_r = rx_awgn(RFI,data.Hinfo.lsp.gainloss_dB, rxWaveform_r,iRr,iTr,sysPar);
    % add receive gain
    rxWaveform_r = nr.rx_agc(rxWaveform_r, data.Hinfo.lsp.gainloss_dB, sysPar, iRr,iTr,sysPar.IndUplink);
    rxWaveform = cat(3, rxWaveform, rxWaveform_r);        %  nDtime * nRx * nRr
    
end
end
%% ====================================================%%
