function H = channelestimate(carrier, rxGrid,rsInd,RsSym,nTx,cdmLengths);
%channelestimate Estimate channel coefficiences by least square based method.
%
% Description:
%   This function aims to perform LS-based channel estimation to obtain 
%   channel frequency response which meeting the NR signal systems as 
%   defined in 3GPP standards. The interpolation in frequency domain is not
%   considered in this function.
%   The dimension of H is (nSC * nSym * nRx * nTx)
%
%	Developer: Jia. Institution: PML. Date: 2021/08/18

nFDCDM = cdmLengths(1);
nTDCDM = cdmLengths(2);
[nSC, nSym, nRx] = size(rxGrid);
H = zeros(nSC, nSym, nRx, nTx);
RefGrid = nr.ResourceGrid( carrier, nTx);
RefGrid( rsInd ) = RsSym;
for iTx = 1 : nTx
    for iRx = 1 : nRx
        H_slot = nr.ResourceGrid( carrier, 1);
        nom = rxGrid(:,:, iRx);
        denom = RefGrid(:,:, iTx);
        Ind = find(denom ~= 0);
        [nsubSC,nsubSym] = ind2sub( [nSC nSym], Ind(:) );
        H_LS = nom(Ind) ./ denom(Ind);
        H_slot( Ind ) = H_LS;
        if nFDCDM > 1
            uniSym = unique( nsubSym );
            for l = 1 : length( uniSym )
                iSym = uniSym(l);
                H_SC = H_slot( nsubSC, iSym);
                k_rest = mod( length(H_SC), nFDCDM );
                H_SC_nFD = reshape( H_SC(1: end -k_rest ), nFDCDM, [] );
                H_SC_nFD = repmat( mean( H_SC_nFD, 1), [nFDCDM 1] );
                H_SC = reshape( H_SC_nFD, [], 1 );
                H_slot( nsubSC, iSym ) = H_SC;
            end
        end
        if nTDCDM > 1
            uniSC = unique( nsubSC );
            for k = 1 : length( uniSC )
                iSC = uniSC(k);
                H_Sym = H_slot( iSC, nsubSym);
                l_rest = mod( length(H_Sym), nTDCDM );
                
                H_Sym_nTD = reshape( H_Sym( 1 :end -l_rest ), nTDCDM, [] );
                H_Sym_nTD = repmat( mean( H_Sym_nTD, 1), [nTDCDM 1] );
                H_Sym = reshape( H_Sym_nTD, [], 1);
                H_slot( iSC, nsubSym) = H_Sym;
            end
        end
       H(:,:, iRx, iTx) = H_slot; 
    end
end

end