classdef CSIRSConfig
    %CSIRSConfig Initialize configuration of CSIRS.
    %
    % DESCRIPTION
    %	This class controls the parameters setting of CSIRS according to
    %   3GPP TS38.211 v16.4.0 clause 7.4.1.5.
    %
    %   Developer: Jia. Institution: PML. Date: 2021/08/10
    
    properties
        % Resource type of CSIRS.
        % The value must be one of {'ZeroPower', 'NonZeroPower'};
        ResType = 'NonZeroPower';
        % Slot number within a frame.
        nslot = 0;
        % Scrambling identity. The value must be one of ( 0 : 65535 ).
        n_ID = 0;
        % Row number corresponding to a CSIRS resource as in table
        % 7.4.1.5.3-1.
        Row = 5;
        % CSIRS resource frequency density. The value must be one of
        % {0.5 1 3}.
        density = 1;
        % Amplitude scaling factor.
        beta_csirs = 0/2;
        % Time domain start positions of a CSIRS resource.
        % The value of L0(1) and L0(2 )must be one of {0,...,13} and
        % {2,...,12}, respectively.
        L0 = [0 2];
        % Frequency start positions of a CSIRS resource.
        K0 = 0;
        % The Frame number.
        Nframe = 0;
        % % Period set: (1) and (2) present the period and the offset of a
        % CSIRS resource.
        Periodset = [4 0];
        % Number of RBs.
        NumRB = 25;
        
    end
    
    properties (Dependent, SetAccess = private)
        % auxiliary arguments.
        cdm_type;
        wf;
        wt;
        % Number of ports
        Nports;
        % Frequency start position.
        K0_row;
        K_prime;
        L_prime;
        K_bar;
        L_bar;
        j_gpind;
    end
    
    properties (Constant, Hidden)
        ports_table = [1 1 2 4 4 8 8 8 12 12 16 16 24 24 24 32 32 32];
    end
    
    methods
        % set functions
        function obj = set.ResType(obj, value)
            if ~(strcmpi(value,'NonZeroPower') || strcmpi(value,'ZeroPower'))
                error('CSIRSconfig: ResType: ');
            else
                obj.ResType = value;
            end
        end
        
        function obj = set.nslot(obj, value)
            if ~( all( size(value) == [1 1]) && isnumeric( value ) && ...
                    isreal( value ) &&  value >= 0   )
                error('CSIRSconfig: nslot: the value must be >= 1');
            else
                obj.nslot = value;
            end
        end
        
        function obj = set.n_ID(obj,value)
            if ~( all( size(value) == [1 1]) && isnumeric( value ) && ...
                    isreal( value ) && any(value == (0:65535) ) )
                error('CSIRSconfig: n_ID: the value must be one of {0,...,65535}');
            else
                obj.n_ID = value;
            end
        end
        
        function obj = set.Row(obj,value)
            if ~( all( size(value) == [1 1]) && isnumeric( value ) && ...
                    isreal( value ) && any(value == (1:18) ) )
                error('CSIRSconfig: Row: the value must be one of {1,...,18}');
            else
                obj.Row = value;
            end
        end
        
        function obj = set.density(obj,value)
            if ~( all( size(value) == [1 1]) && isnumeric( value ) && ...
                    isreal( value ) && any(value == [0.5 1 3]) )
                error('CSIRSconfig: density: the value must be one of {3 1 0.5}');
            else
                obj.density = value;
            end
        end
        
        function obj = set.beta_csirs(obj,value)
            if ~( all( size(value) == [1 1]) && isnumeric( value ) && ...
                    isreal( value ) && any(value == [3 6 7.78 9 10 10.79]/2) )
                error(['CSIRSconfig: beta_csirs: the value must be one of',...
                    ' {3 6 7.78 9 10 10.79}/2']);
            else
                obj.beta_csirs = value;
            end
        end
        
        function obj = set.L0(obj, value)
            if ~( all( size( value ) == [1 1]) && isnumeric( value ) && ...
                    isreal( value ) ) && (~any( value(1) == (0:13)) || ...
                    ~any(value(2) == (2:12) ) )
                error('CSIRSconfig: Wrong input of L0.');
            else
                obj.L0 = value;
            end
        end
        
        function obj = set.K0(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric( value ) && ...
                    isreal( value ) &&  value >= 0   )
                error('CSIRSconfig: K0: the value must be >= 1');
            else
                obj.K0 = value;
            end
        end
        
        function obj = set.Nframe(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric( value ) && ...
                    isreal( value ) &&  value >= 0   )
                error('CSIRSconfig: Nframe: the value must be >= 1');
            else
                obj.Nframe = value;
            end
        end
        
        
        
        function obj = set.NumRB(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric( value ) && ...
                    isreal( value ) &&  value >= 0   )
                error('CSIRSconfig: NumRB: the value must be >= 1');
            else
                obj.NumRB = value;
            end
        end
        
        % get functions
        function out = get.Periodset(obj)
            if obj.Periodset(1) > obj.Periodset(2) && any( obj.Periodset(1) ...
                    == [4 5 8 10 16 20 32 40 64 80 160 320 640] )
                out = obj.Periodset;
            else
                error('CSIRSconfig: Periodset: WrongInput ');
            end
        end
        
        function out = get.density(obj)
            if any(obj.Row == 1)
                if ~any(obj.density == 3)
                    error('CSIRSConfig: density must be 3 with Row = 1.');
                end
            elseif any(obj.Row ==[2 3 11 12 13 14 15 16 17 18] )
                if ~any(obj.density == [1 0.5])
                    error('CSIRSConfig: density must be 1 or 0.5 with current Row.');
                end
            elseif any(obj.Row ==[4 5 6 7 8 9 10] )
                if ~(obj.density == 1 )
                    error('CSIRSConfig: density must be 1 with current Row.');
                end
            end
            out = obj.density;
        end
        
        function out = get.wf(obj)
            switch obj.cdm_type
                case 'noCDM'
                    out = 1;
                case 'fd-CDM2'
                    out = [1 1;1 -1];
                case 'cdm4-FD2-TD2'
                    out = [1 1;1 -1;1 1;1 -1];
                case 'cdm8-FD2-TD4'
                    out = [1 1;1 -1; 1 1;1 -1;1 1;1 -1;1 1;1 -1];
            end
        end
        
        function out = get.wt(obj)
            switch obj.cdm_type
                case 'noCDM'
                    out = 1;
                case 'fd-CDM2'
                    out = [1 ;1];
                case 'cdm4-FD2-TD2'
                    out = [1 1;1 1;1 -1;1 -1];
                case 'cdm8-FD2-TD4'
                    out = [1 1 1 1;1 1 1 1; 1 -1 1 -1;1 -1 1 -1;1 1 -1 -1;...
                        1 1 -1 -1;1 -1 -1 1; 1 -1 -1 1];
            end
        end
        
        function out = get.cdm_type(obj)
            if any(obj.Row == [1 2])
                out = 'noCDM';
            elseif any(obj.Row == [3 4 5 6 7 9 11 13 16])
                out = 'fd-CDM2';
            elseif any(obj.Row == [8 10 12 14 17])
                out = 'cdm4-FD2-TD2';
            elseif any(obj.Row == [15 18])
                out = 'cdm8-FD2-TD4';
            end
        end
        
        function out = get.Nports(obj)
            out = obj.ports_table(obj.Row);
        end
        % Constant setting for k0 k1 k2.... Not according to bitmap
        function out = get.K0_row(obj)
            if  obj.Row == 1
                if obj.K0 <= 3
                    out = obj.K0;
                else
                    error('Current K0 is not supported. ');
                end
            elseif obj.Row == 2
                if obj.K0 <= 11
                    out = obj.K0;
                else
                    error('Current K0 is not supported. ');
                end
            elseif obj.Row == 4
                if any(obj.K0 == [0 4 8])
                    out = obj.K0 *4;
                else
                    error('Current K0 is not supported. ');
                end
            else
                if obj.K0 <= 1
                    out = [0 2 4 6 8 10] + obj.K0;
                else
                    error('Current K0 is not supported. ');
                end
            end
        end
        
        function out = get.L_bar(obj)
            switch obj.Row
                case 1
                    out = [obj.L0(1) obj.L0(1) obj.L0(1)];
                case 2
                    out = obj.L0(1);
                case 3
                    out = obj.L0(1);
                case 4
                    out = [obj.L0(1) obj.L0(1)];
                case 5
                    out = [obj.L0(1) (obj.L0(1)+1)];
                case 6
                    out = [obj.L0(1) obj.L0(1) obj.L0(1) obj.L0(1)];
                case 7
                    out = [obj.L0(1) obj.L0(1) (obj.L0(1)+1) (obj.L0(1)+1)];
                case 8
                    out = [obj.L0(1) obj.L0(1)];
                case 9
                    out = obj.L0(1) * ones(1,6);
                case 10
                    out = obj.L0(1) * ones(1,3);
                case 11
                    out = [obj.L0(1) * ones(1,4) (obj.L0(1)+1) * ones(1,4)];
                case 12
                    out = obj.L0(1) * ones(1,4);
                case 13
                    out = [obj.L0(1) * ones(1,3) (obj.L0(1)+1) * ones(1,3) ...
                        obj.L0(2) * ones(1,3) (obj.L0(2)+1) * ones(1,3)];
                case 14
                    out = [obj.L0(1) * ones(1,3) obj.L0(2) * ones(1,3)];
                case 15
                    out = obj.L0(1) * ones(1,3);
                case 16
                    out = [obj.L0(1) * ones(1,4) (obj.L0(1)+1) * ones(1,4) ...
                        obj.L0(2) * ones(1,4) (obj.L0(2)+1) * ones(1,4)];
                case 17
                    out = [obj.L0(1) * ones(1,4) obj.L0(2) * ones(1,4)];
                case 18
                    out = obj.L0(1) * ones(1,4);
            end
        end
        
        function out = get.K_bar(obj)
            switch obj.Row
                case 1
                    out = [obj.K0_row(1) (obj.K0_row(1)+4) (obj.K0_row(1)+8)];
                case 2
                    out = obj.K0_row(1);
                case 3
                    out = obj.K0_row(1);
                case 4
                    out = [obj.K0_row(1) (obj.K0_row(1)+2)];
                case 5
                    out = [obj.K0_row(1) obj.K0_row(1)];
                case 6
                    out = obj.K0_row(1:4);
                case 7
                    out = [obj.K0_row(1) obj.K0_row(2) obj.K0_row(1) obj.K0_row(2)];
                case 8
                    out = [obj.K0_row(1) obj.K0_row(2)];
                case 9
                    out = obj.K0_row(1:6);
                case 10
                    out = obj.K0_row(1:3);
                case 11
                    out = [obj.K0_row(1:4) obj.K0_row(1:4)];
                case 12
                    out = obj.K0_row(1:4);
                case 13
                    out = [obj.K0_row(1:3) obj.K0_row(1:3) obj.K0_row(1:3) ...
                        obj.K0_row(1:3)];
                case 14
                    out = [obj.K0_row(1:3) obj.K0_row(1:3)];
                case 15
                    out = obj.K0_row(1:3);
                case 16
                    out = [obj.K0_row(1:4) obj.K0_row(1:4) obj.K0_row(1:4) ...
                        obj.K0_row(1:4)];
                case 17
                    out = [obj.K0_row(1:4) obj.K0_row(1:4)];
                case 18
                    out = obj.K0_row(1:4);
            end
        end
        
        function out = get.j_gpind(obj)
            switch obj.Row
                case 1
                    out = [0 0 0];
                case 2
                    out = 0;
                case 3
                    out = 0;
                case 4
                    out = [0 1];
                case 5
                    out = [0 1];
                case 6
                    out = [ 0 1 2 3];
                case 7
                    out = [ 0 1 2 3];
                case 8
                    out = [ 0 1];
                case 9
                    out = (0: 5);
                case 10
                    out = [0 1 2];
                case 11
                    out = (0: 7);
                case 12
                    out = (0: 3);
                case 13
                    out = (0:11);
                case 14
                    out = (0:5);
                case 15
                    out = [0 1 2];
                case 16
                    out = (0:15);
                case 17
                    out = (0:7);
                case 18
                    out = (0:3);
            end
        end
        
        function out = get.K_prime(obj)
            if any( obj.Row == [1 2])
                out = 0;
            elseif any(obj.Row == (3:18) )
                out = [0 1];
            end
        end
        
        function out = get.L_prime(obj)
            if any( obj.Row == [1 2 3 4 5 6 7 9 11 13 16])
                out = 0;
            elseif any( obj.Row == [8 10 12 14 17])
                out = [0 1 ];
            elseif any( obj.Row == [15 18])
                out = [0 1 2 3];
            end
        end
 
    end
end