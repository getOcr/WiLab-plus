classdef ParaEstimation < handle
    % ParaEstimation Initialize the parameters for angle, range, and location
    % estimation.
    %
    % DESCRIPITION
    %   This class controls the parameters of angles, range, and location
    %   estimation.
    %
    %   Developer: Jia. Institution: PML. Date: 2021/08/06
    
    properties
        % 1-D or 2-D angle estimation
        %
        % Select angle estimation method. Six methods are considered: music1, 
        % ssmusic1, music1_angle_tdoa, dbf1, dbf1_angle_tdoa, dbf2, music2 
        AngEstiMethodSel = 'dbf1';
        
        % TOA estimation
        %
        % Select TOA estimation method. Two methods are considered: 
        % toa_dbf and toa_music
        RngEstiMethodSel = 'toa_dbf';
        
        % Assumed number of signal sources for MUSIC-based methods
        nTarget = 1; 
        
        % Location estimation
        %
        % Select BS number for multi-BS positioning.
        nBSsel = 2;  
        
        % Select successive slot number for location estimation algorithm.
        segmSlot = 1; % n slots fusion  n  must no greater than nslot
        
        % Subcarrier spacing in KHz required for AOA estimation.
        SCS = 30;
    end
    
    properties( Hidden, SetAccess = private )
        % Subcarrier spacing in Hz required for AOA estimation.
        deltaf;
        c = 299792458;
    end
    methods
        function set.AngEstiMethodSel(obj, val)
           if ~(  strcmpi( val, 'dbf1' ) || strcmpi( val, 'dbf2' ) || strcmpi( val, 'ssmusic1' ) ||...
                   strcmpi( val, 'music2' ) || strcmpi( val, 'dbf1_angle_tdoa' ) ...
                   || strcmpi( val,'music1' ) || strcmpi( val,'music1_angle_tdoa' ) )
               error('ParaEstimation: Wrong input of AngEstiMethodSel');
           else
               obj.AngEstiMethodSel = val;
           end 
        end
        
        function set.RngEstiMethodSel(obj, val)
            if ~(  strcmpi( val, 'toa_dbf' )|| strcmpi( val, 'toa_music' ) )
                error('ParaEstimation: Wrong input of RngEstiMethodSel');
            else
                obj.RngEstiMethodSel = val;
            end
        end
        
        function set.nTarget(obj, val)
           if ~( all(size(val) == [1 1] ) && isnumeric(val) && ...
                    isreal(val) && val >= 1 )
               error('ParaEstimation: Wrong input of nTarget');
           else
               obj.nTarget = val;
           end 
        end
        
        function set.nBSsel(obj, val)
           if ~( all(size(val) == [1 1] ) && isnumeric(val) && ...
                    isreal(val) && val >= 2 )
               error('ParaEstimation: Wrong input of nBSsel');
           else
               obj.nBSsel = val;
           end
        end
        
       function set.segmSlot(obj,val)
           if ~( all(size(val) == [1 1] ) && isnumeric(val) && ...
                    isreal(val) && val >= 1 )
               error('ParaEstimation: Wrong input of segmSlot');
           else
               obj.segmSlot = val;
           end
        end
        
        function set.SCS(obj, val)
            if ~( all(size(val) == [1 1] ) && isnumeric(val) && ...
                    isreal(val) && any( val == [15 30 60 120 240] ) )
               error('ParaEstimation: Wrong input of nTarget');
           else
               obj.SCS = val;
           end 
        end
        
        function out = get.deltaf(obj)
            out = obj.SCS * 1000;
        end
    end
    
end