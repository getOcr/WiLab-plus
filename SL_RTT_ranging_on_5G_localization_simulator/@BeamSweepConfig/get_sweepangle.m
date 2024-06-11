function beamangle = get_sweepangle(BSC,numBeams,ArraySize,azimBmRange,elevBmRange);
%get_sweepangle Generate sweeping angles for beam sweeping.
%
% Description:
%   This function is used to generate beam angles for beam sweeping. The
%   dimension of BeamAng shall be 2 * numBeams. Beam Angles's should be
%   limited by 3dB beam width.

beamangle = zeros(2, numBeams); %azim; elev
Nazim = ArraySize(2); % Ant number in azimuth dimension
Nelev = ArraySize(1); % Ant number in elevation dimension
lambda = BSC.c/BSC.center_frequency;
d = lambda /2;
% Bandwidth of beams
azimBW = 0.886* lambda /d /Nazim /pi *180; % 3 dB bandwidth
elevBW = 0.886* lambda /d /Nelev /pi *180; % 3 dB bandwidth
% Beam angles per dimension
if Nazim > 1 && Nelev > 1
    if  (isempty(BSC.IndSweepOrient))
        switch numBeams
            case 4
                NazimSweep = 2;
                NelevSweep = 2;
            case 8
                NazimSweep = 4;
                NelevSweep = 2;
            case 12
                NazimSweep = 6;
                NelevSweep = 2;
            otherwise
                error('WrongInput: get_sweepangle. ');
        end
    elseif strcmpi(BSC.IndSweepOrient,'azimuth')
        NazimSweep = numBeams;
        NelevSweep = 1;
    elseif strcmpi(BSC.IndSweepOrient,'elevation')
        NazimSweep = 1;
        NelevSweep = numBeams;
    end
    
    azimInterval = ( azimBmRange(2) - azimBmRange(1) )/(NazimSweep -1);
    if azimInterval <= azimBW
        azimBeamAng = (azimBmRange(1): azimInterval : azimBmRange(2) );
    else
        azimBeamAng = azimBmRange(1)+(0:NazimSweep-1)*azimBW;
    end
    
    elevInterval = ( elevBmRange(2) - elevBmRange(1) )/(NelevSweep -1);
    if elevInterval <= elevBW
        elevBeamAng = (elevBmRange(1): elevInterval : elevBmRange(2) );
    else
        elevBeamAng = elevBmRange(1) + (0:NelevSweep-1)*elevBW;
    end
elseif  Nelev == 1 && Nazim == 1
    NazimSweep = numBeams;
    NelevSweep = 1;
    azimBeamAng = zeros(1,numBeams);
    elevBeamAng = elevBmRange(1);
elseif Nelev == 1
    NazimSweep = numBeams;
    NelevSweep = 1;
    azimInterval = ( azimBmRange(2) - azimBmRange(1) )/(NazimSweep -1);
    if azimInterval <= azimBW
        azimBeamAng = (azimBmRange(1): azimInterval : azimBmRange(2) );
    else
        azimBeamAng = azimBmRange(1)+(0:NazimSweep-1)*azimBW;
    end
    elevBeamAng = elevBmRange(1); 
else
    NelevSweep = numBeams;
    NazimSweep = 1;
    azimBeamAng = 0;
    elevInterval = ( elevBmRange(2) - elevBmRange(1) )/(NelevSweep -1);
    if elevInterval <= elevBW
        elevBeamAng = (elevBmRange(1): elevInterval : elevBmRange(2) );
    else
        elevBeamAng = elevBmRange(1)+(0:NelevSweep-1)*elevBW;
    end
end
% beam angles matrix
beamangle(1,:) = kron(ones(1,NelevSweep), azimBeamAng);
beamangle(2,:) = kron(elevBeamAng, ones(1,NazimSweep));
end



