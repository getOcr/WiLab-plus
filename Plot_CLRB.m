
x = 10:5:30; % 0到90度，每隔1度取一个值

y = [0.5830923,0.9396177,1.3066432,2.0676982,2.8493476];

figure;
plot(x, y, 'LineWidth', 2);
xlabel('Distance (m)');
ylabel('CRLB for Distance');
title('CRLB vs. Distance');
xlabel('Positioning Error / m');ylabel('CDF ');
title(['User']);
grid on;


%第一种分段函数
% t1=0:0.1:3;
% v1=0;
% t2=3:0.1:6;
% v2=1;
% t=[t1 t2];
% v=[v1 v2];
% plot(t,v);
% axis([0 10 0 1]);
% xlabel('Positioning Error / m');ylabel('CDF ');
% title(['User']);
% grid on;


% x=0:0.1:10;
% y=[];
% for xx=x
%     if(xx<3)
%         y=[y,0];
% 
%     else
%         y=[y,1];
% end
% end
% plot(x,y,'LineWidth', 2);
% xlabel('Positioning Error / m');ylabel('CDF ');
% title(['定位CDF']);
% grid on;



% 定义 CRLB 范围
% 定义 CRLB 范围
% 定义 CRLB 范围
% 定义横坐标范围
% 定义横坐标范围
% x_values = linspace(10, 30, 100);
% 
% % 定义凸函数（这里使用了一个简单的二次函数作为示例）
% crlb_values = 0.0015 + 0.0001 * (x_values - 20).^2;
% 
% % 画图
% plot(x_values, crlb_values, 'LineWidth', 2);
% hold on;
% 
% % 加三角形符号
% marker_indices = [1, 50, 100]; % 选择三个位置添加符号
% plot(x_values(marker_indices), crlb_values(marker_indices), '^', 'MarkerSize', 8, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'black');
% 
% xlabel('距离');
% ylabel('CRLB');
% title('凸函数曲线');
% 
% % 添加图例
% legend('凸函数曲线', '三角形符号');
% 
% % 在图上添加网格线
% grid on;
