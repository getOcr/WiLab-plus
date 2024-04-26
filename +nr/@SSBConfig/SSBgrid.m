function [ssbGrid] = SSBgrid(ssb)
%SSBgrid Generate the SSB grid.
%
% Description:
%   This function aims to generate SSB grid according to 3GPP TS38.211
%   v16.4.0 clause 7.4.3.
%
%	Developer: Jia. Institution: PML. Date: 2021/08/13

ssbGrid = zeros(240, 4);
[ psssymbols, pssindices] = PSSsymbols_indices(ssb);
ssbGrid(pssindices) = psssymbols;
[ ssssymbols, sssindices] = SSSsymbols_indices(ssb);
ssbGrid(sssindices) = ssssymbols;
[ dmrssymbols, dmrsindices] = DMRS_PBCHsymbols_indices(ssb);
ssbGrid(dmrsindices) = dmrssymbols;
[ pbchsymbols, pbchindices] = PBCHsymbols_indices(ssb);
ssbGrid(pbchindices) = pbchsymbols;
end
