% % 角度范围
% x = 10:2:30; % 0到90度，每隔1度取一个值
% 
% y = x.^2;
% y2 = 1./cosd(x).^2;
% 
% 
% RootCRLB_percentile_99 = prctile(y, 99);
% 
% 
% disp(RootCRLB_percentile_99)
% % 绘制CRLB_angle和角度的曲线
% figure;
% plot(x, percentile_value, 'LineWidth', 2);
% xlabel('Angle (degrees)');
% ylabel('CRLB for angle');
% title('CRLB vs. Angle');
% grid on;

% % 模拟数据
% second_element = 10 * 10^(0.7/19);
% disp(second_element);
% d = 10:10:50;
% %d = logspace(1, 1.7, 20); % 创建对数间隔的距离值[0.1325579,0.2842733,0.6428727,1.1258253,1.8007652];
% 
% root_CRLB_15kHz_MCS11 = [0.1325579,0.2842733,0.6428727,1.1258253,1.8007652];
% root_CRLB_30kHz_MCS11 = [0.0395437,0.0867265,0.1932977,0.3422788,0.5343979];
% % root_CRLB_15kHz_MCS5 = [0.1184768,0.1860952,0.3287064,0.7359484,1.6582595];
% 
% 
% % root_CRLB_15kHz_MCS11 = [0.1325579,0.2011577,0.3587985,0.7988017,1.8007652];
% % root_CRLB_30kHz_MCS11 = [0.0395437,0.0619075,0.1080350,0.2402894,0.5343979];
% % root_CRLB_15kHz_MCS5 = [0.1184768,0.1860952,0.3287064,0.7359484,1.6582595];
% % root_CRLB_30kHz_MCS5 = 10.^(-3.2 + 0.05*(d-10));
% % root_CRLB_60kHz_MCS5 = 10.^(-3.4 + 0.05*(d-10));
% % root_CRLB_15kHz_MCS23 = 10.^(-2.7 + 0.05*(d-10));
% % root_CRLB_30kHz_MCS23 = 10.^(-2.9 + 0.05*(d-10));
% % root_CRLB_60kHz_MCS23 = 10.^(-3.1 + 0.05*(d-10));
% 
% % 绘图
% figure;
% loglog(d, root_CRLB_15kHz_MCS11, 'o-', 'MarkerFaceColor', 'blue', 'DisplayName', 'MCS: 11, SCS: 15 kHz');
% hold on;
% loglog(d, root_CRLB_30kHz_MCS11, 's-', 'MarkerFaceColor', 'blue', 'DisplayName', 'MCS: 11, SCS: 30 kHz');
% loglog(d, root_CRLB_15kHz_MCS5, 'o--', 'MarkerFaceColor', 'red', 'DisplayName', 'MCS: 5, SCS: 15 kHz');
% % loglog(d, root_CRLB_15kHz_MCS23, 'o-', 'MarkerFaceColor', 'red', 'DisplayName', 'MCS: 23, SCS: 15 kHz');
% % loglog(d, root_CRLB_30kHz_MCS23, 's-', 'MarkerFaceColor', 'red', 'DisplayName', 'MCS: 23, SCS: 30 kHz');
% % loglog(d, root_CRLB_60kHz_MCS23, 'd-', 'MarkerFaceColor', 'red', 'DisplayName', 'MCS: 23, SCS: 60 kHz');
% hold off;
% 
% % 设置图例
% legend('Location', 'best');
% 
% % 设置坐标轴标签
% xlabel('d [m]');
% ylabel('Root CRLB [m]');
% 
% % 设置标题
% title('95-percentile of the root-CRLB for range estimation');
% 
% % 网格显示
% % grid on;
% set(gca, 'XScale', 'log', 'YScale', 'log'); % 确保坐标轴是对数刻度
% 
% % % 注释
% % text(10, 10^-1.5, 'The vehicular density is 30 veh/km.', 'FontSize', 8);
% % text(10, 10^-1.7, 'The packet size is 350 bytes.', 'FontSize', 8);
% 保留ROOT_CRLB_Range_Array中的数据小数点后三位
% 
% ROOT_CRLB_Range_Array=[0.149172808823007	0.130552014926975	0.130552014926975	0.130552014926975	0.132784747274588	0.132784528744790	0.145156603597571	0.145157148467293	0.134788664591166	0.141466133382066	0.150322839475212	0.147382059748294	0.145685495319249	0.162987438948703	0.175677060101800	0.171173767129191	0.154986400452566	0.170532761585710	0.168419265038907	0.161331909140330	0.157582146711015	0.154144678757803	0.147740154279874	0.153782000617513	0.156040478327027	0.154288561393276	0.168847828858349	0.153958743158119	0.139249423431605	0.136778481317231	0.140853433182237	0.145716933344948	0.145737137148840	0.148126401284112	0.154106831123231	0.157100629002108	0.144949641191411	0.132551067450243	0.139576657509070	0.158104191831840	0.158348337792542	0.158349437825231	0.157356949709694	0.154382120940389	0.169008731860531	0.164812336464356	0.155022466621344	0.150499654142983	0.142186227491754	0.140156073393625	0.143113397532451	0.140296638489037	0.140654986240737	0.135681855533963	0.140362228065592	0.148998850916242	0.143724619958879	0.141070447994043	0.139416791215294	0.140663091738186	0.139550177380495	0.142991204774665	0.148634150871985	0.148634150871985	0.143109349438671	0.140655342551792	0.149228873251838	0.149355097056296	0.146359551084237	0.146216485322063	0.149759760422090	0.146894938260383	0.149398845920489	0.158329144636561	0.162549526927691	0.165395594548339	0.158060417678340	0.154506280936896	0.142956972086490	0.145516310036705	0.148211487267137	0.151333436247519	0.151635167802221	0.162468498975135	0.162468503496899	0.152442741496491	0.142266257705191	0.145578207776150	0.145825842162649	0.140583488893187	0.137715684636676	0.144488173815070	0.156537063406775	0.162149825680013	0.161170766453580	0.149203495310638	0.137255316460858	0.145184627011519];
% ROOT_CRLB_Range_Array_rounded = round(ROOT_CRLB_Range_Array, 3);
% % 绘制Empirical CDF of the root CRLB
% figure;
% ecdf(ROOT_CRLB_Range_Array_rounded);
% title('Empirical CDF of the root CRLB');
% xlabel('Root CRLB');
% ylabel('Cumulative Probability');

% 假设原始的 10x100 矩阵为 A
A = randi([0, 1], 10, 100); % 生成一个随机的 10x100 矩阵，元素为 0 或 1

% 创建一个新的 100x100 矩阵 B，初始值为 0
B = zeros(100, 100);

for col = 1:100
    for row = 1:10
        if A(row, col) == 1
            B(((row-1)*10+1):(row*10), col) = 1; % 将元素为1的行扩展为10行1
        else
            B(((row-1)*10+1):(row*10), col) = 0; % 将元素为0的行扩展为10行0
        end
    end
end
rhos = [30, 50, 70];

for i = rhos
    disp(i); % 这里的 i 将依次取数组 rhos 中的每个元素
    % 在这里可以执行针对每个元素 i 的操作
end
% 现在，矩阵 B 是一个 100x100 的矩阵，其中行元素为 1 的部分被扩展为 10 行 1，行元素为 0 的部分被扩展为 10 行 0
