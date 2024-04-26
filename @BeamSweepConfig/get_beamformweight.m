function weight = get_beamformweight(BSC, BeamAng, ArraySize);
%get_beamformweight Generate beamforming weights according to the determined beam angles.
%
%  DESCRIPTION
%   This function aims to generate beamforming weights from the determined 
%   beam angles. The dimension of beamforming weights is  2 * numbeams. 
%   In this fucntion, the weights are calculated according to the steering
%   vectors which similar to DFT beams.
%
% Developer: Jia. Institution: PML. Date: 2021/07/26

[~, L] = size(BeamAng); % N azim elev  L beam number
lambda = BSC.c/BSC.center_frequency;
d = lambda/2;
weight = zeros( prod(ArraySize), L);
for nn = 1 : L
    weight(:, nn) = bs.steervector( ArraySize, BeamAng(1, nn) /180 *pi,...
        BeamAng(2, nn) /180 *pi, d, lambda, 1);
end
end