classdef ChannelConfig
    %ChannelConfig Initialize the channel model parameters.
    %
    % Description:
    %    This class aims to initialize the channel parameters for generating
    %    channel coefficients according to 3GPP TR 38.901 v16.1.0. Three
    %    classes of channel modeling are consdered,
    %    i.e., drop-based, segment-based, and LOS-only.
    %
    % Developer: Jia. Institution: PML. Date: 2021/10/14
    
    properties
        
        % Simulation style of channel. The value must be one of {'static',
        % 'dynamic', 'LOSonly'}. 'static' represents drop-based simulation.
        % 'dynamic' represents segment-based simulation, where time-variant
        % channel model is considered.
        channeltype = 'static';
        
        % The simulation scenarios. The value is configurated in cell
        % style. If numel(value) is equal to one, then all links are with
        % the same scenario. The value must be one of {'RMa', 'UMi', 'UMa'
        % 'Indoor', 'InF_xx'}. When NLOS case is considered, xx must be one
        % of {'SL', 'SH', 'DL', 'DH'}. The default value is {'Indoor'}.
        scenario = {'Indoor'};  % cell style
        
        % Indicator of LOS case. The value must be one of {0 1 2}.
        % If numel(Ind_LOS) == 1, then the states of all links are the same.
        % If not, the state of each link should be configurated with
        % dimension nBS * nUE.
        % Value 1 denotes LOS, Value 0 denotes NLOS, and Value 2 denotes
        % that LOS state will be determined by LOS probability in a certain
        % scenario. The default value is 1 for all.
        Ind_LOS = 1;
        
        % Indicator of transmit direction. The value must be 0 or 1.
        % Value 1 denotes uplink. Value 0 denotes downlink.
        Ind_uplink = 0;
        
        % Indicator of spatial consistence. The value must be 0 or 1. Value
        % 1 enables the spatil consistence and otherwise not.
        Ind_spatconsis = 0;
        
        % Indicator of absolute time of arrival. The value must be 0 or 1.
        % Value 1 means that abosolute TOA is considered and otherwise not.
        Ind_ABS_TOA = 1;
        
        % Indicator of ground reflection. The value must be 0 or 1.
        % Value 1 means that ground reflection is considered and otherwise
        % not.
        Ind_GR = 0;
        
        % Indicator of Outdoor to indoor (O2I). The value must be 0 1 or 2.
        % If numel(Ind_LOS) == 1, then the states of all links are the same.
        % If not, the state of each user should be configurated with
        % dimension nUE * 1. If value is 2, then O2I states are generated
        % according to probability.
        % If value is 1, then the case of O2I is considered, otherwise not.
        Ind_O2I = 0;
        
        % Indicator of gainloss. The value must be 0 or 1. The default
        % value is 1. Value 1 denotes that the gainloss is considered in
        % the channel coefficients, otherwise not.
        Ind_gainloss = 1;
        
        % Maximum velocity of scatters ( m/s). When time-vary doppler is
        % considered in segment-based simulation, the scatters moving can
        % be considered. The default value is 0;
        v_scatter_max = 0;
        
        % Number of channel coefficients samples by time. The default value
        % is 1.
        nsnap = 1;
        
        % Time interval between adjcent snaps. Or sample intervals. Note
        % that the updated distance should be within 1m, i.e., v*del_t<1m.
        interval_snap = 5e-4;  % time interval of snaps
        
        % Probability of indoor states of users.
        p_indoor = 0.5;
        
        % Probability of the building type with low loss penetration.
        p_lowloss = 0.8;
    end
    
    properties (Hidden, SetAccess = private)
        c = 299792458;  % light speed
        center_frequency;   % Carrier frequency in Hz.
        bandwidth;      % transmit bandwidth
        wavelength;  % Wavelength of carrier frequency
        nBS;
        nUE;
        unirndsm = RandStream('dsfmt19937');
        normrndsm = RandStream('dsfmt19937');
    end
    
    methods
        
        % Constructor
        function obj = ChannelConfig(Layout);
            obj.nBS = Layout.nBS;
            obj.nUE = Layout.nUE;
            obj.wavelength = Layout.wavelength;
            obj.bandwidth = Layout.bandwidth;
            obj.center_frequency = Layout.center_frequency;
        end
        
        % Channel_Style
        function obj = set.channeltype(obj, value)
            if ~(strcmpi(value, 'static') || strcmpi(value, 'dynamic')...
                    || strcmpi(value, 'LOSonly') )
                error('ChannelParaConfig: Wrong input of Channel_Style.');
            else
                obj.channeltype = value;
            end
        end
        
        % Scenarios
        function out = get.scenario( obj )
            temp_scen = obj.scenario;
            if all(size(temp_scen) == [1 1])
                out = repmat( temp_scen,obj.nBS,obj.nUE );
            elseif all( size(temp_scen) == [obj.nBS obj.nUE] )
                out = temp_scen;
            else
                error('ChannelParaConfig: Wrong input of scenario.');
            end
        end
        function obj = set.scenario(obj, value)
            if iscell(value)
                obj.scenario = value;
            else
                error('ChannelParaConfig: Wrong input of scenario.');
            end
        end
        
        % Ind_LOS
        function out = get.Ind_LOS( obj )
            temp_Ind_LOS = obj.Ind_LOS;
            if all(size(temp_Ind_LOS) == [1 1])
                out = repmat( temp_Ind_LOS,obj.nBS,obj.nUE );
            elseif all( size(temp_Ind_LOS) == [obj.nBS obj.nUE] )
                out = temp_Ind_LOS;
            else
                error('ChannelParaConfig: Wrong input of Ind_LOS.');
            end
        end
        function obj = set.Ind_LOS(obj, value)
            if isnumeric(value) && isreal(value) && any(value >= 0 ) &&...
                    any(value <= 2 )
                obj.Ind_LOS = value;
            else
                error('ChannelParaConfig: Wrong input of Ind_LOS.');
            end
        end
        
        % Indicator of uplink or downlink
        function obj = set.Ind_uplink(obj, value)
            if  all(size(value) == [1 1]) && (isnumeric(value) || ...
                    islogical(value)) && any( value == [0 1] )
                obj.Ind_uplink = value;
            else
                error('ChannelParaConfig: Wrong input of Ind_uplink.');
            end
        end
        
        % Indicator of spatical consistence
        function obj = set.Ind_spatconsis(obj, value)
            if all(size(value) == [1 1]) && (isnumeric(value) || ...
                    islogical(value)) && any( value == [0 1] )
                obj.Ind_spatconsis = value;
            else
                error('ChannelParaConfig: Wrong input of Ind_spatconsis.');
            end
        end
        
        % Indicator of absolute time of arrival.
        function obj = set.Ind_ABS_TOA(obj, value)
            if all(size(value) == [1 1]) && (isnumeric(value) || ...
                    islogical(value)) && any( value == [0 1] )
                obj.Ind_ABS_TOA = value;
            else
                error('ChannelParaConfig: Wrong input of Ind_ABS_TOA.');
            end
        end
        
        % Indicator of ground reflection.
        function obj = set.Ind_GR(obj, value)
            if all(size(value) == [1 1]) && (isnumeric(value) || ...
                    islogical(value)) && any( value == [0 1] )
                obj.Ind_GR = value;
            else
                error('ChannelParaConfig: Wrong input of Ind_GR.');
            end
        end
        
        % Indicator of outdoor to indoor.
        function out = get.Ind_O2I( obj )
            temp_Ind_O2I = obj.Ind_O2I;
            if all(size(temp_Ind_O2I) == [1 1])
                out = repmat( temp_Ind_O2I, 1,obj.nUE );
            elseif all( size(temp_Ind_O2I) == [1 obj.nUE] )
                out = temp_Ind_O2I;
            else
                error('ChannelParaConfig: Wrong input of Ind_O2I.');
            end
        end
        function obj = set.Ind_O2I(obj, value)
            if isnumeric(value) && isreal(value) && any(value >= 0 ) &&...
                    any(value <= 2 )
                obj.Ind_O2I = value;
            else
                error('ChannelParaConfig: Wrong input of Ind_O2I.');
            end
        end
        
        % Indicator of gain loss of transmission.
        function obj = set.Ind_gainloss(obj, value)
            if all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) && any( value == [0 1] )
                obj.Ind_gainloss = value;
            else
                error('ChannelParaConfig: Wrong input of Ind_gainloss.');
            end
        end
        
        % Maximum velocity of scatters
        function obj = set.v_scatter_max(obj, value)
            if all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0
                obj.v_scatter_max = value;
            else
                error('ChannelParaConfig: Wrong input of v_scatter_max.');
            end
        end
        
        % nsnap
        function obj = set.nsnap(obj, value)
            if all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0
                obj.nsnap = value;
            else
                error('ChannelParaConfig: Wrong input of nsnap.');
            end
        end
        
        % interval_snap
        function obj = set.interval_snap(obj, value)
            if all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0
                obj.interval_snap = value;
            else
                error('ChannelParaConfig: Wrong input of interval_snap.');
            end
        end
        
        % p_indoor
        function obj = set.p_indoor(obj, value)
            if all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0 &&  value <= 1
                obj.p_indoor = value;
            else
                error('ChannelParaConfig: Wrong input of p_indoor.');
            end
        end
        
        % p_lowloss
        function obj = set.p_lowloss(obj, value)
            if all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0 &&  value <= 1
                obj.p_lowloss = value;
            else
                error('ChannelParaConfig: Wrong input of p_lowloss.');
            end
        end
        % function: get channel coefficients
        function [hcoef, info] = get_channelcoeff(obj,Layout);
            % hcoef contains the simulated channel coefficients H with
            % the dimension of [nPath nRx nTx nsnap], and timedelay with the
            % dimension of [nPath 1 or nsnap]. When 'LOSonly' is considered,
            % the dimension of H will be [nRx nTx nsnap].
            % info cantains lsp and ssp parameters for a certain simulation.
            if strcmpi(obj.channeltype, 'static' )
                [hcoef, info ] = obj.channelcoeff_static( Layout, obj );
            elseif strcmpi(obj.channeltype, 'dynamic' )
                [hcoef, info ] = obj.channelcoeff_dynamic( Layout, obj );
            elseif strcmpi(obj.channeltype, 'LOSonly')
                [hcoef, info ] = obj.channelcoeff_LOSonly( Layout, obj );
            end
        end
    end
    methods (Static)
        [hcoef, info] = channelcoeff_static(Layout, obj);
        [hcoef, info] = channelcoeff_dynamic(Layout, obj);
        [hcoef, info] = channelcoeff_LOSonly(Layout, obj);
    end
end