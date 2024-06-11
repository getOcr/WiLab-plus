classdef RFImpairConfig  < handle
    %RFImpairConfig Initilize the parameters for RF impairment functions.
    %
    % DESCRIPTION
    %   This class controls the parameters of RF impairment functions
    %   including array phase offset, timing offset, CFO, IQ imbalance,
    %   phase noise, PA nonlinearity, and CIR energy dispersion.
    %
    % Developer: Jia. Institution: PML. Date: 2021/07/16
    
    properties
        
        % Indicator of array phase offset. Simulate phase offset among
        % receive antennas. The offset angles added from the real test.
        % Support case: center frequency 2.565GHz, bandwidth 100MHz, 4-ant
        % receive array, 30KHz SCS, and horizontal orientation only.
        % The value can be false or true.
        Ind_AntPhaseOffset = 0;
        
        % Indicator of timing offset. Simulate timing offset at the
        % receivers. The value must be one of {0 1 2}. Value 0 means No
        % timing offset, Value 1 means constant timing offset, and Value 2
        % means truncated Ganssian distribution with [-2sigma, 2sigma] for
        % sigma = 5 ns.
        Ind_TimingOffset = 0;
        
        % Indicator of carrier frequency offset. Simulate carrier frequency
        % offset. The value must be one of {0 1 2}. Value 0 means No CFO,
        % Value 1 means constant CFO (150Hz), and Value 2 means variable
        % CFO with uniform distribution +/- 0.05 ppm.
        Ind_CarrFreqOffset = 0;
        
        % Indicator of IQ imbalance. Simulate IQ imbalance at transceivers.
        % The value must be one of {0 1 2 3}. Value 0 means perfect IQ,
        % Value 1 means frequency independent Tx-Rx IQ imbalance, Value 2
        % Value 2 means frequency dependent Tx-Rx IQ imbalance, and Value 3
        % means both independent and dependent cases.
        Ind_IQImbalance = false;
        
        % Indicator of phase noise. Simulate phase noise. The value must be
        % one of {0 1 2 3}. Value 0 means no phase noise, Value 1 means
        % phase noise type 1 which followed by frequency multiplication,
        % Value 2 means phase noise type 2 which followed by IIR filter,
        % Value 3 means phase noise type 3 which followed by the method as
        % in R1-163984 of 3GPP proposals.
        Ind_PhaseNoise = 0;
        
        % Indicator of power amplifier nonlineariry. Simulate nonlinearity
        % of power amplifier. The value can be false or true.
        Ind_PowAmpNonlinear = false;
        
        % Indicator of beamsteering error. The value 0 means deactivated
        % while 1 means activated. 
        Ind_BeamStrErr = 0;
        
        % Indicator of energy dispersion of channel impulse response.
        % The value must be false or true. When Value 0 is set, then the
        % channel impulse response with enegry disperse effect is simulated.
        % If true the delay will be orders of time samples.
        Ind_ApproxiCIR = false;
        
        % Indicator of additive noise. Simulate additive noise at the
        % receivers. The value must be one of {0 1 2 3}. Value 0 means that
        % the noise is generated according to the ground noise and noise
        % figure, Value 1 means that SNR calculated according to the path
        % loss, and Value 2 means that the signal power is obtained by
        % measuring the signal in the first OFDM symbol, and Value 3 means
        % no noise.
        Ind_SNR = 0;
        
    end
    
    properties ( Hidden )
        
        % Parameters for antenna phase offset simulation.
        PhOffset_intp;
        % Indicator of nonuniform BS-array for the antenna phase offset
        % simulation only. Value 1 means that the specific measured phase
        % offset from nonuniform array is considered.
        IndnonuniBSarray = 0;
        
        % Parameters for timing offset simulation.
        TOsigma = 5; % ns
        
        % Parameters for carrier frequency offset simulation.
        CFOepsilon;
        CFOrange = 0.05; %for case 2: TRP: uniform distribution +/-0.05ppm
        
        % Parameters for IQ imbalance.
        %  QcarrierRx:  -QGainRx*sin(wt + QPhaseRx) %
        %  QcarrierTx:  -QGainTx*sin(wt + QPhaseTx) %
        % Frequency independent
        QGainTx = 1.5;   % gain     1 for perfect IQ
        QPhaseTx = 6;    % degree    0 for perfect IQ
        QGainRx = 0.5;   % gain     1 for perfect IQ
        QPhaseRx = 6;    % degree    0 for perfect IQ
        % Frequency dependent
        h_TxI = [1, 0.04 -0.03];   % Tx I branch impulse response
        h_TxQ = [1, -0.04 -0.03];   % Tx Q branch impulse response
        h_RxI = [1, 0.05];   % Rx I branch impulse response
        h_RxQ = [1, -0.05];   % Rx Q branch impulse response
        
        % Parameters for nonlinearity of power amplifier simulation.
        PANg = 4.65;
        PANs = 0.81;
        PANAsat = 0.58;
        PANalpha = 2560;
        PANbeta = 0.114;
        PANq1 = 2.4;
        PANq2 = 2.3;
        
        % Parameters for phase noise simulation.
        fz1 = 100e6;
        fp1 = 1e6;
        fz2 = [1.8 2.2 40] * 1e6;
        fp2 =  [0.1 0.2 8] * 1e6;
        
        % Parameters for additive noise simulation.
        noise_Wsig = 100e6;%  for 100MHz bandwidth
        Pgroundnoise = 0; %10*log10( noise_K * noise_T * noise_Wsig);
        noise_K = 1.38e-23; % J/k   joule / K
        noise_T = 290; % k
        BSnoisefig = 5; %dB
        UEnoisefig = 9; %dB
        
        % Paras for beamsteering error
        Nbit = 6; % bit number of digital phase shifter
        Del_pha = 4; % RMS phase error
        Del_amp = 1.5; % RMS amplitude error
        % Random stream seeds.
        randstream1 = RandStream('dsfmt19937');
        randstream2 = RandStream('dsfmt19937');
        randstream3 = RandStream('dsfmt19937');
        randstream4 = RandStream('dsfmt19937');
        randstream5 = RandStream('dsfmt19937');
    end

    
    properties (Hidden)
        center_frequency;
        SCS;
        sampleRate;
        SNR;
        NSa;% = [4448, ones(1,13)* 4384 ];
        nFFT;% = 4096;
        nRr;
        nTr;
        SubCarrierused;
        nGridsize;
        IndUplink;
        SymbolsPerSlot;
    end
    
    methods
        
        % Constructor
        function obj =  RFImpairConfig( sysPar, carrier )
            if exist('sysPar', 'var') && ~isempty( sysPar ) && ...
                    exist('carrier', 'var') && ~isempty( carrier )
                obj.center_frequency = sysPar.center_frequency;
                obj.SubCarrierused = sysPar.SubCarrierused;
                obj.IndUplink = sysPar.IndUplink;
                obj.SCS = carrier.SubcarrierSpacing;
                obj.sampleRate = carrier.SampleRate;
                obj.SymbolsPerSlot = carrier.SymbolsPerSlot;
                obj.nFFT = carrier.Nfft;
                obj.nGridsize = carrier.NSizeGrid;
                obj.NSa = carrier.NSa;
                obj.nRr = sysPar.nRr;
                obj.nTr = sysPar.nTr;
                obj.noise_Wsig = sysPar.bandwidth;
                if obj.Ind_AntPhaseOffset == 1
                    if sysPar.nRx ~= 4|| sysPar.center_frequency~=2.565e9
                        error('System setting for AntPhasOffset is limited. ');
                    end
                end
            else
                error('RFImpairConfig:WrongInput !');
            end
        end
        
        %get functions
        function out = get.CFOepsilon(obj)
            switch obj.Ind_CarrFreqOffset
                case 0
                    out = 0;
                case 1
                    out = 0.01;
                case 2
                    out = ( rand( obj.randstream1 ) * obj.CFOrange...
                        * 2 - obj.CFOrange ) * 1e-6 * obj.center_frequency ...
                        / (obj.SCS * 1000);
            end
        end
        
        function out = get.Pgroundnoise(obj)
            out = 10 * log10( obj.noise_K * obj.noise_T * obj.noise_Wsig );
        end
        
        % Set functions
        function set.Ind_AntPhaseOffset(obj, value)
            if ~( all(size(value) == [1 1]) && (isnumeric(value) || ...
                    islogical(value)) && any( value == [0 1] ) )
                error('RFImpairConfig: Ind_AntPhaseOffset. The value must be 0 or 1.');
            end
            obj.Ind_AntPhaseOffset = logical( value );
        end
        
        function set.Ind_TimingOffset(obj, value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) && any( value == [0 1 2] ) )
                error('RFImpairConfig:Ind_TimingOffset. The value must be 0 1 or 2.');
            end
            obj.Ind_TimingOffset = value;
        end
        
        function set.Ind_CarrFreqOffset(obj, value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) && any( value == [0 1 2] ) )
                error('RFImpairConfig:Ind_CarrFreqOffset. The value must be 0 1 or 2.');
            end
            obj.Ind_CarrFreqOffset = value;
        end
        
        function set.Ind_IQImbalance(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) && any( value == [0 1 2 3] ) )
                error('RFImpairConfig:Ind_IQImbalance. The value must be 0 1 2 3.');
            end
            obj.Ind_IQImbalance = value;
        end
        
        function set.Ind_PhaseNoise(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) && any( value == [0 1 2 3] ) )
                error('RFImpairConfig:Ind_PhaseNoise. The value must be 0 1 2 3.');
            end
            obj.Ind_PhaseNoise = ( value );
        end
        
        function set.Ind_PowAmpNonlinear(obj,value)
            if ~( all(size(value) == [1 1]) && (isnumeric(value) || ...
                    islogical(value)) && any( value == [0 1] ) )
                error('RFImpairConfig:Ind_PowAmpNonlinear. The value must be 0 or 1.');
            end
            obj.Ind_PowAmpNonlinear = logical( value );
        end
        
        function set.Ind_ApproxiCIR(obj,value)
            if ~( all(size(value) == [1 1]) && (isnumeric(value) || ...
                    islogical(value)) && any( value == [0 1] ) )
                error('RFImpairConfig:Ind_ApproxiCIR. The value must be 0 or 1.');
            end
            obj.Ind_ApproxiCIR = logical( value );
        end
        
        function set.Ind_SNR(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) && any( value == [0 1 2 3] ) )
                error('RFImpairConfig:Ind_SNR. The value must be 0 1 2 3.');
            end
            obj.Ind_SNR =  ( value );
        end
        
    end
    
    methods
        % generate interpolate antenna phase offset
        function get_interpPhaseoffset(obj);
            if obj.Ind_AntPhaseOffset == 1
                obj.PhOffset_intp = RFImpairConfig.gen_AntPhaseOffset( ...
                obj.IndnonuniBSarray );
            end
        end
    end
    
    methods (Static, Access = protected)
        function out = gen_AntPhaseOffset(IndnonuniBSarray)
            % Generate antenna phase offset for linear or nonlinear array.
            PhaseDiff = zeros(241,11,4);
            if ~IndnonuniBSarray %
                for i = 1 : 11
                    dat = 50+i;
                    filename = strcat(['@RFImpairConfig\data_antphaoff\uniform',...
                        '\test_normal2.'],num2str(dat),'5.csv');
                    a = readmatrix(filename);
                    PhaseDiff(:,i,:) = a(:,2:5);
                end
            else
                for i = 1 : 11
                    dat = 50+i;
                    filename = strcat(['@RFImpairConfig\data_antphaoff\nonuniform', ...
                        '\array2\test_normal_1_Ant2_2.'],num2str(dat),'5.csv');
                    a = readmatrix(filename);
                    PhaseDiff(:,i,:) = a(:,2:5);
                end
            end
            [x,y,z] = size(PhaseDiff);
            [hx,hy,hz] = meshgrid(1:30/10000:y,1:1/5:x,1:z);
            out = interp3(PhaseDiff, hx, hy, hz, 'spline');
            a = zeros(1201,4096-3334,4);
            out = cat(2, out,a);
        end
    end
end