function DS = get_DS_ServCell(HHinfo, channeltype, nUE, Ind_servBS);
%get_DS_ServCell generate timedelay spread for channel calibration.
DS = zeros(1, nUE);
if strcmpi(channeltype, 'static')
    for iUE = 1 : nUE
        iBS = Ind_servBS(iUE);
        delay = HHinfo.ssp(iBS, iUE).cluster.tau_n;
        P_n = HHinfo.ssp(iBS, iUE).cluster.P_n1;
        DS(1,iUE) = get_timedelayspread(delay, P_n);
    end
else
    for iUE = 1 : nUE
        iBS = Ind_servBS(iUE);
        delay =  HHinfo.ssp(iBS, iUE).cluster.tau_n_tilde(:,1);
        P_n = HHinfo.ssp(iBS, iUE).cluster.P_n1;
        DS(1,iUE) = get_timedelayspread(delay, P_n);
    end
end
end