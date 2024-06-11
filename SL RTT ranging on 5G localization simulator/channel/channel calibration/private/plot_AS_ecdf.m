function plot_AS_ecdf(HH,anglename,nBS,nUE,Ind_sBS);
%plot_AS_ecdf

AS = zeros(1, nUE);
if strcmpi(HH.Ind_state, 'static')
    for iUE = 1 : nUE
        iBS = Ind_sBS(iUE);
        if strcmpi(anglename,'asa')
            theta_nm = HH.info.ssp(iBS, iUE).ray.phi_AOA_nm/180*pi;
            max = 140;
        elseif strcmpi(anglename,'asd')
            theta_nm = HH.info.ssp(iBS, iUE).ray.phi_AOD_nm/180*pi;
            max = 140;
        elseif strcmpi(anglename,'esa')
            theta_nm = HH.info.ssp(iBS, iUE).ray.theta_EOA_nm/180*pi;
            max = 70;
        elseif strcmpi(anglename,'esd')
            theta_nm = HH.info.ssp(iBS, iUE).ray.theta_EOD_nm/180*pi;
            max = 70;
        end
        P_n = HH.info.ssp(iBS, iUE).cluster.P_n1;
        AS(1,iUE) = get_angularspread(theta_nm,P_n)*180/pi;
    end
else
    for iUE = 1 : nUE
        iBS = Ind_sBS(iUE);
        if strcmpi(anglename,'asa')
            theta_nm = HH.info.ssp(iBS, iUE).ray.phi_AOA_nmt(:,:,1)/180*pi;
            max = 140;
        elseif strcmpi(anglename,'asd')
            theta_nm = HH.info.ssp(iBS, iUE).ray.phi_AOD_nmt(:,:,1)/180*pi;
            max = 140;
        elseif strcmpi(anglename,'esa')
            theta_nm = HH.info.ssp(iBS, iUE).ray.theta_EOA_nmt(:,:,1)/180*pi;
            max = 70;
        elseif strcmpi(anglename,'esd')
            theta_nm = HH.info.ssp(iBS, iUE).ray.theta_EOD_nmt(:,:,1)/180*pi;
            max = 70;
        end
        P_n = HH.info.ssp(iBS, iUE).cluster.P_n1;
        AS(1,iUE) = get_angularspread(theta_nm,P_n)*180/pi;
    end
end
plotecdf(AS, 0,max,100,anglename,'degrees');
