function plotnodesArrays(Layout)
%plotnodesArrays Display BS and UE's arrays.
for iBS = 1 : length( Layout.BS_position(1,:) )
pf.plotArray( Layout.BS_array(iBS), Layout.BS_position(:,iBS));
end
for iUE = 1 : length(Layout.UE_position(1,:))
pf.plotArray( Layout.UE_array(iUE), Layout.UE_position(:,iUE) );
end