classdef SysLayoutConfig < handle
    %SysLayoutConfig Initialize the system layout for simulator.
    %
    % Description:
    %   This class aims to initialize all system parameters configuration
    %   for system-level wireless communication links. The specific the
    %   BS/UE array configuration is also considered herein. Note that all
    %   the configurations are compatible with the 3GPP TR 38.901 v16.1.0.
    %
    % Developer: Jia. Institution: PML. Date: 2021/10/14
    
    %------------------------
    % system layout
    properties
        
        % Initial position vectors of BSs. Three-dimension position
        % information shall be presented in cartesian coordinates. The
        % positions of different BSs are given by columns.
        BS_position = [0; 0; 3];
        
        % Initial position vectors of UEs. Three-dimension position
        % information shall be presented cartesian coordinates. The
        % positions of different UEs are given by columns.
        UE_position = [10; 10; 1.5];
        
        % Orientations of BSs. Three-dimension angles are presented in
        % radians, i.e., [bear;downtilt;slant]. If the number of columns is
        % equal to one, then the orientations of all BSs are the same. The
        % orientation of each BS should be configured by different columns.
        BSorientation = [0; 0; 0];
        
        % Orientations of UEs. Three-dimension angles are set in radians.
        % i.e., [bear;downtilt;slant]. If the number of columns is equal to
        % one, then the orientations of all UEs are the same. The
        % orientation of each UE should be configured by different columns.
        UEorientation = [0; 0; 0];
        
        % Indicator of the 3-sector BS. The value must be 0 or 1. When the
        % value is 1, then 3-sector arrays are considered for a BS.
        Ind_3_sector = 0;
        
        % Distance from the BS array to the pole in m. The default value is 0;
        dis_2pole = 0;
        
        % Speed of UEs. If single scalar is assigned, then the speeds of
        % all UEs are the same. Otherwise, the value should be given by a
        % tuple.
        UE_speed = 3/3.6; % (m/s)
        
        % Accelerated Speed of UEs. If single scalar is assigned, then the
        % value of all UEs are the same. Otherwise, the value should be
        % given by a tuple.
        UEAcceSpeed = 0;
        
        % UE moving direction. azim and elev angles are given in radians.
        % i.e. [azim;elev]. If the number of columns is equal to one, then
        % the directions of all UEs are the same. The moving directions of
        % each UEs are configuratedd by different columns.
        UE_mov_direction = [0, pi/2].'; % [azim, elev]
        
        % Carrier frequency in Hz.
        center_frequency = 2e9;
        
        % Transmit bandwidth in Hz.
        bandwidth = 1e6;
    end
    
    %------------------
    % array configuration
    properties
        
        % BS array config. Mg and Ng denote the number of panels
        % in a column and in a row, respectively. M and N denote the number
        % of antenna elements in a column and a row on each panel,
        % respectively. The values of [Mg Ng M N P] are given in a tuple.
        % P = 1 means single vertical polarization, and P=2 means cross
        % polarization.
        BSarrayTuple = [1 1 1 1 1];
        
        % UE array config. Mg and Ng denote the number of panels
        % in a column and in a row, respectively. M and N denote the number
        % of antenna elements in a column and a row on each panel,
        % respectively. The values of [Mg Ng M N P] are given in a tuple.
        UEarrayTuple = [1 1 1 1 1];
        
        % BS antenna power pattern. The value must be one of {1,...5}. The
        % patterns for each value are generated according to 3GPP TR 38.802
        % Table A.2.1. Please see more information in the function
        % 'antpowerpattern.m'.
        % The default value for BS is 1, which corresponding to 3-sector and
        % above-6GHz patch antenna.
        BSantsty = 1;
        
        % UE antenna power pattern. The value must be one of {6,7}. The
        % patterns for each value are generated according to 3GPP TR 38.802
        % Table A.2.1-8. Please see more information in the function
        % 'antpowerpattern.m'.
        % The default value for UE is 7, which corresponding to omni-antenna.
        UEantsty = 7;
        
        % Inter-antenna and -panel spacing config in wavelength for BS. If
        % the value is not empty, then this shall be [d_vg d_hg d_v d_h].
        % For example, if 0.5lambda length is considered for inter-antenna
        % vertial spacing, then set d_v = 0.5. Please see the function
        % 'AntArrayConfig' for more information.
        BSSpacTuple =[];
        
        % Inter-antenna and -panel spacing config. in wavelength for UE. If
        % the value is not empty, then this shall be [d_vg d_hg d_v d_h].
        % For example, if 0.5lambda length is considered for inter-antenna
        % vertial spacing, then set d_v = 0.5. Please see the function
        % 'AntArrayConfig' for more information.
        UESpacTuple =[];
        
        % Cross-polarized angles configuration for BS. If the value is not
        % empty, then the value must be 1 or 0; 1 represents (+/-45 degr)
        % and 0 for (0/90 deg).
        BSX_pol = [];
        
        % Cross-polarized angles configuration for UE. If the value is not
        % empty, then the value must be 1 or 0; 1 represents (+/-45 degr)
        % and 0 for (0/90 deg).
        UEX_pol = [];
        
    end
    
    properties(SetAccess = private)
        % Wavelength of carrier frequency
        wavelength;
        % Number of BS.
        nBS;
        % Number of UE.
        nUE;
        % Array set of BSs.
        BS_array = AntArrayConfig(2e9);
        % Array set of UEs.
        UE_array = AntArrayConfig(2e9);
        c = 299792458;  % light speed
    end
    
    methods
        
        % BS positions
        function obj = set.BS_position(obj, value)
            if length( value(:,1) ) == 3 && isnumeric(value) && isreal(value )
                obj.BS_position = value;
            else
                error('SysLayoutConfig: Wrong input of BS_position.');
            end
        end
        
        % UE positions
        function obj = set.UE_position(obj, value)
            if length(value(:,1)) == 3 && isnumeric(value) && isreal(value )
                obj.UE_position = value;
            else
                error('SysLayoutConfig: Wrong input of UE_position.');
            end
        end
        
        % BS orientations
        function out = get.BSorientation(obj)
            temp_pos = obj.BSorientation;
            if all( size(temp_pos) == [3 1] )
                out = repmat( temp_pos, 1, obj.nBS );
            elseif all( size(temp_pos) == [3 obj.nBS] )
                out = temp_pos;
            else
                error('SysLayoutConfig:size(BSorientation) must be 3*1 or 3*nBS.');
            end
        end
        function obj = set.BSorientation(obj, value)
            if length(value(:,1)) == 3 && isnumeric(value) && all( all(value <= 2*pi) ) ...
                    && all( all(value >= 0 ) )
                obj.BSorientation = value;
            else
                error('SysLayoutConfig: wrong input of BSorientation.');
            end
        end
        
        % UE orientations
        function out = get.UEorientation(obj)
            temp_pos = obj.UEorientation;
            if all(size( temp_pos ) == [3 1])
                out = repmat( temp_pos, 1, obj.nUE );
            elseif all( size( temp_pos ) == [3 obj.nUE] )
                out = temp_pos;
            else
                error('SysLayoutConfig:size(UEorientation) must be 3*1 or 3*nUE.');
            end
        end
        function obj = set.UEorientation(obj, value)
            if length(value(:,1)) == 3 && isnumeric(value) && all( all(value <= 2*pi) ) ...
                    && all( all(value >= 0 ) )
                obj.UEorientation = value;
            else
                error('SysLayoutConfig: UEorientation must be in [0 2*pi]');
            end
        end
        
        % Indicator of 3-sector BS.
        function obj = set.Ind_3_sector(obj, value)
            if all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) && any( value == [0 1] )
                obj.Ind_3_sector = value;
            else
                error('SysLayoutConfig: Wrong input of Ind_3_sector.');
            end
        end
        
        % Distance from the BS array to the pole in m.
        function obj = set.dis_2pole(obj, value)
            if all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) && value >= 0
                obj.dis_2pole = value;
            else
                error('SysLayoutConfig: Wrong input of Ind_3_sector.');
            end
        end
        
        % UE speed
        function out = get.UE_speed(obj)
            temp_speed = obj.UE_speed;
            if all(size(temp_speed) == [1 1])
                out = repmat(temp_speed,1,obj.nUE);
            elseif numel(temp_speed) == obj.nUE
                out = temp_speed;
            else
                error('SysLayoutConfig: numel(UE_speed) must be nUE.');
            end
        end
        function obj = set.UE_speed(obj, value)
            if  isnumeric(value) && isreal(value) && any(value >= 0 )
                obj.UE_speed = value;
            else
                error('SysLayoutConfig: Wrong input of UE_speed.');
            end
        end
        
        % UE acelerated speed
        function out = get.UEAcceSpeed(obj)
            temp_Accespeed = obj.UEAcceSpeed;
            if all(size(temp_Accespeed) == [1 1])
                out = repmat(temp_Accespeed,1,obj.nUE);
            elseif numel(temp_Accespeed) == obj.nUE
                out = temp_Accespeed;
            else
                error('SysLayoutConfig: numel(UEAcceSpeed) must be nUE.');
            end
        end
        function obj = set.UEAcceSpeed(obj, value)
            if  isnumeric(value) && isreal(value) && any(value >= 0 )
                obj.UEAcceSpeed = value;
            else
                error('SysLayoutConfig: Wrong input of UEAcceSpeed.');
            end
        end
        
        % UE moving direction
        function out = get.UE_mov_direction(obj)
            temp_dir = obj.UE_mov_direction;
            if all(size(temp_dir) == [2 1])
                out = repmat(temp_dir,1,obj.nUE);
            elseif numel(temp_dir) == 2 * obj.nUE
                out = temp_dir;
            else
                error('SysLayoutConfig: numel(UE_mov_direction) must be 2*nUE.');
            end
        end
        function obj = set.UE_mov_direction(obj, value)
            if  length(value(:,1)) == 2 && isnumeric(value) && all( all(value <= 2*pi) ) ...
                    && all( all(value >= -pi*2 ) )
                obj.UE_mov_direction = value;
            else
                error('SysLayoutConfig: Wrong input of UE_mov_direction.');
            end
        end
        
        % Carrier frequency
        function obj = set.center_frequency(obj, value)
            if all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0
                obj.center_frequency = value;
            else
                error('SysLayoutConfig: Wrong input of center_frequency.');
            end
        end
        
        % Bandwidth
        function obj = set.bandwidth(obj, value)
            if all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0
                obj.bandwidth = value;
            else
                error('SysLayoutConfig: Wrong input of bandwidth.');
            end
        end
        
        % BS array config.
        function obj = set.BSarrayTuple(obj, value)
            if length(value) == 5 && isreal(value) && isnumeric(value) &&...
                    all( all(value >= 0 ) )
                obj.BSarrayTuple = value;
            else
                error('SysLayoutConfig:  Wrong input of BSarrayTuple.');
            end
        end
        
        % UE array config.
        function obj = set.UEarrayTuple(obj, value)
            if length(value) == 5 && isreal(value) && isnumeric(value) &&...
                    all( all(value >= 0 ) )
                obj.UEarrayTuple = value;
            else
                error('SysLayoutConfig:  Wrong input of UEarrayTuple.');
            end
        end
        
        % BS antenna style
        function obj = set.BSantsty(obj, value)
            if isreal(value) && isnumeric(value) && any(value == [1 2 3 4 5 6 7] )
                obj.BSantsty = value;
            else
                error('SysLayoutConfig:  Wrong input of BSantsty.');
            end
        end
        
        % UE antenna style
        function obj = set.UEantsty(obj, value)
            if isreal(value) && isnumeric(value) && any(value == [6 7] )
                obj.UEantsty = value;
            else
                error('SysLayoutConfig:  Wrong input of UEantsty.');
            end
        end
        
        % BS spacing config
        function obj = set.BSSpacTuple(obj, value)
            if isreal(value) && isnumeric(value) && all(value > 0 )
                obj.BSSpacTuple = value;
            else
                error('SysLayoutConfig:  Wrong input of BSSpacTuple.');
            end
        end
        
        % UE spacing config
        function obj = set.UESpacTuple(obj, value)
            if isreal(value) && isnumeric(value) && all(value > 0 )
                obj.UESpacTuple = value;
            else
                error('SysLayoutConfig: Wrong input of UESpacTuple.');
            end
        end
        
        % BS cross-polarized angles
        function obj = set.BSX_pol(obj, value)
            if isreal(value) && isnumeric(value) && any(value == [0 1] )
                obj.BSX_pol = value;
            else
                error('SysLayoutConfig: Wrong input of BSX_pol.');
            end
        end
        
        % UE cross-polarized angles
        function obj = set.UEX_pol(obj, value)
            if isreal(value) && isnumeric(value) && any(value == [0 1] )
                obj.UEX_pol = value;
            else
                error('SysLayoutConfig: Wrong input of UEX_pol.');
            end
        end
        
        % Wavelength
        function out = get.wavelength(obj)
            out = obj.c / obj.center_frequency;
        end
        % Number of BS
        function out = get.nBS(obj)
            out = length( obj.BS_position(1,:) );
        end
        % Number of UE
        function out = get.nUE(obj)
            out = length( obj.UE_position(1,:) );
        end
        
        % functions
        function get_BS_UE_array_config(obj)
            for iBS = 1 : obj.nBS
                obj.BS_array(1,iBS) = AntArrayConfig(obj.center_frequency,...
                    obj.BSarrayTuple, obj.BSorientation(:,iBS), obj.Ind_3_sector,...
                    obj.BSantsty, obj.BSSpacTuple, obj.BSX_pol, obj.dis_2pole);
            end
            for iUE = 1 : obj.nUE
                obj.UE_array(1,iUE) = AntArrayConfig(obj.center_frequency,...
                    obj.UEarrayTuple, obj.UEorientation(:,iUE),0,obj.UEantsty,...
                    obj.UESpacTuple,obj.UEX_pol);
            end
        end
    end
end