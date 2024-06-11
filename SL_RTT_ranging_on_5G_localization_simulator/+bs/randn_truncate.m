function [out] = randn_truncate(nsize);
if exist('nsize','var') && ~isempty( nsize )
    tmp = randn(nsize);
    tmp( abs(tmp) >1 ) = randn_trun_sing;
else
    tmp = randn_trun_sing;
end
out = tmp;
end

function out = randn_trun_sing(~)
tmp = randn;
while abs(tmp) > 1
    tmp = randn;
end
out = tmp;
end