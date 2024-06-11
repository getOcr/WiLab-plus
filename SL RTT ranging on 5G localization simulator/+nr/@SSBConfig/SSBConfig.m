classdef SSBConfig
    %SSBConfig Initialize configuration of synchronization signal blocks.
    %
    % DESCRIPTION
    %	This class controls the parameters setting of synchronization 
    %   signal blocks according to 3GPP TS 38.211 v16.4.0 clause 7.4.2 -
    %   7.4.3. and TS 38.213 v16.5.0 clause 4.
    %   Note that the cases of shared spectrum channel access and unpaired
    %   spectrum operation are not considered.
    %
    %   Developer: Jia. Institution: PML. Date: 2021/08/13
    
    properties
        % Cell ID 1 and 2. The value of N_ID1 must be one of {0,...,335}.
        % The value of N_ID2 must be one of {0,1,2}.
        N_ID1 = 0;
        N_ID2 = 0;
        % Common resource block offset to point A.
        N_CRB_ssb =0; % scs=15KHz for mu=1,2 or scs=60KHz for mu=3,4
        % SS Burst set periodicity in ms. {5 10 20 40 80 160} (default 5)
        SSBPeriodicity = 5;
        % Half-frame number.
        NHFframe = 0;
        % Subcarrier offset.
        k_ssb = 0;   %K_ssb_bar is not considered.
        % Case for time domain determination. The value must be one of 
        % { 'Case A', 'Case B', 'Case C', 'Case D', 'Case E'}.
        CaseSel = 'Case C';
        % Information for PBCH.
        PBCHbits = zeros(864,1);
        % Amplitude scaling factors.
        beta_pss = 0;
        beta_sss = 0;
        beta_pbch = 0;
        beta_dmrs = 0;
         % Total frame number.
        nframe_tot;
    end
    
    properties (Dependent)
        % Unique physical-layer cell identities. N = 1008.
        N_cellID;
        % Maximum number of SSB in a half frame.
        Lmax_bar  % get function
        % mu. e.g., scs = 2^mu*15. The value must be one of { 0 1 3 4}.
        mu;  
        % Time-domain index of ssb.
        Ind_tim_ssb;
        % SSB symbols position
        SSBSymPos;
        % SSB subcarrier position.
        SSBSCPos;
    end
    properties (Hidden)
        center_frequency;
        SubcarrierSpacing;
        NRB;        
        i_ssb_bar =0;
        i_ssb =0;
        n_hf =0;
    end
    
    methods
        % Constructor
        function obj = SSBConfig( sysPar, carrier )
            if exist('sysPar', 'var') && ~isempty( sysPar ) && ...
                    exist('carrier', 'var') && ~isempty( carrier )
                obj.center_frequency = sysPar.center_frequency;
                obj.SubcarrierSpacing = carrier.SubcarrierSpacing;
                obj.NRB = carrier.NSizeGrid;
            else
                error('SSBConfig:WrongInput of constructor!');
            end
        end
                
        % set functions
        function obj = set.N_ID1(obj, value)
            if ~( all( size( value ) == [1 1] ) && isnumeric(value) && ...
                    isreal(value) &&  any(value == (0:335) ) )
                error('SSBConfig:N_ID1. The value must be one of {0,...,335}.');
            end
            obj.N_ID1 = (value);
        end
        
        function obj = set.N_ID2(obj, value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  any(value == [0 1 2] ) )
                error('SSBConfig:N_ID2. The value must be one of {0 1 2}.');
            end
            obj.N_ID2 = (value);
        end
        
        function obj = set.N_CRB_ssb(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0 )
                error('SSBConfig:N_CRB_ssb. The value must be >= 0.');
            end
            obj.N_CRB_ssb = (value);
        end
        
        function obj = set.SSBPeriodicity(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  any(value == [5 10 20 40 80 160] ) )
                error(['SSBConfig:SSBPeriodicity. The value must be one of',...
                    ' {5 10 20 40 80 160}.']);
            end
            obj.SSBPeriodicity = (value);
        end
        
        function obj = set.NHFframe(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0 )
                error('SSBConfig:NHFframe. The value must be >= 0.');
            end
            obj.NHFframe = (value);
        end
        
        function obj = set.k_ssb(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0 )
                error('SSBConfig:k_ssb. The value must be >= 0.');
            end
            obj.k_ssb = (value);
        end
        
        function obj = set.nframe_tot(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0 )
                error('SSBConfig:nframe_tot. The value must be >= 0.');
            end
            obj.nframe_tot = (value);
        end
        
        function obj = set.CaseSel(obj,value)
            if ~(strcmpi(value,'Case A') ||strcmpi(value,'Case B') || ...
                    strcmpi(value,'Case C')  || strcmpi(value,'Case D') || ...
                    strcmpi(value,'Case E')  )
                error(['SSBConfig:CaseSel. The value must be one of ',...
                    '{''Case A'', ''Case B'', ''Case C'', ''Case D'', ''Case E''}.']);
            else
                obj.CaseSel = value;
            end
        end
        
         % get functions
        function out = get.N_cellID(obj)
            out = obj.N_ID1 + obj.N_ID2;
        end
        
        function out = get.mu(obj)
            if obj.SubcarrierSpacing == 60
                error('SSBConfig:SubcarrierSpacing = 60 is not supported. ');
            else
                out = log2(obj.SubcarrierSpacing/15);
            end
        end
        
        function out = get.Lmax_bar(obj)
            if obj.center_frequency <= 3e9
                out = 4;
            elseif obj.center_frequency <= 6e9
                out = 8;
            else
                out = 64;
            end
        end
        
        function out = get.Ind_tim_ssb(obj)
            switch obj.CaseSel
                case 'Case A'
                    if obj.mu == 0
                        if obj.Lmax_bar == 4
                            out = [2 8 16 22];
                        elseif obj.Lmax_bar == 8
                            out = [2 8 16 22 30 36 44 50];
                        else
                            error('Case A is with fs <= 6e9. ');
                        end
                    else
                        error('Case A is with SCS = 15 KHz.');
                    end
                case 'Case B'
                    if obj.mu == 1
                        if obj.Lmax_bar == 4
                            out = [4 8 16 20];
                        elseif obj.Lmax_bar == 8
                            out = [4 8 16 20 32 36 44 48];
                        else
                            error('Case B is with fs <= 6e9. ');
                        end
                    else
                        error('Case B is with SCS = 30 KHz.');
                    end
                case 'Case C'
                    if obj.mu == 1
                        if obj.Lmax_bar == 4
                            out = [4 8 16 20];
                        elseif obj.Lmax_bar == 8
                            out = [4 8 16 20 32 36 44 48];
                        else
                            error('Case C is with fs <= 6e9. ');
                        end
                    else
                        error('Case C is with SCS = 30 KHz.');
                    end
                case 'Case D'
                    if obj.mu == 3
                        if obj.Lmax_bar == 64
                            temp = [4 8 16 20].' + [ 28 *(0:3),28 *(5:8),...
                                28 *(10:13), 28 *(15:18)];
                            out = temp(:).';
                        else
                            error('Case D is with fs > 6e9. ');
                        end
                    else
                        error('Case D is with SCS = 120 KHz.');
                    end
                case 'Case E'
                    if obj.mu == 4
                        if obj.Lmax_bar == 64
                            temp = [8 12 16 20 32 36 40 44].' +...
                                [ 56 *(0:3),56 *(5:8) ];
                            out = temp(:).';
                        else
                            error('Case E is with fs > 6e9. ');
                        end
                    else
                        error('Case E is with SCS = 240 KHz.');
                    end
            end
        end
        
        function out = get.k_ssb(obj)
            if any(obj.mu == [0 1] )
                if ~any(obj.k_ssb == (0:23) )
                    error('SSBConfig:k_ssb. The value must be one of {0,...,23}');
                else
                    out = obj.k_ssb;
                end
            elseif any(obj.mu == [3 4])
                if ~any(obj.k_ssb == (0:23) )
                    error('SSBConfig:k_ssb. The value must be one of {0,...,11}');
                else
                    out = obj.k_ssb;
                end
            end
            
        end
        
        function out = get.SSBSymPos(obj)
           out = ((obj.Ind_tim_ssb+1) + [1;2;3;4]).'; 
        end
        
        function out = get.SSBSCPos(obj)
           if any(obj.mu == [0 1] )
               out = obj.k_ssb + obj.N_CRB_ssb * 12 / 2^(obj.mu) + (1:240);
           elseif any(obj.mu == [3 4] )
               out = obj.k_ssb + obj.N_CRB_ssb * 12 / 2^(obj.mu-2) + (1:240);
           end
        end
    end

end