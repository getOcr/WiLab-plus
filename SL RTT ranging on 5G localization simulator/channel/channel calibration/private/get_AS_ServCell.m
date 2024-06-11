function AS = get_AS_ServCell(HHinfo, channeltype, nUE, Ind_servBS, ASname);
%get_AS_ServCell generate angular spread for channel calibration.
AS = zeros(1, nUE);
if strcmpi(channeltype, 'static')
    for iUE = 1 : nUE
        iBS = Ind_servBS(iUE);
        if strcmpi(ASname,'asa')
            theta_nm = HHinfo.ssp(iBS, iUE).ray.phi_AOA_nm/180*pi;
        elseif strcmpi(ASname,'asd')
            theta_nm = HHinfo.ssp(iBS, iUE).ray.phi_AOD_nm/180*pi;
        elseif strcmpi(ASname,'esa')
            theta_nm = HHinfo.ssp(iBS, iUE).ray.theta_EOA_nm/180*pi;
        elseif strcmpi(ASname,'esd')
            theta_nm = HHinfo.ssp(iBS, iUE).ray.theta_EOD_nm/180*pi;
        end
        P_n = HHinfo.ssp(iBS, iUE).cluster.P_n1;
        AS(1,iUE) = get_angularspread(theta_nm,P_n)*180/pi;
    end
else
    for iUE = 1 : nUE
        iBS = Ind_servBS(iUE);
        if strcmpi(ASname,'asa')
            theta_nm = HHinfo.ssp(iBS, iUE).ray.phi_AOA_nmt(:,:,1)/180*pi;
        elseif strcmpi(ASname,'asd')
            theta_nm = HHinfo.ssp(iBS, iUE).ray.phi_AOD_nmt(:,:,1)/180*pi;
        elseif strcmpi(ASname,'esa')
            theta_nm = HHinfo.ssp(iBS, iUE).ray.theta_EOA_nmt(:,:,1)/180*pi;
        elseif strcmpi(ASname,'esd')
            theta_nm = HHinfo.ssp(iBS, iUE).ray.theta_EOD_nmt(:,:,1)/180*pi;
        end
        P_n = HHinfo.ssp(iBS, iUE).cluster.P_n1;
        AS(1,iUE) = get_angularspread(theta_nm,P_n)*180/pi;
    end
end
end