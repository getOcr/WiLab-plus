classdef CarrierConfig < handle
    %CarrierConfig time-frequncey carrier resource configuration
    %
    % This class aims to generate carrier-related time-frequecy
    % resource configuration information. All parameters are meeting the
    % 3GPP NR standards.
    %
    % Developer: Jia. Institution: PML. Date: 2021/08/18
    
    properties
        % Physical cell identity. N = 1008.
        NCellID = 0;
        % Length of resource grid in RB.
        NSizeGrid = 25;    
        % Cyclic prefix. The value must be one of {'normal','extended'}.
        CyclicPrefix = 'normal';     
        % Subcarrier spacing. The value must be one of {15 30 60 120 240}.
        SubcarrierSpacing = 30;     
        % FFT point number of fft transformation.
        Nfft = 4096;
        
    end
    
    properties ( Dependent )
        % Symbol number of a slot.
        SymbolsPerSlot;
        % Slot number of a sub frame.
        SlotsPerSubframe;
        % Slot number of a frame.
        SlotsPerFrame;
        % Sample number of a symbol.
        NSa ; %[4448, ones(1,13)* 4384,4448, ones(1,13)* 4384 ];
        % Sampling rate.
        SampleRate;
    end
    
    methods
        % get functions
        function out = get.CyclicPrefix(obj)
            if strcmpi(obj.CyclicPrefix,'extended') && ...
                    obj.SubcarrierSpacing ~= 60
                error(['CarrierConfig: CyclicPrefix. Extended',...
                    'cyclicprefix works with SCS =60.']);
            end
            out = obj.CyclicPrefix;
        end
        
        function out = get.SymbolsPerSlot(obj)
            if strcmpi(obj.CyclicPrefix, 'extended')
                out = 12;
            else
                out = 14;
            end
        end
        
        function out = get.SlotsPerSubframe(obj)
            out = obj.SubcarrierSpacing /15;
        end
        
        function out = get.SlotsPerFrame(obj)
            out =  obj.SubcarrierSpacing /15 *10;
        end
        
        function out = get.NSa(obj)
            kappa = 64;
            mu = log2( obj.SubcarrierSpacing /15);
            rat = 2048 *kappa *2^( -mu) /obj.Nfft;
            if strcmpi(obj.CyclicPrefix, 'extended')
                Ncp = 512 *kappa *2^( -mu) /rat * ...
                    ones(1, obj.SymbolsPerSlot *2^mu);
            elseif strcmpi(obj.CyclicPrefix, 'normal')
                Ncp = [ (144 *kappa *2^( -mu) +16 *kappa ) /rat, ...
                    144 *kappa *2^( -mu) /rat *ones( 1, 7 *2^mu -1 ),...
                    ( 144 *kappa *2^( -mu) +16 *kappa ) /rat, 144 *kappa ...
                    *2^( -mu ) /rat * ones( 1, 7 *2^mu -1 ) ];
            end
            out = Ncp + obj.Nfft;
        end
        
        function out = get.SampleRate(obj)
            out = obj.SubcarrierSpacing * obj.Nfft;
            
        end
        
        % set functions
        function set.NCellID(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  any(value == (0:1007) ))
                error(['CarrierConfig:NCellID. The value must be one of',...
                    ' {0,...,1007}.']);
            end
            obj.NCellID = value;
        end
        
        function set.NSizeGrid(obj,value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) &&  value >= 0  )
                error('CarrierConfig:NSizeGrid. The value must be >= 0.');
            end
            obj.NSizeGrid = value;
        end
        
        function set.CyclicPrefix(obj,value)
            if strcmpi(value,'normal') ||strcmpi(value,'extended')
                obj.CyclicPrefix = value;
            else
                error(['CarrierConfig:CyclicPrefix. The value must be ',...
                    '''normal'' or ''extended''.']);
            end
        end
        
        function set.Nfft(obj, value)
            if ~( all(size(value) == [1 1]) && (isnumeric(value) || ...
                    islogical(value)) &&  any(value == [256 384 512 768 ...
                    1024 1536 2048 3072 4096] ))
                error(['CarrierConfig:NFFT. The value must be one of {256',...
                    ' 384 512 768 1024 1536 2048 3072 4096}.']);
            end
            obj.Nfft = value;
        end
        
        
    end
end