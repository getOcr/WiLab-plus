function out = ray2cluster(h_ray, P_ray)
%ray2cluster Combine rays into clusters using cluster power compensation.
% Note: the dimension of h_ray and P_ray is ncluster*nray*nsnap.
%   The dim( out ) = [ncluster 1 nsnap].
if ~isempty(P_ray)
    if length( P_ray(1,:) ) ~= 1
        P_ray = permute(P_ray, [1 3 2]);
    end
    out = sqrt( P_ray .* sum( abs(h_ray).^2, [2 3] ) ./ sum( abs( sum(h_ray, 2)...
        ).^2, 3 ) ) .* sum(h_ray, 2);
else
    out = [];
end
end