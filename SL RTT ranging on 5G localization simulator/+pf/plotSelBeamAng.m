function plotSelBeamAng(sysPar,data)
%plotSelBeamAng Plot selected beam angles of beam sweeping.

[~, nRr, nTr] = size( data.SelRxBeamAng );
if ~sysPar.IndUplink
    Trname = 'BS'; Rrname = 'UE';
else
    Rrname = 'BS'; Trname = 'UE';
end
nTrgrid = repmat((1:nTr),1,nRr).';
nRrgrid = kron((1:nRr),ones(1,nTr)).';
Rowname = strcat(Trname,num2str(nTrgrid),'-',Rrname,num2str(nRrgrid));
a = 'AzimAngle';
a(2,:) = 'ElevAngle';
Colname = strcat(Trname,'-',a);
Colname(3:4,:) = strcat(Rrname,'-',a);
dat1 = reshape(data.SelTxBeamAng,2,[]);
dat1(3:4,:) = reshape(data.SelRxBeamAng,2,[]);
fig = figure;set(fig,'position',[200 200 450 330]);
uitable(fig,'Data',dat1','Position',[20 20 420 300],...
    'Columnname',Colname,'Rowname',Rowname,'FontSize',11,...
    'Fontname','Times new Roman');
end