function plotecdf(data,min,max,del,name,xunit);
%plotecdf display ecdf of the data.
temp = zeros(del, 1);
for i = 0 : del-1 
temp(i+1) = sum(data <= ((i)/del * (max-min) +min), 'all');
end
% figure;
grid_x = min : (max - min ) /del : max - (max - min ) /del;
plot(grid_x, temp/numel(data));grid on;xlabel([name,' / ',xunit],'LineWidth',1.5);
ylabel('CDF / %'); set(gca,'FontName','Times New Roman','FontSize',11);
end