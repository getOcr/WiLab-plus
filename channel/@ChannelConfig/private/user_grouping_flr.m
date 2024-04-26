function  Ind = user_grouping_flr(UE_pos,h_floor);
%user_grouping grouping users within one floor.
% Ind: cell(nflr,1); index of user in each floor.
h_UE = UE_pos(3,:);
nflr = floor( max(h_UE) /h_floor )+1;
Ind = cell(nflr,1);
temp = floor( h_UE/h_floor )+1;
for iflr = 1 : nflr
    Ind{iflr,1} = find(temp == iflr);
end
Ind(cellfun(@isempty,Ind)) = [];
end