function [SelTxBeamAng, SelRxBeamAng] = gen_beamorientresult(BSC, sysPar, carrier, Layout, data)
%gen_beamorientresult generate beamforming-based angle estimation result.
%
% Description:
%   This function aims to generate angle estimation result based on
%   beamforming methods as follows:
%   ( 1 ) The first method is followed by the paper: ''Two-dimensional AoD 
%   and AoA acquisition for wideband millimeter-wave systems with 
%   dual-polarized MIMO''. TWC 2017.
%   ( 2 ) The second method is a variant of ( 1 ), using three beams.
%   ( 3 ) The third method is the sum and diff beamforming method.
%
% Developer: Jia. Institution: PML. Date: 2022/01/10

nTr = sysPar.nTr;
nRr = sysPar.nRr;
SelRxBeamAng = zeros(2, nRr, nTr);
SelTxBeamAng = zeros(2, nRr, nTr);
for iTr = 1 : nTr
    for iRr = 1 : nRr
        if BSC.IndrxBmSweep == 1
            rsrp = data.rsrp(:,:, iRr, iTr).';
            spatfreq = BSC.Rxspatfreq;
        else
            rsrp = data.rsrp(:,:, iRr, iTr);
            spatfreq = BSC.Txspatfreq;
        end
        lambda = 1 ;
        d = lambda /2;
        delta = BSC.SpatFreqoffset; % pi/M
        if BSC.IndOrientFind == 1
            % Method 1
            zeta1 = ( rsrp(1,1) - rsrp(1,3) ) / ( rsrp(1,1) + rsrp(1,3) );
            eta1 = spatfreq(1,2);
            mu1 = eta1 - asin( ( zeta1 * sin( delta ) - zeta1 .* ...
                sqrt( 1- zeta1.^2) * sin(delta) * cos(delta) ) ./ ...
                ( sin( delta )^2 + zeta1.^2 * cos( delta )^2 ) );    
            zeta2 = ( rsrp(1,4) - rsrp(1,6) ) / ( rsrp(1,4) + rsrp(1,6) );
            eta2 = spatfreq(2, 5);
            mu2 = eta2 - asin( ( zeta2 * sin( delta ) - zeta2 .* ...
                sqrt( 1 -zeta2.^2 ) *  sin( delta ) * cos( delta ) ) ./ ...
                ( sin( delta )^2 + zeta2.^2 * cos( delta )^2 ) );
            SelBeamAng(2, 1) = acos( mu2 / ( 2 *pi *d /lambda ) ) / pi * 180;
            SelBeamAng(1, 1) = asin( mu1 / ( 2 *pi *d /lambda ) / ...
                sin( SelBeamAng(2, 1) /180 *pi ) ) /pi *180;
        elseif BSC.IndOrientFind == 2
            % Method 2, the optimal delta = pi / (M/2);
            if rsrp(1, 1) > rsrp(1, 3)
                zeta1 = ( rsrp(1, 1) - rsrp(1, 2) ) / ( rsrp(1, 1) + rsrp(1, 2) );
                eta1 = spatfreq(1, 2) - delta /2;
            else
                zeta1 = ( rsrp(1, 2) - rsrp(1, 3) ) / ( rsrp(1, 2) + rsrp(1, 3) );
                eta1 = spatfreq(1, 2) + delta /2;
            end
            if rsrp(1, 4) > rsrp(1, 6)
                zeta2 = ( rsrp(1, 4) - rsrp(1, 5) ) / ( rsrp(1, 4) + rsrp(1, 5) );
                eta2 = spatfreq(2, 5) - delta /2;
            else
                zeta2 = ( rsrp(1, 5) - rsrp(1, 6) ) / (rsrp(1, 5) + rsrp(1, 6) );
                eta2 = spatfreq(2, 5) + delta /2;
            end
            mu1 = eta1 - asin( ( zeta1 * sin( delta /2 ) - zeta1 .* ...
                sqrt( 1 - zeta1.^2 ) * sin( delta /2 ) * cos( delta /2 ) ) ...
                ./ ( sin( delta /2 )^2 + zeta1.^2 * cos( delta /2 )^2 ) );
            mu2 = eta2 - asin( ( zeta2 * sin( delta /2 ) - zeta2 .* ...
                sqrt( 1 - zeta2.^2 ) * sin( delta /2 ) * cos( delta /2 ) ) ...
                ./ ( sin( delta /2 )^2 + zeta2.^2 * cos( delta /2 )^2 ) );
            SelBeamAng(2, 1) = acos( mu2 / ( 2* pi* d / lambda ) ) / pi * 180;
            SelBeamAng(1, 1) = asin( mu1 / ( 2* pi* d / lambda ) / ...
                sin( SelBeamAng(2, 1) / 180 * pi ) ) / pi * 180;
        elseif BSC.IndOrientFind == 3
            % Method 3  
            if BSC.IndrxBmSweep
                Nazim = BSC.RxArraySize(2);  
                Nelev = BSC.RxArraySize(1);  
            else
                Nazim = BSC.TxArraySize(2);  
                Nelev = BSC.TxArraySize(1); 
            end       
            H = nr.channelestimate( carrier, data.rxGrid, data.rsIndices, ...
                data.rsSymbols, 1, [1 1] );  % (nSC * nSym * nRx * nTx)
            angle_z = angle( H( data.rsIndices(1, 1) ) / H( data.rsIndices(1, 2) ) );
            angle_y = angle( H( data.rsIndices(1, 3) ) / H( data.rsIndices(1, 2) ) );
            xi_y = sqrt( rsrp(1, 3) ) / sqrt( rsrp(1, 2) );
            de_y = 2* lambda * atan(xi_y) / ( pi* d* Nazim ) * ( -sign( angle_y) );
            theta = acos( de_y + cos( BSC.SndDeterAngle(2, 1) / 180 * pi) ) /pi*180;
            xi_z = sqrt( rsrp(1, 1) ) / sqrt( rsrp(1, 2) );
            de_z = 2* lambda * atan( xi_z ) / ( pi* d* Nelev ) * ( -sign(angle_z) );
            phi = asin( (de_z + sin(BSC.SndDeterAngle(1,1) /180*pi )* ...
                sin( BSC.SndDeterAngle(2, 1) /180 *pi) )/ sin(theta /180 *pi)) /pi*180;
            SelBeamAng(2, 1) = theta;
            SelBeamAng(1, 1) = phi;
        end
        
        if BSC.IndrxBmSweep == 0
            SelTxBeamAng(:, iRr, iTr) = SelBeamAng;
            if sysPar.IndUplink
                SelRxBeamAng(:, iRr, iTr) = [0;90]+Layout.BSorientation((1:2),iRr)/pi*180;
            else
                SelRxBeamAng(:, iRr, iTr) = [0;90]+Layout.UEorientation((1:2),iRr)/pi*180;
            end
        else
            SelRxBeamAng(:, iRr, iTr) = SelBeamAng;
            if sysPar.IndUplink
                SelTxBeamAng(:, iRr, iTr) = [0;90]+Layout.UEorientation((1:2),iTr)/pi*180;
            else
                SelTxBeamAng(:, iRr, iTr) = [0;90]+Layout.BSorientation((1:2),iTr)/pi*180;
            end
        end
    end
end
end