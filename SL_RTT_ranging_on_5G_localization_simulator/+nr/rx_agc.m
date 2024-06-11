function waveout = rx_agc(wavein, pathloss, sysPar, iRr, iTr, Indup);
%rx_agc simulate automatic gain control mode at the receiver.
%
% Description:
%   This function aims to compansate path loss at the receiver according to
%   the path loss calculated in the wireless channel model.
%
% Developer: Jia. Institution: PML. Date: 2021/08/18

[~, L ] = size( wavein );
if Indup
    pathloss = pathloss.';
end
gain_pl = repmat( sqrt( 10^( pathloss( iTr,iRr ) /10 ) ), [ 1 L ] );
gain_TxAnt = 30000/ (50.7 *2 /sysPar.BSArraySize(1) ) /...
    ( 50.7 *2 /sysPar.BSArraySize(2));
gain = gain_pl /gain_TxAnt;
waveout = wavein .* gain;
end