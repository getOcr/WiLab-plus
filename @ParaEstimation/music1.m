function result = music1(PE, data)
%music1 1-dimension music algorithm.
%
% DESCRIPITION
%   The dimension of data is nSC * nRx * nTx. One of nRx and nTx should be
%   1. Anticlockwise is consisent with
%   positive angles.
%
% Developer: Jia. Institution: PML. Date: 2021/08/06

[~,L] = size(data);
if L == 1
    data = permute(data, [1 3 2]);
end
data=data.'; %  nAx * ndelf  %take ndelf dimension as nsnapshot
Rx = data * data';%  covariance matrix
[M,~]=size(Rx);
[EgV, D] = eig(Rx);
Egv = diag(D);
[~,b] = sort(Egv); % ordering from minimum
target_Num = PE.nTarget; % signal number
i = b(1 : M-target_Num ); %noise subspace index
UN = EgV(:,i);   % noise subspace
Interval1 = 0.1;
theta= -pi*4/9 : Interval1: pi*4/9;
Tmp_cg = one_music(L, theta, UN);
Interval2 = 0.005;
theta= Tmp_cg - Interval1 : Interval2: Tmp_cg + Interval1;
result = one_music(L, theta, UN);
end
function result = one_music(L, theta, UN);
AngleEst = zeros(1,  length( theta ));
for k = 1 : length( theta )
    a = exp(1i * pi * ( 0: L-1 )'* sin( theta(k) ) );
    AngleEst(1,k)=10*log10(1/abs(a'*(UN*UN')*a));
end
[~, Sub] = max(AngleEst);
result = theta(Sub);
end