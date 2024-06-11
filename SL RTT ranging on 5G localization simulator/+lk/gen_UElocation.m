function [EstiLoc,LocErr,BS_sel,power_rs,index,pos_BS,nn] = gen_UElocation(sysPar,data,PE);
%gen_UElocation Estimate locations by LS.
%
% Description:
%   This function aims to perform LS-based localization algorithm with
%   given azimuth angles among multiBSs. multislot fusion is available.
%   Output: LocationsEsti  % [x;y]*n; LocError n = fix( nslot /segmSlot);
%   BS_sel： BS selected for positioning.
%
% Developer: Jia. Institution: PML. Date: 2021/12/28

nBS = sysPar.nBS;
nUE = sysPar.nUE;
nRSslot = sysPar.nRSslot;    %1
segmSlot = PE.segmSlot; %%  multislot estimation
nBSsel = PE.nBSsel;  %  the number of BS selected for positioning （2）
nn = fix( nRSslot / segmSlot);  %1
LocErr = zeros(nn, nUE);
EstiLoc = zeros(2, nn, nUE);
if nBS <= 1
    error('Error: sysPar.nBS must be >= 2 for multiBS localization !');
end

for iUE = 1 : nUE
    if strcmpi(sysPar.UEstate,'dynamic')
        if sysPar.IndUplink
            posReal_UE = data.Hinfo.ssp(1,iUE).bs.tx_positions_t(1:2,1:nRSslot);
        else
            posReal_UE = data.Hinfo.ssp(1,iUE).bs.rx_positions_t(1:2,1:nRSslot);
        end
    else
        posReal_UE = repmat(sysPar.UEPos(1:2, iUE),[1 nRSslot]);
    end
    % select BSs according the power of CIRs
    power_rs = zeros(nBS, nn);
    for iBS = 1 : nBS
        for ii = 1 : nn
            if sysPar.IndUplink
                power_rs(iBS, ii) = rms(data.hcfr_esti(:,1,1,segmSlot * ...
                    (ii -1) +1,iBS, iUE) );
            else
                power_rs(iBS, ii) = rms(data.hcfr_esti(:,1,1,segmSlot * ...
                    (ii -1) +1,iUE, iBS) );
            end
        end
    end
    [~, index] = sort(power_rs);   %排列后的矩阵不输出，只输出排序后的索引
    BS_sel = index( end - nBSsel +1: end, :);     %所选BS的index

    pos_BS = cell(nn , 1);
    for ii = 1 : nn
        pos_BS{ii,1} =  sysPar.BSPos( (1 :2), BS_sel(:, ii) );  %所选取的BS的位置
    end

    ObAngle = zeros( nBSsel , nRSslot);
    for islot = 1 : nRSslot
        for iBSsel = 1 : nBSsel
            if sysPar.IndUplink
                ObAngle(iBSsel, islot) = data.Angle_esti(islot, BS_sel(iBSsel, ...
                    fix((islot -1) / segmSlot ) +1), iUE,1).';
            else
                ObAngle(iBSsel, islot) = data.Angle_esti(islot, iUE, ...
                    BS_sel(iBSsel, fix((islot -1) / segmSlot ) +1),1).';
            end
        end
    end
    pos_o = zeros(2, 1);
    for  ii = 1 : nn
        Z = reshape(ObAngle(:  ,( (segmSlot * (ii -1) +1): (segmSlot * ii) ) ), ...
            nBSsel * segmSlot, 1);
        pos_up = posReal_UE(:, segmSlot * (ii -1) +1) + randn(2, 1) *0.1;
        itemp = 0;
        while ( sum(( pos_up - pos_o) .^2) > 1e-3 && itemp < 300 )
            pos_o = pos_up;
            r2 = sum( ( pos_o - pos_BS{segmSlot * (ii -1) +1} ) .^2, 1)';
            temp = ( pos_o - pos_BS{segmSlot * (ii -1) +1})';
            H = atan( temp(:, 2) ./ temp(:, 1) );
            H1 = repmat(H, segmSlot, 1);
            B = (pos_o - pos_BS{segmSlot * (ii -1)+1})' ./ r2 * [0 1 ;-1 0];
            B1 = repmat(B, segmSlot, 1);
%             pos_up = (B1'* B1)\ B1'* (Z - H1) + pos_o;
            pos_up = lsqminnorm(B1'* B1, B1') * (Z - H1) + pos_o;  %返回可以求解线性方程 A*pos_up = B 并使 norm(A*pos_up-B) 的值最小化的数组 pos_up
            itemp= itemp +1;
        end
        EstiLoc(:, ii,iUE) = pos_up;
        LocErr(ii,iUE) =sqrt( sum((posReal_UE(:,segmSlot * (ii-1)+1) -pos_up).^2));
    end
end
end