close all;
clear all;
clc;
vcf = [6e9 30e9 60e9 70e9 6e9 30e9 60e9 70e9 6e9 30e9 60e9 70e9 ];
cescen = {'umi','umi','umi','umi','uma','uma','uma','uma',...
    'indoor','indoor','indoor','indoor'};
%---------------------------------
% % Configuration 1
for iii = 1 : 12
    %-------------------------------
    Scenario = cescen( iii ); % cell sty
    cf = vcf( iii );
    %------------------------------------    
    var_cell = {'cl','wsir','ds','asd','esd','asa','esa'};
    name_cell = {'Coupling Loss','Wideband SIR','Delay Spread','ASD','ESD','ASA','ESA'};
    unit_cell = {'dB','dB','nsec','deg','deg','deg','deg'};
    grid_min = [-180 -30 0 0 0 0 0];
    grid_max = [-60 40 8000 140 70 140 70];
    
    for iF = 1 : 7
%         load('.\data\fullcalib_conf1_indr901_result.mat',['sim_',...
%             (Scenario{1}),'_',num2str(fix(cf/1e9)),'_',var_cell{iF}]);
        load('.\data\fullcalib_conf1_result.mat',['sim_',(Scenario{1}),'_',...
            num2str(fix(cf/1e9)),'_',var_cell{iF}]);
        load('.\data\Fullcalib1.mat',[(Scenario{1}),'_',num2str(fix(cf/1e9)),...
            '_',var_cell{iF}]);
    end
    figure; set(gcf,'position',[300,100,1200,900],'color','w');
    for iF = 1 : 7
        subplot(3,3,iF);
        plotecdf(eval([(Scenario{1}),'_',num2str(fix(cf/1e9)),'_',var_cell{iF}]),...
            grid_min(iF),grid_max(iF),100,name_cell{iF},unit_cell{iF});hold on;
        plotecdf(eval(['sim_',(Scenario{1}),'_',num2str(fix(cf/1e9)),'_',var_cell{iF}]),...
            grid_min(iF),grid_max(iF),100,name_cell{iF},unit_cell{iF});hold on;
        title([upper(Scenario{1}),'-',num2str(fix(cf/1e9)),'GHz']);
        hl=legend('3GPP ref. mean','Simulator','Location','Best');
    end    
end
% Configuration 2
for iii = 1 : 12
    %-------------------------------
    Scenario = cescen( iii ); % cell sty
    cf = vcf( iii );
    %------------------------------------    
    var_cell = {'cl','wsir','1st','2nd','ratio'};
    var1_cell = {'CL','WSIR','LSV','SSV','RATIO'};
    name_cell = {'Coupling Loss','Wideband SIR','Largest singular value (LSV)',...
        'Smallest singular value (SSV)','Ratio between LSV and SSV'};
    unit_cell = {'dB','dB','dB','dB','dB'};
    grid_min = [-180 -30 -30 -80 0];
    grid_max = [-60 40 30 20 90];
    
    for iF = 1 : 5
        load('.\data\fullcalib_conf2_result.mat',['sim_',(Scenario{1}),'_',...
            num2str(fix(cf/1e9)),'_',var_cell{iF}]);
%         load('.\data\fullcalib_conf2_38900_result.mat',['sim_',(Scenario{1}),'_',...
%             num2str(fix(cf/1e9)),'_',var_cell{iF}]);
        load('.\data\Fullcalib2.mat',[(Scenario{1}),'_',num2str(fix(cf/1e9)),...
            '_',var_cell{iF}]);
    end
    figure; set(gcf,'position',[300,100,1200,900],'color','w');
    for iF = 1 : 5
        subplot(2,3,iF);
        plotecdf(eval([(Scenario{1}),'_',num2str(fix(cf/1e9)),'_',var_cell{iF}]),...
            grid_min(iF),grid_max(iF),100,name_cell{iF},unit_cell{iF});hold on;
        plotecdf(eval(['sim_',(Scenario{1}),'_',num2str(fix(cf/1e9)),'_',var_cell{iF}]),...
            grid_min(iF),grid_max(iF),100,name_cell{iF},unit_cell{iF});hold on;
        title([upper(Scenario{1}),'-',num2str(fix(cf/1e9)),'GHz']);
        hl=legend('3GPP ref. mean','Simulator','Location','Best');   
    end    
end