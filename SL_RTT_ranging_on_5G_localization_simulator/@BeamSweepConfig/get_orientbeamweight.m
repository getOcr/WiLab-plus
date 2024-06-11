function [weight, beamangle, spatfreq] = get_orientbeamweight( BSC, nBeam,...
    SndDeterAngle, ArraySize, delta );
%get_orientbeamweight Generate orienting's beam information for beam based orientation.
%
% Description:
%   This function aims to generate beamforming information of determined 
%   beams for beamforming-based AOA estimation. In corresponding to the
%   methods in the function 'gen_beamorientresult.m', three estimation
%   methods are considered:
%   ( 1 ) The first estimation method is followed by the paper:
%   'Two-dimensional AoD and AoA acquisition for wideband millimeter-wave
%   systems with dual-polarized MIMO''. TWC 2017.
%   ( 2 ) The second method is a variant of ( 1 ),i.e., using three beams.
%   ( 3 ) The third method is the sum and diff beamforming method.
%
% Developer: Jia. Institution: PML. Date: 2021/08/24

Nazim = ArraySize(2); % Ant number in azimuth dimension
Nelev = ArraySize(1); % Ant number in elevation dimension
lambda = BSC.c / BSC.center_frequency;
d = lambda /2;
if any( BSC.IndOrientFind == [1 2] )
    azimbeam = ones(1,6) * SndDeterAngle(1,1);
    elevbeam = ones(1,6) * SndDeterAngle(2,1);
    %[ua-deltaa, ua+deltaa,ua,ua;ue-deltae,ue+deltae,ue,ue]
    spatfreqy = 2* pi * d / lambda * sin(azimbeam / 180 * pi ) ...
        .* sin(elevbeam / 180 * pi );
    spatfreqy = spatfreqy + [-delta 0 delta 0 0 0];
    spatfreqz = 2* pi * d / lambda * cos(elevbeam / 180 * pi );
    spatfreqz = spatfreqz + [ 0 0 0 -delta 0 delta];
    spatfreq = [ spatfreqy; spatfreqz ];
    beamangle = zeros(size(spatfreq));
    beamangle(2,:) = acos(spatfreqz /(pi*2*d/lambda) ) /pi *180;
    beamangle(1,:) = asin(spatfreqy /(pi*2*d/lambda) ./ ...
        sin( beamangle(2,:) /180 *pi ) ) /pi *180;
    weighty = exp( 1i* spatfreqy .* ( (0: Nazim-1).'- (Nazim-1) /2 ) );
    weightz = exp( 1i* spatfreqz .* ( (0: Nelev-1).'- (Nelev-1) /2 ) );
    weight = zeros( prod( ArraySize ), nBeam);
    for l = 1 : 6
        weight(:, l) = kron( weighty(:, l), weightz(:, l) );
    end
elseif BSC.IndOrientFind == 3
    azimbeam = ones(1,3) * SndDeterAngle(1, 1);
    elevbeam = ones(1,3) * SndDeterAngle(2, 1);
    spatfreqy = 2* pi * d / lambda * sin( azimbeam / 180 * pi ) .* ...
        sin(elevbeam / 180 * pi );
    spatfreqz = 2* pi * d / lambda * cos( elevbeam / 180 * pi );
    spatfreq = [ spatfreqy; spatfreqz ];
    beamangle = zeros( size(spatfreq) );
    beamangle(2,:) = acos( spatfreqz /(2* pi* d/ lambda) ) /pi *180;
    beamangle(1,:) = asin( spatfreqy /(2* pi* d/ lambda) ./ ...
        sin( beamangle(2,:) /180 *pi ) )/pi *180;
    tempy = [ [ ones(1, Nazim/2 ), -ones(1, Nazim/2 ) ].', ones(Nazim, 2) ];
    tempz = [ ones(Nelev, 2), [ ones(1, Nelev/2), -ones(1, Nelev/2) ].' ];
    weighty = exp( 1i* spatfreqy .* ( (0: Nazim-1).'- (Nazim-1) /2) ) .* tempy;
    weightz = exp( 1i* spatfreqz .* ( (0: Nelev-1).'- (Nelev-1) /2) ) .* tempz;
    weight = zeros( prod(ArraySize), nBeam );
    for l = 1 : 3
        weight(:,l) = kron( weighty(:,l), weightz(:,l) );
    end
end