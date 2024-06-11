function result = dbf2(PE,data);
%dbf2 2-dimension DBF algorithm for angle estimation. current n*n UPA only
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
Interval1 = 0.1;
azim= -pi+0.01 : Interval1: pi ;
elev= 0 : Interval1: pi/2;
Tmp_cg = twodimsearch_dbf(L, hdata, azim, elev);
Interval2 = 0.005;
azim =  Tmp_cg(1,:)- Interval1 : Interval2: Tmp_cg(1,:) + Interval1 ;
elev = Tmp_cg(2,:)- Interval1 : Interval2: Tmp_cg(2,:) + Interval1 ;
result = twodimsearch_dbf(L, hdata, azim, elev);
end

function result = twodimsearch_dbf(L, hdata, azim, elev);
a = zeros(L,1,1,length(azim),length(elev));
for k = 1 : length(azim)
    for m = 1 : length(elev)
        a(:,:,:,k,m) = kron( exp((0:sqrt(L)-1)' *1i *pi .*sin( -azim(k) ) .*sin( elev(m) ) ...
            ), exp((0:sqrt(L)-1)' *1i*pi .* cos( -azim(k) ) .* sin(  elev(m) ) ) );
    end
end
AngleEst = 10 * log10( sum( abs(sum(conj(a) .* hdata,1) ) .^2, [2 3] ) );
[~,Ind]=max(AngleEst,[],'all','linear');
[ra, cb]=ind2sub([length(azim),length(elev)],Ind);
result(1,:) = azim(ra);
result(2,:) = elev(cb);
end