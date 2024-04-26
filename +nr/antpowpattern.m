function [Aant,info] = antpowpattern(azim,elev,num)
%antpowpattern Generate antenna power pattern according 3GPP standards.
%
% Developer: Jia. Institution: PML. Date: 2021/08/18

switch num
    case 1 % BS: 3 sector above 6GHz, TR38.802 Table A.2.1-6
        theta_3db = 65; SLAv = 30; phi_3db = 65; Amax = 30; eletilt =90; ...
            Gmax = 8; %dbi
        A1 = - min( 12 * ( ( azim / pi * 180 ) / phi_3db ).^2, Amax );
        A2 = - min( 12 * ( ( elev / pi * 180 -90 ) / theta_3db ).^2, SLAv );
        Aant = -min(-(A1+A2),Amax);
    case 2 % BS: indoor single sector, above 6GHz, TR38.802 Table A.2.1-7
        theta_3db = 65; SLAv = 25; eletilt = 90; phi_3db = []; Amax = 25; ...
            Gmax = 5; %dbi
        Aant = - min( 12 * ( ( elev / pi * 180 -90 ) / theta_3db ).^2, SLAv);
    case 3 % BS: indoor 3-sector, above 6GHz, TR38.802 Table A.2.1-7
        theta_3db = 65; SLAv = 25; phi_3db = 65; Amax = 25; eletilt = 110;...
            Gmax = 8; %dbi
        A1 = - min( 12 * ( ( azim / pi * 180 ) / phi_3db ).^2, Amax );
        A2 = - min( 12 * ( ( elev / pi * 180 -90 ) / theta_3db ).^2, SLAv );
        Aant = - min( - ( A1 + A2 ), Amax );
    case 4 % BS: indoor wall-mount, above 6GHz, TR38.802 Table A.2.1-7
        theta_3db = 90; SLAv = 25; phi_3db = 90; Amax = 25; eletilt =90;...
            Gmax = 5; %dbi
        A1 = - min( 12 * ( ( azim / pi * 180 ) / phi_3db ).^2, Amax );
        A2 = - min( 12 * ( ( elev / pi * 180 -90 ) / theta_3db ).^2, SLAv );
        Aant = -min(-(A1+A2),Amax);
    case 5 % BS: indoor cell-mount, above 6GHz, TR38.802 Table A.2.1-7
        theta_3db = 130; SLAv = 25; phi_3db = 130; Amax = 25; eletilt =90;...
            Gmax = 5; %dbi
        A1 = - min( 12 * ( ( azim / pi * 180 ) / phi_3db ).^2, Amax );
        A2 = - min( 12 * ( ( elev / pi * 180-90) / theta_3db ).^2, SLAv );
        Aant = - min( -( A1 + A2 ), Amax );
    case 6 % UE: above 6GHz, TR38.802 Table A.2.1-8
        theta_3db = 65; SLAv = 25; phi_3db = 65; Amax = 25; eletilt =90;...
            Gmax = 5; %dbi
        A1 = - min( 12 * ( ( azim / pi * 180 ) / phi_3db ).^2, Amax );
        A2 = - min( 12 * ( ( elev / pi * 180 -90 ) / theta_3db ).^2, SLAv );
        Aant = -min(-(A1+A2),Amax);
    case 7 % UE omni
        theta_3db = []; SLAv = []; phi_3db = []; Amax = 30; eletilt = 90;...
            Gmax = 0; %dbi
        Aant = zeros( size(azim) );
end
info.theta_3db = theta_3db;
info.SLAv = SLAv;
info.phi_3db = phi_3db;
info.Amax = Amax;
info.eletilt = eletilt;
info.Gmax = Gmax;
end
% Aant(Aant<=-Amax)=-Amax;
% Aant = Aant+Amax;
% figure(1)
% azim_grid = repmat(azim,length(elev),1);
% elev_grid = repmat(elev,1,length(azim));
% [x,y,z] = bs.sph2cart(azim_grid,elev_grid,Aant);
% [xb,yb,zb] = bs.cartYrotate(x,y,z,-(eletilt-90)/180*pi);
% surf(xb, yb, zb,'EdgeColor','#4DBEEE','FaceColor','c');grid on; axis equal;
% grid on;
% xlabel('x');ylabel('y');zlabel('z');