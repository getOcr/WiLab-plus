classdef PRSConfig
    %PRSConfig Initialize configuration of PRS.
    %
    % DESCRIPTION
    %	This class controls the parameters setting of PRS according to 3GPP
    %   TS38.211 v16.4.0 clause 7.4.1.7.
    %
    %   Developer: Jia. Institution: PML. Date: 2021/08/12
    
    properties
        % PRS sequence ID number. The value must be one of {0,...,4095}.
        nPRSID = 0;
        % Slot number within a frame.
        nslot = 0;
        % Amplitude scaling factor. May be revalent to power boost. 
        % The value must be one of { 0 3 6 7.78 9 10}/2;
        beta_prs = 0;  
        % Transmission comb number. The value must be one of {2 4 6 12}.
        KTC = 12;
        % Start RE in the first OFDM symbol of each PRS resource. 
        % The value must be one of {0,...,KTC-1}.
        K_offset = 0;
        % Comb size of the downlink PRS resource in time domain. 
        % The value must be one of {2 4 6 12}.
        L_prs = 12;
        % First symbol of the PRS within a slot.
        L_start = 0;
        % Frame number.
        Nframe = 0;
        % Period set (1) period in slots (2) offset in slots. The value of
        % Periodset(1) must be one of 2^mu *{4 5 8 10 16 20 32 40 64 80 160
        % 320 640 1280 2560 5120 10240}. The value of Periodset(2) must be
        % one of {0,...,Periodset(1)-1}.
        Periodset = [8 0];
        % Slot offset of each PRS resource relative to PRS resource set
        % slot offset.
        T_offset_res = 0;
        % Repetition factor. The value must be one of {1 2 4 6 8 16 32}.
        T_rep = 1;
        % Muting bit repetition factor.
        T_muting = 1;       
        % PRB Number.
        NumRB = 25;       
        % Muting bitmap1
        bitmap1 = [];     
        % Muting Bitmap2
        bitmap2 = [];
        % Time gap. Slot offset between two consecutive repeated instances
        % of a PRS resource. The value must be one of { 1 2 4 6 8 16 32}.
        T_gap = 2;
        % Length of bitmap.
        L; % The value must be one of { 2 4 6 8 16 32 }.
    end
    properties (Constant, Hidden)
        k_prime_table = [0 1 0 1 0 1 0 1 0 1 0 1; 0 2 1 3 0 2 1 3 0 2 1 3; ...
            0 3 1 4 2 5 0 3 1 4 2 5; 0 6 3 9 1 7 4 10 2 8 5 11];
        period_table = 2^1 * [4 5 8 10 16 20 32 40 64 80 160 320 640 1280 ...
            2560 5120 10240]; 
    end
    
    methods

        % set functions
        function obj = set.nPRSID(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  any(value == (0:4095) )  )
                error('PRSconfig:nPRSID. The value must be one of {0,...,4095}.');
            end
            obj.nPRSID = value;
        end
        
        function obj = set.nslot(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0  )
                error('PRSconfig:nslot. The value must be  >= 0.');
            end
            obj.nslot = value;
        end
        
        function obj = set.beta_prs(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  any(value == [0 3 6 7.78 9 10]/2 )  )
                error(['PRSconfig:beta_prs. The value must be one of ',...
                    '{ 0 3 6 7.78 9 10}/2.']);
            end
            obj.beta_prs = value;
        end
        
        function obj = set.KTC(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  any(value == [2 4 6 12] )  )
                error('PRSconfig:KTC. The value must be one of { 2 4 6 12}.');
            end
            obj.KTC = value;
        end
        
        function obj = set.K_offset(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0  )
                error('PRSconfig:K_offset. The value must be  >= 0.');
            end
            obj.K_offset = value;
        end
        
        function obj = set.L_prs(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  any(value == [2 4 6 12] )  )
                error('PRSconfig:L_prs. The value must be one of { 2 4 6 12}.');
            end
            obj.L_prs = value;
        end
        
        function obj = set.L_start(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0  )
                error('PRSconfig:L_start. The value must be  >= 0.');
            end
            obj.L_start = value;
        end
        
        function obj = set.Nframe(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0  )
                error('PRSconfig:Nframe. The value must be  >= 0.');
            end
            obj.Nframe = value;
        end
        
        function obj = set.Periodset(obj, value)
            if all(size(value) == [1 2]) && isnumeric(value) && ...
                    isreal(value) && ( value(1) > value(2) ) && ...
                    any( value(1) == obj.period_table )
                obj.Periodset = value;
            else
                error('PRSconfig: Wrong input of Periodset.');
            end
        end
        
        function obj =set.T_offset_res(obj, value)
            if ~( all(size(value) == [1 1]) && isnumeric( value ) && ...
                    isreal( value ) &&  value >= 0  )
                error('PRSconfig:T_offset_res. The value must be  >= 0.');
            end
            obj.T_offset_res = value;
        end
        
        function obj = set.T_rep(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric( value ) && ...
                    isreal( value ) &&  any(value == [1 2 4 6 8 16 32] )  )
                error(['PRSconfig:T_rep. The value must be one of {1 2 4 6',...
                    ' 8 16 32}.']);
            end
            obj.T_rep = value;
        end
        
        function obj =set.T_muting(obj, value)
            if ~( all(size(value) == [1 1]) && isnumeric( value ) && ...
                    isreal( value ) &&  value >= 1  )
                error('PRSconfig:T_muting. The value must be  >= 1.');
            end
            obj.T_muting = value;
        end
        
        function obj =set.NumRB(obj, value)
            if ~( all(size(value) == [1 1]) && isnumeric( value ) && ...
                    isreal( value ) &&  value >= 1  )
                error('PRSconfig: NumRB. The value must be >= 1.');
            end
            obj.NumRB = value;
        end
                
        function obj = set.bitmap1(obj,value)
            if ~any( length(value) == [ 2 4 6 8 16 32] )
                error(['PRSconfig: bitmap1. The length of bitmap1 must be ',...
                    'one of {2 4 6 8 16 32}.']);
            elseif any( ( value ~= 0 & value ~= 1) ~=0 )
                error(['PRSconfig: bitmap1. The element of bitmap1 must be',...
                    ' 0 or 1.']);
            else
                obj.bitmap1 = value;
            end
        end
        
        function obj = set.bitmap2(obj,value)
            if ~any(length(value) == [1 2 4 6 8 16 32])
                error( ['PRSconfig: bitmap2. The length of bitmap1 must be ',...
                    'one of {1 2 4 6 8 16 32}.'] );
            elseif any( ( value ~=0 & value ~= 1 ) ~=0 ) 
                error( ['PRSconfig: bitmap2. The element of bitmap1 must be',...
                    ' 0 or 1.'] );
            else
                obj.bitmap2 = value;
            end
        end
               
        function obj = set.T_gap(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric( value ) && ...
                    isreal( value ) &&  any(value == [1 2 4 6 8 16 32] )  )
                error(['PRSconfig:T_gap. The value must be one of {1 2 4 6',...
                    ' 8 16 32}.']);
            end
            obj.T_gap = value;
        end
        
        % get functions
        function out = get.L( obj )
            out = length( obj.bitmap1 );
        end
        
        function out = get.T_gap( obj )
            out = length( obj.bitmap2 );
        end
        
        function out = get.L_prs( obj )
            if obj.KTC <= obj.L_prs
                out = obj.L_prs;
            else
                error('PRSconfig: L_prs: obj.KTC <= obj.L_prs');
            end
        end
    end
end