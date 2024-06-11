function result=ssmusic1(PE,data)
%ssmusic1 1-dimension space-smoothing based music algorithm.
%
% DESCRIPITION
%   The dimension of data is nSC * nRx * nTx. One of nRx and nTx should be
%   1. Anticlockwise is consisent with
%   positive angles.
%
%   Developer: Jia. Institution: PML. Date: 2021/08/06

[~,L] = size(data);
nSubarray  = L - 1;
if L == 1
    data = permute(data, [1 3 2]);
end
data = data.'; %  nAx * ndelf  %take ndelf dimension as nsnapshot
Rx = data * data';%  covariance matrix
FlipEye = flip( eye(nSubarray) );
Rxfs = zeros(nSubarray, nSubarray, L-nSubarray+1);
Rxbs = zeros(nSubarray, nSubarray, L-nSubarray+1);
for ii = 1 : L -nSubarray +1
    Rxfs(:,:,ii) = Rx((ii: nSubarray+ii-1), (ii: nSubarray+ii-1) );
    Rxbs(:,:,ii) = FlipEye*conj( Rxfs(:,:,ii) )*FlipEye;
end
Rx_f = sum( Rxfs, 3 ); % forward smoothing
Rx_b = sum(Rxbs, 3 ); % backward smoothing
Rx_sm = Rx_f +Rx_b;%two-way smoothing
[M, ~] = size( Rx_sm );
[EgV, D] = eig( Rx_sm );
Egv = diag(D);
[~, b] = sort(Egv);
target_Num = PE.nTarget;
i=b(1: M -target_Num);
UN = EgV(:, i);  % noise subspace
Interval1 = 0.1;
theta= -pi*4/9 : Interval1: pi*4/9;
Tmp_cg = one_ssmusic(nSubarray, theta, UN);
Interval2 = 0.005;
theta= Tmp_cg - Interval1 : Interval2: Tmp_cg + Interval1;
result = one_ssmusic(nSubarray, theta, UN);
end

function result = one_ssmusic(nSubarray, theta, UN)
AngleEst = zeros(1, length( theta ) );
for k = 1 : length(theta)
    a = exp(1i*pi*(0:nSubarray-1)'*sin(theta(k)));
    AngleEst(1, k)=10*log(1/abs(a'*(UN*UN')*a));
end
[~,Sub]=MUSICfindpeaks(AngleEst,1);
result=theta(Sub);
end
function [Amplitude,index_final] = MUSICfindpeaks(values,TargetNumb)

index=[];
Amplitude=[];
Len=length(values);
for i=2:Len-1
    if values(i)>values(i+1)&&values(i)>values(i-1)
        Amplitude_temp=values(i);
        index_temp=i;
        Amplitude= [Amplitude,Amplitude_temp];
        index=[index,index_temp];
    end
end
[SortAmp,SortAindex]=sort(Amplitude);
L=length(SortAindex);
index_index = SortAindex(L-TargetNumb+1:L);
index_final = index(1,index_index);
end