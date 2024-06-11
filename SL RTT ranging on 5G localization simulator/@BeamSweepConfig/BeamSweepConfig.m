classdef BeamSweepConfig < handle
    %BeamSweepConfig Initialize the parameters for beam sweeping.
    %
    % DESCRIPTION
    % This class controls the parameters of beam sweeping with reference
    % signals or the synchronization signals. Note that the beamforming
    % considered in the simulator is corresponding to the spatial filter
    % defined in 3GPP physical layer standards, which is also consistent
    % with the beam management defined in 3GPP NR standards.
    %
    % Developer: Jia. Institution: PML. Date: 2021/07/26
    
    % Beam sweeping
    properties
        % Indicator of beam sweeping. The value must be true or false.
        % If true, then the beamforming weight will be considered at the
        % transceivers.
        IndBmSweep = false;
        
        % Indicator of receive beam sweeping. The value must be true or false.
        % When SSBurst considered, 'true' means both transmit and receive
        % beam sweeping. Otherwise, 'true' means only receive beam sweeping
        % considered, while 'false' means only transmit beam sweeping.
        IndrxBmSweep = false;
        
        % Indicator of beam sweeping orientation. The value must be one of
        % {'azimuth', 'elevation'}. The indicator works only when the array
        % is UPA. If the value is absent, the beams orientation criterions
        % are followed by the default setting in the function:
        % 'get_sweepangle'.
        IndSweepOrient = [];
        
        % Range of transmit beam sweeping at the azimuth angle in degree.
        % Note that the positive angle is consistent with counterclockwise.
        % Also the boresight of an array is at the orientation of azimuth
        % angle 0 degree and elevation angle 90 degree.
        % The range must be within [-180, 180].
        TxAzimBmRange = [-60, 60];
        
        % Range of transmit beam sweeping at the elevation angle in degree.
        % Note that the positive angle is consistent with counterwise.
        % Also, the boresight of an array is at the orientation of azimuth
        % angle 0 degree and elevation angle 90 degree.
        % The range must be within [0, 180].
        TxElevBmRange = [90 180];
        
        % Range of receive beam sweeping at the azimuth angle in degree.
        % The range must be within [-180, 180].
        RxAzimBmRange = [-60 60];
        
        % Range of receive beam sweeping at the elevation angle in degree.
        % The range must be within [0, 180].
        RxElevBmRange = [90 180];
        
        % Number of sweeping beams at a transmitter. When transmit
        % beamsweeping is considered, each beam keeps constant during a
        % OFDM symbol, and changes versus different OFDM symbols. The
        % default number of sweeping beams is 12. Note that for SSB
        % resource sets, the number of sweeping beams must be consisent
        % with the number of SSBs per half frame.
        nTxBeam = 12;
        
        % Number of sweeping beams at a receiver. When receive
        % beamsweeping is considered, each beam keeps constant during a
        % OFDM symbol, and changes versus different OFDM symbols. The
        % default number of sweeping beams is 12. Note that for SSB
        % resource sets, the number of sweeping beams must be consisent
        % with the number of SSBs per half frame.
        nRxBeam = 12;
    end
    
    % Orientation finding
    properties
        % Indicator of beam-based orientation finding. The value must be
        % one of {0 1 2 3}. If Value > 0, then the orientation finding is
        % enabled. Specifically, value 1 presents two-beam orient-finding,
        % 2 for three-beam orienting finding, and 3 for sum-and-diff
        % beamforming orientation finding.
        IndOrientFind = 0;
        
        % Angle determined at the Secound beam sweeping ( aka. beam
        % refinement ). This would be taken as the initial estimated angle
        % for beam-based orientation finding.
        SndDeterAngle;
        
        % Spatial-frequency offset for beam-based orientation finding. When
        % auxiliary beam pair based AOA estimation is considered, the value
        % shall be assigned. Usually, pi/N is used for two-beam method, and
        % 2 * pi/(N) is used for three-beam method.
        SpatFreqoffset;
    end
    
    properties (SetAccess = private)
        % Calculated angles of sweeping beams in degree at the transmitter.
        TxBeamAng;
        % Calculated angles of sweeping beams in degree at the receiver.
        RxBeamAng;
        % Calculated beamforming weights of sweeping beams at the transmitter.
        TxWeight;
        % Calculated beamforming weights of sweeping beams at the receiver.
        RxWeight;
        % Calculated spatial frequency of sweeping beams in degree at the
        % transmitter.
        Txspatfreq;
        % Calculated spatial frequency of sweeping beams in degree at the
        % receiver.
        Rxspatfreq;
    end
    
    properties (Constant,Hidden)
        c = 299792458;
    end
    
    properties ( Hidden)
        center_frequency;
        nTx;
        nRx;
        TxArraySize;
        RxArraySize;
        SignalType;
        NSa;
        SlotsPerFrame;
        SymbolsPerSlot;
        SSBSymPos;
        SSBPeriodicity;
        wavelength;
    end
    
    methods
        % Constructor
        function obj = BeamSweepConfig(sysPar, carrier)
            if exist('sysPar','var') && ~isempty(sysPar) && ...
                    exist('carrier','var') && ~isempty(carrier)
                obj.center_frequency = sysPar.center_frequency;
                obj.nTx = sysPar.nTx;
                obj.nRx = sysPar.nRx;
                obj.TxArraySize = sysPar.TxArraySize;
                obj.RxArraySize = sysPar.RxArraySize;
                obj.SignalType = sysPar.SignalType;
                obj.NSa = carrier.NSa;
                obj.SlotsPerFrame = carrier.SlotsPerFrame;
                obj.SymbolsPerSlot = carrier.SymbolsPerSlot;
                if strcmpi( sysPar.SignalType, 'SSB')
                    obj.SSBSymPos = sysPar.SigRes(1).SSBSymPos;
                    obj.SSBPeriodicity = sysPar.SigRes(1).SSBPeriodicity;
                end
                if obj.IndOrientFind > 0 && sysPar.nBeams < 6
                    error('BeamSweepConfig:nBeam must >= 6 for beam orienting');
                end
            else
                error('BeamSweepConfig: WrongInput of sysPar or carrier!');
            end
        end
        
        % Get functions
        function out = get.wavelength(obj)
            out = obj.c / obj.center_frequency;
        end
        
        % Set functions
        function set.IndBmSweep(obj, value)
            if ~( all(size(value) == [1 1]) && (isnumeric(value) || ...
                    islogical(value)) && any( value == [0 1] ) )
                error('BeamSweepConfig: Wrong input of IndBmSweep.');
            end
            obj.IndBmSweep = logical(value);
        end
        
        function set.IndrxBmSweep(obj, value)
            if ~( all(size(value) == [1 1]) && (isnumeric(value) || ...
                    islogical(value)) && any( value == [0 1] ) )
                error('BeamSweepConfig: Wrong input of IndrxBmSweep.');
            end
            obj.IndrxBmSweep = logical(value);
        end
        
        function set.IndSweepOrient(obj, value)
            if ~( strcmpi(value, 'azimuth') || strcmpi(value, 'elevation') )
                error(['BeamSweepConfig: wrong input of IndSweepOrient.']);
            end
            obj.IndSweepOrient = (value);
        end
        
        function set.TxAzimBmRange(obj, value)
            if ~( all(size(value) == [1 2]) && isnumeric(value) && ...
                    isreal(value) && value(1) < value(2) )
                error('BeamSweepConfig:TxAzimBmRange. value(1) < value(2).');
            end
            obj.TxAzimBmRange = (value);
        end
        
        function set.TxElevBmRange(obj,value)
            if ~( all(size(value) == [1 2]) && isnumeric(value) && ...
                    isreal(value) && value(1) < value(2) )
                error('BeamSweepConfig:TxElevBmRange. value(1) < value(2).');
            end
            obj.TxElevBmRange = (value);
        end
        
        function set.RxAzimBmRange(obj,value)
            if ~( all(size(value) == [1 2]) && isnumeric(value) && ...
                    isreal(value) && value(1) < value(2) )
                error('BeamSweepConfig:RxAzimBmRange. value(1) < value(2).');
            end
            obj.RxAzimBmRange = (value);
        end
        
        function set.RxElevBmRange(obj,value)
            if ~( all(size(value) == [1 2]) && isnumeric(value) && ...
                    isreal(value) && value(1) < value(2) )
                error('BeamSweepConfig:RxElevBmRange. value(1) < value(2).');
            end
            obj.RxElevBmRange = (value);
        end
        
        function set.nTxBeam(obj, value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) && value > 0 )
                error('BeamSweepConfig:nTxBeam. The value must be > 0.');
            end
            obj.nTxBeam = (value);
        end
        
        function set.nRxBeam(obj, value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) && value > 0 )
                error('BeamSweepConfig:nRxBeam. The value must be > 0.');
            end
            obj.nRxBeam = (value);
        end
        
        function set.IndOrientFind(obj, value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) && any( value == [0 1 2 3] ) )
                error('BeamSweepConfig: Wrong input of IndOrientFind.');
            end
            obj.IndOrientFind = (value);
        end
        
        function set.SpatFreqoffset(obj, value)
            if ~( all(size(value) == [1 1]) && isnumeric(value) && ...
                    isreal(value) && all( value <= pi/2 ) && ...
                    all(value >= -pi/2 ) )
                error('BeamSweepConfig: wrong input of SpatFreqoffset.');
            end
            obj.SpatFreqoffset = (value);
        end
        
        % Functions: Generate beamforming parameters of sweeping beams at
        % transceivers.
        function get_SweepBeamsPara(obj)
            if ~isempty(obj.SSBSymPos)
                [obj.TxBeamAng, obj.TxWeight, obj.Txspatfreq] = obj.txBeamCalc(obj);
                [obj.RxBeamAng, obj.RxWeight, obj.Rxspatfreq] = obj.rxBeamCalc(obj);
            elseif obj.IndrxBmSweep
                [obj.RxBeamAng, obj.RxWeight, obj.Rxspatfreq] = obj.rxBeamCalc(obj);
                obj.TxBeamAng = nan; obj.TxWeight = nan; obj.Txspatfreq  = nan;
            else
                [obj.TxBeamAng, obj.TxWeight, obj.Txspatfreq] = obj.txBeamCalc(obj);
                obj.RxBeamAng = nan; obj.RxWeight = nan; obj.Rxspatfreq = nan;
            end
        end
    end
    
    methods (Static, Access = protected)
        function [txBeamAng, TxWeight, Txspatfreq] = txBeamCalc( obj )
            if logical( obj.IndOrientFind ) == false
                txBeamAng = get_sweepangle(obj, obj.nTxBeam, obj.TxArraySize,...
                    obj.TxAzimBmRange, obj.TxElevBmRange);
                TxWeight = get_beamformweight(obj, txBeamAng, obj.TxArraySize);
                Txspatfreq = [];
            else
                [TxWeight, txBeamAng, Txspatfreq] = get_orientbeamweight(obj,...
                    obj.nTxBeam, obj.SndDeterAngle, obj.TxArraySize, ...
                    obj.SpatFreqoffset);
            end
        end
        
        function [rxBeamAng, RxWeight, Rxspatfreq] = rxBeamCalc( obj )
            if logical( obj.IndOrientFind ) == false
                rxBeamAng = get_sweepangle(obj, obj.nRxBeam, obj.RxArraySize,...
                    obj.RxAzimBmRange, obj.RxElevBmRange);
                RxWeight = get_beamformweight(obj, rxBeamAng, obj.RxArraySize);
                Rxspatfreq = [];
            else
                [RxWeight, rxBeamAng, Rxspatfreq] = get_orientbeamweight(obj,...
                    obj.nRxBeam, obj.SndDeterAngle, obj.RxArraySize,...
                    obj.SpatFreqoffset);
            end
        end
    end
end