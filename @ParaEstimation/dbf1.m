function result=dbf1(~,data)
%dbf1 1-dimension DBF algorithm.
%
% DESCRIPITION
%   The dimension of data is nSC * nRx * nTx. One of nRx and nTx should be
%   1. Anticlockwise is consisent with
%   positive angles.
%
% Developer: Jia. Institution: PML. Date: 2021/08/06

[~,L] = size(data);
data = data.'; %  nAx * ndelf  %take ndelf dimension as nsnapshot
theta= -pi*4/9 : 0.01: pi*4/9;
k = 1 : length(theta);
a = exp( 1i * pi * (0:L-1)'.* sin( permute(theta(k), [1 3 4 2] ) ) );
AngleEst = 10 * log( sum( abs(sum(conj(a) .* data,1) ) .^2, [2 3] ) );
[~,Sub]=max(AngleEst);
result=theta(Sub);
end
