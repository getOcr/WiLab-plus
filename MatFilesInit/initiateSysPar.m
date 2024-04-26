function [sysPar,varargin] = initiateSysPar(fileCfg,varargin)
% function [sysPar,varargin] = initiateSysPar(fileCfg,varargin)
%
% Settings of the V2X sidelink positioning sysPar 
% It takes in input the name of the (possible) file config and the inputs
% of the main function
% It returns the structure "sysPar"

fprintf('sysPar settings\n');

[sysPar,varargin] = addNewParam([],'bandwidth',1e8,'bandwidth','double',fileCfg,varargin{1});
[sysPar,varargin] = addNewParam(sysPar,'center_frequency',4.9e9,'center_frequency','double',fileCfg,varargin{1});
[sysPar,varargin] = addNewParam(sysPar,'nFrames',0.05,'nFrames (s)','double',fileCfg,varargin{1});

sysPar.center_frequency = 4.9e9;
sysPar.UEstate = 'dynamic';% static or dynamic
sysPar.VelocityUE = 100;%    3/3.6 m/s
sysPar.BSArraySize = [1 4];
sysPar.UEArraySize = [1 1];
sysPar.nBS = 2;
sysPar.nUE = 1;
sysPar.RSPeriod = 4;  % n slot
sysPar.SignalType = 'SRS';       %'SRS', 'CSIRS'
sysPar.BeamSweep = 0;
sysPar.SNR = 20; % in dB 
sysPar.bandwidth = 1e8;