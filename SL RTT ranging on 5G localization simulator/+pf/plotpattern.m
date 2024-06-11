function plotpattern(ArraySize,BeamAng,Orient,Pos,Unit,Ind_omni)
%plotpattern Generate beam pattern for an array.
myaxis = (0: ArraySize(2)-1);
mzaxis = (0: ArraySize(1)-1);
azim = -pi:0.02:pi;
elev = 0:0.02:pi;
azim_grid = repmat(azim,length(elev),1);
elev_grid = repmat(elev.',1,length(azim));
BeamAng = squeeze(BeamAng);
lambda = 1;
d = lambda/2;
for nn = 1 : length(Pos(1,:))
    % weight
    weight =  bs.steervector(ArraySize, BeamAng(1,nn) /180 *pi, ...
        BeamAng(2,nn) /180*pi, d, lambda, 1);
    % array manifold
    array = zeros( length(mzaxis) * length( myaxis), length( azim), length(elev));
    P = zeros(length(azim), length(elev));
    for i = 1 : length(azim)
        for j = 1 : length(elev)
            array(:,i,j) = bs.steervector(ArraySize, azim(i), elev(j), d, lambda,1);
            P(i,j) = abs(sum( array(:,i,j) .* conj(weight),'all'))^2;
        end
    end
    P_dB = 10 *log10(P);
    P_dB = P_dB - max(P_dB, [], 'all');
    %============
    if Ind_omni ~= 1
        [Fant,antinfo] = nr.antpowpattern( azim, elev.', 1);
    else
        [Fant,antinfo] = nr.antpowpattern(azim, elev.', 7);
    end
    Farray = Fant + P_dB.';
    Farray( Farray <= -antinfo.Amax) = -antinfo.Amax;
    Gain = get_gain(ArraySize, Unit, BeamAng, Ind_omni)/2;
    %============
    if strcmp(Unit,'linear')
        P_lin =10 .^(Farray /10);
        P_lin = P_lin/max(P_lin, [], 'all') *10;
        [x,y,z] = bs.sph2cart(azim_grid + Orient(nn), elev_grid, P_lin ...
            *log10( Gain ) /2);
    elseif strcmp(Unit,'dB')
        [x,y,z] = bs.sph2cart(azim_grid  + Orient(nn), elev_grid, ...
            ( Farray +antinfo.Amax) /30 *Gain);
    end
    h = mesh(x + Pos(1,nn),y + Pos(2,nn),z + Pos(3,nn),...
        'EdgeColor', '#4DBEEE', 'FaceColor', 'c');
    set(h,'handlevisibility','off');
    grid on;    hold on;
end
end
function G = get_gain(ArraySize,Unit,BeamAng,Ind_omni)
% boresight gains considered only
bw_az = 65;
bw_el = 65;
if ArraySize(2) ~= 1
    bw_az = 50.7*2/(ArraySize(2) );
end
if ArraySize(1) ~= 1
    bw_el = 50.7*2/(ArraySize(1) );
end
% cos(theta) is not considered herein.
% bw_az = bw_az/cos(BeamAng(1)/180*pi);
% bw_el = bw_el/cos((BeamAng(2)-90)/180*pi);
if strcmpi(Unit,'dB')
    G = 10*log10(30000/bw_az/bw_el);
elseif strcmpi(Unit,'linear')
    G = 30000/bw_az/bw_el;
end
if Ind_omni && prod(ArraySize) == 1
   G = 2; 
end
end