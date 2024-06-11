function result = toa_dbf(PE,data);
%toa_dbf calculate toa via dbf
%
% DESCRIPITION
%   The dimension of data is nSC * nRx * nTx. One of nRx and nTx should be
%   1. 
%
% Developer: Jia. Institution: PML. Date: 2022/05/20
data1 = data;
[nSC,~] = size(data1);
freq_index=(1:16:nSC).';
%take nRx dimension as nsnapshot
range= (0:0.05:87).';
range = permute(range, [2 3 4 1]);
a = exp(-1i * 2 * pi * (freq_index) * PE.deltaf .* range/PE.c);
RangeEst = sum( abs(sum(conj(a) .* data1(freq_index,:),1) ) .^2, [2 3] );
% plot(squeeze(RangeEst))
% size(RangeEst)
[~,Sub]=max(RangeEst);
result=range(Sub);
end
