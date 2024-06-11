classdef SRSConfig
    %SRSconfig Initialize configuration of SRS.
    %
    % DESCRIPTION
    %	This class controls the parameters of SRS resource sets according
    %   to 3GPP TS 38.211 v16.4.0 clause 6.4.1.4.
    %
    %   Developer: Jia. Institution: PML. Date: 2021/08/01
    
    properties
        % Number of antenna ports. The value must be one of {1, 2, 4}.
        N_ap = 4;
        % Number of consecutive symbols. The value must be one of
        % {1,2,4,8,12}.
        N_symb = 1;
        % The start time-position. The value must be one of {0,1,...,13}.
        L_0 = 13;
        % The start frequency-position. The value must be within bandwidth.
        K_0 = 0;
        % Transmission comb number. The value must be one of {2,4,8}.
        KTC = 2;
        % Number of cyclic shifts. The value must be one of (0 : 
        % N_cycshf_max).
        N_cycshf = 0;
        % Column index of the bandwidth configuration in the table 
        % 6.4.1.4.3-1 from 3GPP TS 38.211 v16.4.0. The value must be one of
        % {0,1,2,3}.
        B_SRS = 0;
        % Row index of the bandwidth configuration in the table 6.4.1.4.3-1 
        % form 3GPP TS 38.211 v16.4.0. The value must be one of (0 : 63).
        C_SRS = 25; %61
        % Hopping type of SRS symbols. The value must be one of {'neither',
        % 'groupHopping', 'sequenceHopping'}.
        groupOrSeqHopping = 'neither';
        %SRS scrambling identity. The value must be one of (0:65535).
        NSRSID = 0;
        % Slot number within a frame.
        nslot = 0;
        % Frame number.
        Nframe = 0;
        % Amplitude scaling factor. The value must be
        % one of {0 3 4.77 6 7 7.78}/2 dB
        beta_srs = 0/2;
        % Resource set type. The value must be one of { 'aperiodic','periodic'};
        ResType = 'periodic';
        % Period set. (1) period in slots (2) offset in slots
        Periodset = [3 0];
        % Frequency hopping para. The value must be one of {0 1 2 3}.
        b_hop = 0;
        % Frequency shift.
        n_shift = 0;
        % comb offset. The value must be one of {0,...,KTC-1}.
        KTC_offset = 0;
        % Additional circular frequency-domain offset.
        n_RRC = 0;
        % Indicator of enabling the Transmit comb offset. 
        % 1 means that K_offser would be generated according to TS 38.211-
        % table 6.4.1.4.3-2. 0 means default value,i.e., K_offset = 0.
        K_offset_enble = 1;
        % Repetition factor of OFDM symbols.
        R_rf;
    end
    properties (SetAccess = private)
        % Max number of the cyclic shifts.
        N_cycshf_max;
        % Length of the SRS symbol sequence.  % number of subcarriers used.
        M_sc_b;
        % Bandwidth in RB.
        m_srs_b;
        % Parameter N_b in table 6.4.1.4.3-1 SRS bandwidth configuration.
        N_b;
        % Transmit comb offset in subcarriers.
        K_offset;
    end
    
    properties (Constant, Hidden)
        Range_N_ap = [1 , 2, 4];
        Range_symb = [1, 2, 4, 8, 12];
        Range_L_0 = (0 : 13);
        Range_KTC = [2, 4, 8];
        Range_B_SRS = (0 : 3);
        Range_C_SRS = (0 : 63);
        
        % table_m_srs(B_SRS,C_SRS)
        table_m_srs = [4 8 12 16 16 20 24 24 28 32 36 40 48 48 52 56 60 64 ...
            72 72 76 80 88 96 96 104 112 120 120 120 128 128 128 132 136 144 ...
            144 144 144 152 160 160 160 168 176 184 192 192 192 192 208 216 ...
            224 240 240 240 240 256 256 256 264 272 272 272; ...
            4 4 4 4 8 4 4 12 4 16 12 20 16 24 4 28 20 32  24 36 4 40 44 32 ...
            48 52 56 60 40 24 64 64 16 44 68 72 48 48 16 76 80 80 32 84 88 ...
            92 96 96 64 24 104 108 112 120 80 48 24 128 128 16 132 136 68 16;...
            4 4 4 4 4 4 4 4 4 8 4 4 8 12 4 4 4 16 12 12 4 20 4 16 24 4 28 ...
            20 8 12 32 16 8 4 4 36 24 16 8 4 40 20 16 28 44 4 48 24 16 8 ...
            52 36 56 60 20 16 12 64 32 8 44 68 4 8;...
            4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 ...
            4 4 4 4 4 12 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 8 4 4 4 4 4 4 4 4];
        table_N_b = [ones(1,64);1 2 3 4 2 5 6 2 7 2 3 2 3 2 13 2 3 2 3 2 19 ...
            2 2 3 2 2 2 2 3 5 2 2 8 3 2 2 3 3 9 2 2 2 5 2 2 2 2 2 3 8 2 2 2 2 ...
            3 5 10 2 2 16 2 2 4 17; 1 1 1 1 2 1 1 3 1 2 3 5 2 2 1 7 5 2 2 ...
            3 1 2 11 2 2 13 2 3 5 2 2 4 2 11 17 2 2 3 2 19 2 4 2 3 2 23 2 ...
            4 4 3 2 3 2 2 4 3 2 2 4 2 3 2 17 2; ones(1,9) 2 1 1 2 3 1 1 1 ...
            4 3 3 1 5 1 4 6 1 7 5 2 3 8 4 2 1 1 9 2 4 2 1 10 5 4 7 11 1 ...
            12 6 4 2 13 9 14 15 5 2 3 16 8 2 11 17 1 2];
        
    end
    
    methods
        %set functions
        function obj = set.N_ap(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  any(value == [1 2 4])  )
                error('SRSconfig: N_ap. The value must be one of {1 2 4}.');
            end
            obj.N_ap = value;
        end
        
        function obj = set.N_symb(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) && any(value == [1 2 4 8 12])  )
                error('SRSconfig:N_symb. The value must be one of {1 2 4 8 12}.');
            end
            obj.N_symb = value;
        end
        
        function obj = set.L_0(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  any(value == (0:13) )  )
                error('SRSconfig:L_0. The value must be one of {0,...13}.');
            end
            obj.L_0 = value;
        end
        
        function obj = set.K_0(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0  )
                error('SRSconfig:K_0. The value must be >= 0.');
            end
            obj.K_0 = value;
        end
        
        function obj = set.KTC(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  any(value == [2 4 8] )  )
                error('SRSconfig:KTC. The value must be one of {2 4 8}.');
            end
            obj.KTC = value;
        end
        
        function obj = set.N_cycshf(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0  )
                error('SRSconfig:N_cycshf. The value must be >= 0.');
            end
            obj.N_cycshf = value;
        end
        
        function obj = set.B_SRS(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  any(value == [0 1 2 3] )  )
                error('SRSconfig:B_SRS. The value must be one of {0 1 2 3}.');
            end
            obj.B_SRS = value;
        end
        
        function obj = set.C_SRS(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  any(value == (0:63) )  )
                error('SRSconfig:C_SRS. The value must be one of {0,...,63}.');
            end
            obj.C_SRS = value;
        end
        
        function obj = set.groupOrSeqHopping(obj,value)
            if ~( strcmp(value, 'neither')|| ...
                    strcmp(value, 'groupHopping') || ...
                    strcmp(value, 'sequenceHopping'))
                error('SRSconfig: wrong input of groupOrSeqHopping.');
            end
            obj.groupOrSeqHopping = value;
        end
        
        function obj = set.NSRSID(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  any(value == (0:65535) )  )
                error('SRSconfig:NSRSID. The value must be one of {0,...,65535}.');
            end
            obj.NSRSID = value;
        end
        
        function obj = set.nslot(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) && value >= 0 )
                error('SRSconfig:nslot. The value must be  >= 0.');
            end
            obj.nslot = value;
        end
        
        function obj = set.Nframe(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) && value >= 0 )
                error('SRSconfig:Nframe. The value must be  >= 0.');
            end
            obj.Nframe = value;
        end
        
        function obj = set.beta_srs(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  any(value == [0 3 4.77 6 7 7.78] /2 )  )
                error('SRSconfig:beta_srs. The value must be one of {0 3 4.77 6 7 7.78}/2.');
            end
            obj.beta_srs = value;
        end
        
        function obj = set.ResType(obj,value)
            if ~( strcmp(value, 'periodic')|| strcmp(value, 'aperiodic') )
                error('SRSconfig: Wrong input of ResType.');
            end
            obj.ResType = value;
        end
        
        function obj = set.b_hop(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  any(value == [0 1 2 3] )  )
                error('SRSconfig:b_hop. The value must be one of {0 1 2 3}.');
            end
            obj.b_hop = value;
        end
        
        function obj = set.n_shift(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0   )
                error('SRSconfig:n_shift. The value must be >= 0.');
            end
            obj.n_shift = value;
        end
        
        function obj = set.KTC_offset(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0   )
                error('SRSconfig:KTC_offset. The value must be >= 0.');
            end
            obj.KTC_offset = value;
        end
        
        function obj = set.n_RRC(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0   )
                error('SRSconfig:n_RRC. The value must be >= 0.');
            end
            obj.n_RRC = value;
        end
        
        function obj = set.K_offset_enble( obj, value)
            if ~( all(size( value ) == [1 1]) && isnumeric( value ) && ...
                    isreal( value )                                                                                                                  &&  any(value == [0 1 ])   )
                error('SRSconfig:K_offset_enble. The value must be 0 or 1.');
            end
            obj.K_offset_enble = logical( value );
        end
        
        function obj = set.R_rf(obj, val)
            obj.R_rf = val;
        end
        
        %get functions
        function out = get.R_rf( obj )
            if isempty( obj.R_rf )
                out = obj.N_symb;
            elseif obj.R_rf <= obj.N_symb
                out = obj.R_rf;
            else
                error('WrongInput: SRSconfig: R_rf must <= N_symb !');
            end
        end
        
        function out = get.N_cycshf_max(obj)
            switch obj.KTC
                case 2
                    out = 8;
                case 4
                    out = 12;
                case 8
                    out = 6;
            end
        end
        
        function out = get.M_sc_b(obj)
            out = obj.m_srs_b * 12 / obj.KTC;
        end
        
        function out = get.m_srs_b(obj)
            out = obj.table_m_srs((1:obj.B_SRS+1), obj.C_SRS+1);
        end
        
        function out = get.N_b(obj)
            out = obj.table_N_b((1:obj.B_SRS+1), obj.C_SRS+1);
        end
        
        function out = get.K_offset(obj)
            if obj.K_offset_enble == 1
                if obj.KTC == 2
                    switch obj.N_symb
                        case 1
                            out = 0;
                        case 2
                            out = [0,1];
                        case 4
                            out = [0 1 0 1];
                        otherwise
                            error('WrongInput: N_symb ');
                    end
                elseif obj.KTC == 4
                    switch obj.N_symb
                        case 2
                            out = [0 2];
                        case 4
                            out = [0 2 1 3];
                        case 8
                            out = [0 2 1 3 0 2 1 3];
                        case 12
                            out = [0 2 1 3 0 2 1 3 0 2 1 3];
                        otherwise
                            error('WrongInput: N_symb ');
                    end
                elseif obj.KTC ==8
                    switch obj.N_symb
                        case 4
                            out = [0 4 2 6];
                        case 8
                            out = [0 4 2 6 1 5 3 7];
                        case 12
                            out = [0 4 2 6 1 5 3 7 0 4 2 6 ];
                        otherwise
                            error('WrongInput: N_symb ');
                    end
                end
            else
                out = zeros(1,obj.N_symb);
            end
        end
    end
end