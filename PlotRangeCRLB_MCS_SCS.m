
d = 10:10:50;
%d = logspace(1, 1.7, 20); % 创建对数间隔的距离值[0.1325579,0.2842733,0.6428727,1.1258253,1.8007652];

%实验2：raw=100 density=30 MCS=5/23 BW=40 v=40
root_CRLB_15kHz_MCS23=[0.0566 0.1264 0.2843 0.5055 0.7898 ];
root_CRLB_30kHz_MCS23=[0.0400 0.0894 0.2012 0.3577 0.5590 ];
root_CRLB_60kHz_MCS23=[0.0296 0.0660 0.1486 0.2641 0.4127 ];

root_CRLB_15kHz_MCS5=[0.0301 0.0673 0.1515 0.2693 0.4205 ];
root_CRLB_30kHz_MCS5=[0.0209 0.0467 0.1051 0.1868 0.2973 ];
root_CRLB_60kHz_MCS5=[0.0150 0.0334 0.0752 0.1337 0.2063 ];


% root_CRLB_15kHz_MCS11 = [0.1325579,0.2842733,0.6428727,1.1258253,1.8007652];%10M
% root_CRLB_30kHz_MCS5 = [0.0395437,0.0867265,0.1932977,0.3422788,0.5343979];%10M
% root_CRLB_60kHz_MCS5 = [0.0265150,0.0578361,0.1293410,0.2284627,0.3543471];%40M
% 
% root_CRLB_15kHz_MCS5 = [0.1184768,0.2630236,0.5973408,1.0493046,1.6582595];%10M
% root_CRLB_30kHz_MCS11 = [0.0552856,0.1214806,0.2700435,0.4793783,0.7504245];%20M
% root_CRLB_60kHz_MCS11 = [0.0336569,0.0733564,0.1640595,0.2901017,0.4512764];%40M


% 绘图
figure;
hold on;
loglog(d, root_CRLB_15kHz_MCS23, 'b-o', 'linewidth',1,'MarkerFaceColor', 'blue', 'DisplayName', 'MCS: 23, SCS: 15 kHz');
loglog(d, root_CRLB_30kHz_MCS23, 'r-', 'linewidth',1 , 'MarkerFaceColor', 'red', 'DisplayName', 'MCS: 23, SCS: 30 kHz');
loglog(d, root_CRLB_60kHz_MCS23, 'black-s', 'linewidth',1 , 'MarkerFaceColor', 'black', 'DisplayName', 'MCS: 23, SCS: 60 kHz');

loglog(d, root_CRLB_15kHz_MCS5, 'b--o', 'linewidth',1 , 'MarkerFaceColor', 'blue', 'DisplayName', 'MCS:  5 , SCS: 15 kHz');
loglog(d, root_CRLB_30kHz_MCS5, 'r--d', 'linewidth',1 , 'MarkerFaceColor', 'red', 'DisplayName', 'MCS:  5 , SCS: 30 kHz');
loglog(d, root_CRLB_60kHz_MCS5, 'black--s', 'linewidth',1 , 'MarkerFaceColor', 'black', 'DisplayName', 'MCS:  5 , SCS: 60 kHz');
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
