function plotCDF(sysPar,data);
% PLOTCDF Plot cumulative distributed function of positioning error
% Note: x-axis range is 0~10m
%%================================%%
temp = zeros(1,1000);
nUE = sysPar.nUE;
figure;
for iUE = 1 : nUE
    for i = 1 : 1000
        temp(i) = sum( data.LocErrall(:, iUE) <= i/100);
    end
    subplot(nUE,1,iUE);
    plot(1/100:1/100:10,temp/length(data.LocErrall(:,iUE)));grid on;
    xlabel('Positioning Error / m');ylabel('CDF ');
    title(['User',num2str(iUE)]);
     set(gca,'FontName','Times New Roman','FontSize',10);
    axis([0 10 0 1]);
end
end