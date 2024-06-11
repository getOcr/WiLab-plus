% 计算数据的累积分布
%data = posEr(posEr<10);
data = rangeEr(rangeEr<10);
data1 = data;
sorted_data = sort(data1);
n = numel(sorted_data);
y = (1:n) / n;

% 绘制CDF图
figure;

plot(sorted_data, y,'LineWidth',1.5);
grid on;
%xlabel('二维AOA定位误差（米）');
xlabel('二维测距误差（米）');
ylabel('累计分布函数');
%title('新平台定位误差累积分布函数图');
title('新平台定位测距误差累积分布函数图');