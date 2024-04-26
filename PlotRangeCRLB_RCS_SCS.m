% function
%
%Raw:100
%MCS:23
%v:70

d = 10:10:50;

%0.1508017  0.3388417 0.7538402 1.3074170 1.9468519   0.1508017
root_CRLB_15kHz_100m = [0.0867812,0.1929957,0.4296148,0.7457523,1.1157645];%20M
root_CRLB_15kHz_1m = [0.0484373,0.1055757,0.2366811,0.4166361,0.6532785];%20M
root_CRLB_15kHz_10m = [0.1508017,0.3388417,0.7538402,1.3074170,1.9468519];%40M

 

% root_CRLB_15kHz_MCS11 = [0.1325579,0.2011577,0.3587985,0.7988017,1.8007652];
% root_CRLB_30kHz_MCS11 = [0.0395437,0.0619075,0.1080350,0.2402894,0.5343979];
% root_CRLB_15kHz_MCS5 = [0.1184768,0.1860952,0.3287064,0.7359484,1.6582595];
% root_CRLB_30kHz_MCS5 = 10.^(-3.2 + 0.05*(d-10));
% root_CRLB_60kHz_MCS5 = 10.^(-3.4 + 0.05*(d-10));
% root_CRLB_15kHz_MCS23 = 10.^(-2.7 + 0.05*(d-10));
% root_CRLB_30kHz_MCS23 = 10.^(-2.9 + 0.05*(d-10));
% root_CRLB_60kHz_MCS23 = 10.^(-3.1 + 0.05*(d-10));

% 绘图
figure;
hold on;
loglog(d, root_CRLB_15kHz_10m, 'r-d', 'linewidth',1 , 'MarkerFaceColor', 'red', 'DisplayName', 'RCS:  1 m , SCS: 15 kHz');
loglog(d, root_CRLB_15kHz_100m, 'b-o', 'linewidth',1,'MarkerFaceColor', 'blue', 'DisplayName', 'RCS:  10m, SCS: 15 kHz');
loglog(d, root_CRLB_15kHz_1m, 'yellow-d', 'linewidth',1 , 'MarkerFaceColor', 'yellow', 'DisplayName', 'RCS:100m, SCS: 15 kHz');
% loglog(d, root_CRLB_60kHz_MCS11, 'yellow-s', 'linewidth',1 , 'MarkerFaceColor', 'yellow', 'DisplayName', 'MCS: 11, SCS: 60 kHz');

% loglog(d, root_CRLB_15kHz_1000B, 'b--o', 'linewidth',1 , 'MarkerFaceColor', 'blue', 'DisplayName', 'pack:1000B , SCS: 15 kHz');
% loglog(d, root_CRLB_30kHz_1000B, 'r--d', 'linewidth',1 , 'MarkerFaceColor', 'red', 'DisplayName', 'pack:1000B , SCS: 30 kHz');
% loglog(d, root_CRLB_30kHz_MCS5, 'r--d', 'linewidth',1 , 'MarkerFaceColor', 'red', 'DisplayName', 'MCS:  5 , SCS: 30 kHz');
% loglog(d, root_CRLB_60kHz_MCS5, 'yellow--s', 'linewidth',1 , 'MarkerFaceColor', 'yellow', 'DisplayName', 'MCS:  5 , SCS: 60 kHz');
% loglog(d, root_CRLB_15kHz_MCS23, 'o-', 'MarkerFaceColor', 'red', 'DisplayName', 'MCS: 23, SCS: 15 kHz');
% loglog(d, root_CRLB_30kHz_MCS23, 's-', 'MarkerFaceColor', 'red', 'DisplayName', 'MCS: 23, SCS: 30 kHz');
% loglog(d, root_CRLB_60kHz_MCS23, 'd-', 'MarkerFaceColor', 'red', 'DisplayName', 'MCS: 23, SCS: 60 kHz');
hold off;

% 设置图例
legend('Location', 'best');

% 设置坐标轴标签
xlabel('d [m]');
ylabel('Root CRLB [m]');

% 设置标题
title('95-percentile of the root-CRLB for range estimation');

% 网格显示
grid on;
set(gca, 'XScale', 'log', 'YScale', 'log'); % 确保坐标轴是对数刻度

% % 注释
% text(10, 10^-1.5, 'The vehicular density is 30 veh/km.', 'FontSize', 8);
% text(10, 10^-1.7, 'The packet size is 350 bytes.', 'FontSize', 8);
