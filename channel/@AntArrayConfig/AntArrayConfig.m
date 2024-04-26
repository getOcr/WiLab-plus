classdef AntArrayConfig
    %AntArrayConfig Initialize the parameters setting for the antenna
    % array.
    %
    % Description
    %   This class aims to config basic parameters of antenna array
    %   strucutres according to the TR 38.901, partly in clause 7.3.
    %
    % Developer: Jia. Institution: PML. Date: 2021/09/24
    
    properties
        % Indicator of the 3-sector layout.
        Ind_3_sector = 0;
        % Carrier frequency in Hz.
        center_frequency;
        % Antenna power pattern. The value must be one of {1,...7}. The
        % patterns for each value are generated according to 3GPP TR 38.802
        % Table A.2.1. Please see more information in the function
        % 'antpowerpattern.m'.
        % The default value is 1, which corresponding to 3-sector and
        % above-6GHz patch antenna.
        antsty = 1;
        % Orientation of the array. Three-dimension angles are set in
        % radians for the array. i.e., [bear;downtilt;slant].
        Orientation = [0; 0; 0];
        % Number of panels in a column of the array. The default value is 1.
        Mg = 1;
        % Number of panels in a row of the array. The default value is 1.
        Ng = 1;
        % Number of antenna elements in each column on each panel. The
        % default value is 1.
        M = 1;
        % Number of antenna elements in each row on each panel. The default
        % value is 1.
        N = 1;
        % Polarization of each antenna elements of the array. The value
        % must be 1 or 2. The value 1 represents vertical polarization
        % only while 2 denotes dual cross-polarization. The default value
        % is 1.
        P = 1;
        % Vertical spacing in a Wavelength between two adjacent panels.
        d_vg = 2.5;
        % Horizontal spacing in a Wavelength between two adjacent panels.
        d_hg = 2.5;
        % Vertical spacing in a Wavelength between two adjacent antenna on
        % each panel.
        d_v = 0.5;
        % Horizontal spacing in a Wavelength between two adjacent antenna
        % on each panel.
        d_h = 0.5;
        % Cross-polarized angles configuration when P = 2. The value must
        % be one of 1 or 0. 1 represents (+/-45 degr) and 0 for (0/90 deg).
        X_pol = 1;
        % Distance from the array to the pole. The default value is 0;
        dis_2pole = 0;
        % Polarized antenna model considered as in 3GPP TR38.901 v16.1.0 -
        % clause 7.3.2. The default value is 2.
        mode = 2;
        % Positions of each antenna element in LCS.
        position_ant;
        % Polarized field of each antenna in elev angle direction with the
        % dimension: nelev(181) * nazim(361) * nantenna * P(1 or 2). The
        % value of nantenna is (M * N * Mg * Ng * 3*Ind_3_sector).
        Fth;
        % Polarized field of each antenna in azim angle direction with the
        % dimension of nelev(181) * nazim(361) * nantenna * P(1 or 2). The
        % value of nantenna is (M * N * Mg * Ng * 3*Ind_3_sector).
        Fph;
        % Information of antenna element.
        antinfo;
        % Total antenna number of an array with co-polarization.
        nant;
        % Wavelength of the carrier.
        lambda;
        % Vertical spacing in m between two adjacent panels.
        dis_vg;
        % Horizontal spacing in m between two adjacent panels.
        dis_hg;
        % Vertical spacing in m between two adjacent antenna on each panel.
        dis_v;
        % Horizontal spacing in m between two adjacent antenna on each panel.
        dis_h;
        % Grid of elevation angle. The range is [0, pi];
        grid_elev = 0 :pi/180 : pi;
        % Grid of azimuth angle. The range is [-pi, pi];
        grid_azim = -pi :pi/180 : pi;
    end
    
    properties (Hidden, Constant)
        c = 299792458;
    end
    
    
    methods
        % Constructor
        function obj = AntArrayConfig(center_frequency, arrayTuple, ...
                Orientation, Ind_3_sector, antsty, SpacTuple, X_pol, dis_2pole)
            obj.center_frequency = center_frequency;
            if exist('dis_2pole','var') && ~isempty(dis_2pole)
                obj.dis_2pole = dis_2pole;
            end
            if exist('X_pol','var') && ~isempty(X_pol)
                obj.X_pol = X_pol;
            end
            if exist('SpacTuple','var') && ~isempty(SpacTuple)
                obj.d_vg = SpacTuple(1);
                obj.d_hg = SpacTuple(2);
                obj.d_v = SpacTuple(3);
                obj.d_h = SpacTuple(4);
            end
            if exist('antsty','var') && ~isempty(antsty)
                obj.antsty = antsty;
            end
            if exist('Ind_3_sector','var') && ~isempty(Ind_3_sector)
                obj.Ind_3_sector = Ind_3_sector;
            end
            if exist('Orientation','var') && ~isempty(Orientation)
                obj.Orientation = Orientation;
            end
            if exist('arrayTuple','var') && ~isempty(arrayTuple)
                obj.Mg = arrayTuple(1);
                obj.Ng = arrayTuple(2);
                obj.M = arrayTuple(3);
                obj.N = arrayTuple(4);
                obj.P = arrayTuple(5);
            end
            % ant positions calc
            obj.lambda = obj.c / obj.center_frequency;
            obj.dis_v = obj.lambda * obj.d_v;
            obj.dis_vg = obj.lambda * obj.d_vg;
            obj.dis_h = obj.lambda * obj.d_h;
            obj.dis_hg = obj.lambda * obj.d_hg;
            obj.nant = obj.Mg * obj.Ng * obj.N * obj.M;
            obj.position_ant = obj.ant_pos_calc(obj);
            [obj.Fth, obj.Fph, obj.antinfo] = obj.get_array_pattern(obj);
        end
    end
  
    methods (Static)
        function  [Fth, Fph, info] = ants_pol_field(obj);
            % Generate polarized fields for the antenna of the array.
            Fth = []; Fph = [];
            for isec = 1 : (1 + 2 * logical(obj.Ind_3_sector) )
                if obj.P == 1
                    [Fth_s, Fph_s, info] = obj.antpolfieldGCS( obj.grid_azim, ...
                        obj.grid_elev.', obj.antsty, obj.mode, 0, ...
                        ( obj.Orientation(1) + 2/3*pi * (isec -1) ), ...
                        obj.Orientation(2), obj.Orientation(3) );
                elseif obj.P == 2
                    [Fth1, Fph1, info] = obj.antpolfieldGCS( obj.grid_azim, ...
                        obj.grid_elev.', obj.antsty, obj.mode, 0-pi/4*obj.X_pol, ...
                        ( obj.Orientation(1) + 2/3*pi * (isec -1) ),...
                        obj.Orientation(2), obj.Orientation(3) );
                    [Fth2, Fph2, ~] = obj.antpolfieldGCS( obj.grid_azim, ...
                        obj.grid_elev.', obj.antsty, obj.mode, pi/2-pi/4*obj.X_pol, ...
                        ( obj.Orientation(1) + 2/3*pi * (isec -1) ), ...
                        obj.Orientation(2), obj.Orientation(3) );
                    Fth_s = cat( 3, Fth1, Fth2); Fph_s = cat( 3, Fph1, Fph2);
                end
                Fth = cat(5, Fth, Fth_s); Fph = cat(5, Fph, Fph_s);
            end
        end
        
        function [Fth, Fph, antinfo] = get_array_pattern(obj)
            % Generate polarized fields for the the array.
            [temp1,temp2,temp3] = obj.ants_pol_field(obj);
            temp1 = repmat(temp1,1,1,1,obj.nant,1);
            temp1 = reshape(temp1, length(obj.grid_elev), ...
                length(obj.grid_azim), obj.P, []);
            Fth = permute(temp1,[1 2 4 3]);
            temp2 = repmat(temp2,1,1,1,obj.nant,1);
            temp2 = reshape(temp2, length(obj.grid_elev), ...
                length(obj.grid_azim), obj.P, []);
            Fph = permute(temp2,[1 2 4 3]);
            antinfo = temp3;
        end
    end
    
    methods
        % display antenna power pattern
        function DisAntPattern(obj);
            figure;
            for iant = 1 : 1 + 2 * logical(obj.Ind_3_sector)
                if obj.Ind_3_sector
                    subplot(2,2,iant);
                end
                A = obj.Fth(:,:,(1+ obj.nant * (iant-1) ),1).^2 + ...
                    obj.Fph(:,:,(1+ obj.nant * (iant-1) ),1).^2;
                A = 10 * log10(A);
                Amax = obj.antinfo.Amax - obj.antinfo.Gmax;
                A = real(A) + Amax;
                azim_grid = repmat(obj.grid_azim, length(obj.grid_elev), 1 );
                elev_grid = repmat(obj.grid_elev.', 1, length(obj.grid_azim) );
                [x,y,z] = bs.sph2cart(azim_grid,elev_grid,A);
                surf(x, y, z,'EdgeColor','#4DBEEE','FaceColor','c'); grid on;
                axis equal;
                title(['Antenna-',num2str(iant),' power pattern']);
                xlabel('x'); ylabel('y'); zlabel('z');
            end
        end
    end
    methods (Static)
        [Fth,Fph,info] = antpolfieldGCS(azim,elev,antsty,mode,zeta,alpha,beta,gamma);
        [Aant,info] = antpowpattern(azim,elev,num);
        [Fth1,Fph1] = antpolarizedfield(A,azim,elev,zeta,mode);
        pos = ant_pos_calc(obj);
    end
end
