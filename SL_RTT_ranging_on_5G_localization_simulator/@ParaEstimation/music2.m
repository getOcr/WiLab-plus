function result = music2(PE,data);
%music2 2-dimension music algorithm for angle estimation. current n*n UPA only
%
% DESCRIPITION
%   The dimension of data is nSC * nRx * nTx. One of nRx and nTx should be
%   1. Anticlockwise is consisent with
%   positive angles.
%
% Developer: Jia. Institution: PML. Date: 2022/05/19

[~,L] = size(data);
if L == 1
    data = permute(data, [1 3 2]);
end
hdata=data((1:64:end),:).'; %  nRx * ndelf  %take ndelf dimension as nsnapshot
Rx = hdata * hdata';%  covariance matrix
[M,~]=size(Rx);
[EgV, D] = eig(Rx);
Egv = diag(D);
[~,b] = sort(Egv); % ordering from minimum
target_Num = PE.nTarget; % signal number
i = b(1 : M-target_Num ); %noise subspace index
UN = EgV(:,i);   % noise subspace
Interval1 = 0.1;
azim= -pi+0.01 : Interval1: pi ;
elev= 0 : Interval1: pi/2;
Tmp_cg = twodimsearch_music(L, UN, azim, elev);
Interval2 = 0.005;
azim =  Tmp_cg(1,:)- Interval1 : Interval2: Tmp_cg(1,:) + Interval1 ;
elev = Tmp_cg(2,:)- Interval1 : Interval2: Tmp_cg(2,:) + Interval1 ;
result = twodimsearch_music(L, UN, azim, elev);
end

function result = twodimsearch_music(L, UN, azim, elev);
AngleEst = zeros(length(azim),length(elev));
for k = 1 : length(azim)
    for m = 1 : length(elev)
        a = kron( exp((0:sqrt(L)-1)' *1i *pi .*sin( -azim(k) ) .*sin( elev(m) ) ...
            ), exp((0:sqrt(L)-1)' *1i*pi .* cos( -azim(k) ) .* sin(  elev(m) ) ) );
        AngleEst(k,m)=10*log10(1/abs(a'*(UN*UN')*a));
    end
end
[~,Ind]=max(AngleEst,[],'all','linear');
[ra, cb]=ind2sub([length(azim),length(elev)],Ind);
result(1,:) = azim(ra);
result(2,:) = elev(cb);
end