% function
%
%Raw:100
%MCS:23
%v:70

d = 10:10:50;


% root_CRLB_15kHz_350B = [0.0867812,0.1929957,0.4296148,0.7457523,1.1157645];%20M
% root_CRLB_30kHz_350B = [0.0484373,0.1055757,0.2366811,0.4166361,0.6532785];%20M
% root_CRLB_60kHz_350B = [];%40M
% 
% 
% root_CRLB_15kHz_1000B = [0.1194864,0.2722023,0.5928204,1.0565647,1.5554106];%20M
% root_CRLB_30kHz_1000B = [0.0734585,0.1600343,0.3600405,0.6314761,0.9819655];%40M
% root_CRLB_60kHz_1000B = [];%40M

%实验2：raw=100 density=30 MCS=5 BW=40 v=40 
root_CRLB_15kHz_350B=[0.0301 0.0673 0.1515 0.2693 0.4205 ];
root_CRLB_30kHz_350B=[0.0209 0.0467 0.1051 0.1868 0.2973 ];
root_CRLB_60kHz_350B=[0.0150 0.0334 0.0752 0.1337 0.2063 ];

root_CRLB_15kHz_1000B = [0.0431 0.0963 0.2167 0.3853 0.6536];
root_CRLB_30kHz_1000B = [0.0299 0.0668 0.1501 0.2674 0.4142];
root_CRLB_60kHz_1000B = [0.0212 0.0473 0.1064 0.1891 0.2954];

% 绘图
figure;
hold on;
loglog(d, root_CRLB_15kHz_350B, 'b-o', 'linewidth',1,'MarkerFaceColor', 'blue', 'DisplayName', 'pack: 350B, SCS: 15 kHz');
loglog(d, root_CRLB_30kHz_350B, 'r-d', 'linewidth',1 , 'MarkerFaceColor', 'red', 'DisplayName', 'pack: 350B, SCS: 30 kHz');
loglog(d, root_CRLB_60kHz_350B, 'black-s', 'linewidth',1 , 'MarkerFaceColor', 'black', 'DisplayName', 'pack: 350B, SCS: 60 kHz');

loglog(d, root_CRLB_15kHz_1000B, 'b--o', 'linewidth',1 , 'MarkerFaceColor', 'blue', 'DisplayName', 'pack:1000B , SCS: 15 kHz');
loglog(d, root_CRLB_30kHz_1000B, 'r--d', 'linewidth',1 , 'MarkerFaceColor', 'red', 'DisplayName', 'pack:1000B , SCS: 30 kHz');
loglog(d, root_CRLB_60kHz_1000B, 'black--s', 'linewidth',1 , 'MarkerFaceColor', 'black', 'DisplayName', 'pack:1000B , SCS: 60 kHz')
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
