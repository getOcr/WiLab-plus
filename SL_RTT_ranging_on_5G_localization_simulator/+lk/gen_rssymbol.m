function  [rsSymbols,rsIndices,txGrid] = gen_rssymbol(sysPar, carrier, IndBmSweep);
%gen_rssymbol generate symbols to be tranmitted according to the 
% configurated resource set.
%
% Description:
%   This function aims to generate reference signal or synchronization
%   signal symbols ！！！！according to the configurated resource set.！！！！
%   Output:
%        rsSymbols   % nSCused * nRSsym * nTr   %已用的子载波？
%        rsIndices   % SRSindices  * nRSsym  * nTr
%        txGrid      % nSC * nSym * nTr %一个时隙有14个ofdm符号（carrier.SymbolsPerSlot），一个子帧（1ms）有多少时隙取决于子载波间隔
%
% Developer: Jia. Institution: PML. Date: 2021/10/28
 
nTr = sysPar.nTr;
nTx = sysPar.nTx;
rsIndices = [];
rsSymbols = [];
txGrid = [];
for iTr = 1 : nTr
    rsIndices_u = [];
    rsSymbols_u = [];
    txGrid_u = [];
    if IndBmSweep
        switch sysPar.SignalType
            case 'SSB'
                [txGrid_ant] = gen_SSBgrid( sysPar.SigRes(iTr), carrier );
                txGrid_u = repmat(txGrid_ant, 1,1, nTx);
            case 'CSIRS'
                [rsSymbols_u, rsIndices_u] = CSIRSBeamSym_Ind( sysPar.SigRes(iTr), ...
                    carrier,sysPar.nBeams );
                txGrid_s = nr.ResourceGrid(carrier, 1);
                txGrid_s(rsIndices_u) = rsSymbols_u;
                txGrid_u = repmat(txGrid_s, 1,1, nTx);
            case 'SRS'
                [rsSymbols_u, rsIndices_u] = SRSBeamSym_Ind( sysPar.SigRes(iTr), ...
                    carrier, sysPar.nBeams );
                txGrid_s = nr.ResourceGrid(carrier, 1);
                txGrid_s( rsIndices_u ) = rsSymbols_u;
                txGrid_u = repmat( txGrid_s, 1,1, nTx);
            case 'PRS'
                [rsSymbols_u, rsIndices_u] = PRSsymbols_indices( ...
                    sysPar.SigRes( iTr ), carrier );
                txGrid_s = nr.ResourceGrid(carrier, 1);
                txGrid_s(rsIndices_u) = rsSymbols_u;
                txGrid_u = repmat( txGrid_s, 1,1, nTx );
        end
    else
        for islot = 1 : carrier.SlotsPerFrame * sysPar.nFrames
            % Update slot counter
            sysPar.SigRes(iTr).Nframe = ceil( islot / carrier.SlotsPerFrame ) -1;
            sysPar.SigRes(iTr).nslot = mod( islot -1, carrier.SlotsPerFrame);%
            % Generate RS and map to slot grid
            switch sysPar.SignalType
                case 'SRS'
                    rsIndices_s = SRSindices( sysPar.SigRes(iTr), carrier );
                    rsSymbols_s = SRSsymbols( sysPar.SigRes(iTr), carrier );
                    txGrid_s = nr.ResourceGrid( carrier, nTx );
                    txGrid_s( rsIndices_s ) = rsSymbols_s;
                case 'CSIRS'
                    [rsSymbols_s, rsIndices_s] = CSIRSsymbols_indices(...
                        sysPar.SigRes(iTr), carrier );
                    txGrid_s = nr.ResourceGrid( carrier, nTx );
                    txGrid_s( rsIndices_s ) = rsSymbols_s;
                case 'PRS'
                    [rsSymbols_s, rsIndices_s] = PRSsymbols_indices(... %这个函数在nr文件夹里（为什么不用写nr.呢？）
                        sysPar.SigRes( iTr ), carrier );
                    txGrid_s = nr.ResourceGrid(carrier, 1);
                    txGrid_s(rsIndices_s) = rsSymbols_s;
                    txGrid_s = repmat(txGrid_s, 1, nTx);               
            end
            % Slots without RS signal are droped.
            if ~isempty( rsSymbols_s )
                rsIndices_u = cat(2, rsIndices_u, rsIndices_s);    %cat里维度参数为2时是水平拼接
                rsSymbols_u = cat(2, rsSymbols_u, rsSymbols_s);
                txGrid_u = cat(2, txGrid_u, txGrid_s);      
                % nSC * nRSsymperslot (* nTx)
            end
        end
    end
    rsIndices = cat(4, rsIndices, rsIndices_u);
    rsSymbols = cat(4, rsSymbols, rsSymbols_u);
    txGrid = cat(4, txGrid, txGrid_u);       
    % nSC * (nRSsymperslot* nRSslot)( * nTx) * nTr
end