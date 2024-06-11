%%%W=40M 
d = 10:2:50;
root_CRLB_15kHz_MCS5 = zeros(size(d)); % 创建一个与 d 相同大小的零矩阵用于存储计算结果
root_CRLB_30kHz_MCS5 = zeros(size(d));
root_CRLB_60kHz_MCS5 = zeros(size(d));
root_CRLB_15kHz_MCS23 = zeros(size(d));
root_CRLB_30kHz_MCS23 = zeros(size(d));
root_CRLB_60kHz_MCS23 = zeros(size(d));
for i = 1:length(d)
    root_CRLB_15kHz_MCS5(i) = sqrt(CalculateCRLBDistance(15, 5, d(i)));
    root_CRLB_30kHz_MCS5(i) = sqrt(CalculateCRLBDistance(30, 5, d(i)));
    root_CRLB_60kHz_MCS5(i) = sqrt(CalculateCRLBDistance(60, 5, d(i)));
    root_CRLB_15kHz_MCS23(i) = sqrt(CalculateCRLBDistance(15, 23, d(i)));
    root_CRLB_30kHz_MCS23(i) = sqrt(CalculateCRLBDistance(30, 23, d(i)));
    root_CRLB_60kHz_MCS23(i) = sqrt(CalculateCRLBDistance(60, 23, d(i)));
end

% 绘图
figure;
hold on;
loglog(d, root_CRLB_15kHz_MCS5, 'b-o', 'linewidth',1.2 , 'MarkerFaceColor', 'blue', 'DisplayName', 'MCS:    5 , SCS: 15 kHz');
loglog(d, root_CRLB_30kHz_MCS5, 'r-s', 'linewidth',1.2 , 'MarkerFaceColor', 'red', 'DisplayName', 'MCS:    5 , SCS: 30 kHz');
loglog(d, root_CRLB_60kHz_MCS5, 'black-x', 'linewidth',1.2 , 'MarkerFaceColor', 'black', 'DisplayName', 'MCS:    5 , SCS: 60 kHz');


loglog(d, root_CRLB_15kHz_MCS23, 'b--o', 'linewidth',1.2 , 'MarkerFaceColor', 'none', 'DisplayName', 'MCS:  23 , SCS: 15 kHz');
loglog(d, root_CRLB_30kHz_MCS23, 'r--s', 'linewidth',1.2 , 'MarkerFaceColor', 'none', 'DisplayName', 'MCS:  23 , SCS: 30 kHz');
loglog(d, root_CRLB_60kHz_MCS23, 'black--x', 'linewidth',1.2 , 'MarkerFaceColor', 'black', 'DisplayName', 'MCS:    23, SCS: 60 kHz');

hold off;
% 设置纵坐标范围
ylim([1e-3, 1e-1]);
% 设置图例
legend('Location', 'best');

% 设置坐标轴标签
xlabel('收发车辆间距 [m]');
ylabel('测距估计的克拉美罗界的二次根号值[m]');

% 设置标题
title('克拉美罗界受MCS和SCS的影响');

% 网格显示
grid on;
set(gca, 'XScale', 'log', 'YScale', 'log'); % 确保坐标轴是对数刻度

% % 注释
% text(10, 10^-1.5, 'The vehicular density is 30 veh/km.', 'FontSize', 8);
% text(10, 10^-1.7, 'The packet size is 350 bytes.', 'FontSize', 8);




%函数定义模块
function CRLB_distance = CalculateCRLBDistance(SCS,MCS,d)
    c = 3 * 10^8; % Speed of light
    pi_value = pi;
    M = 14;
    Nant = 1;
    fc = 5.9*1e9;
    G_dB = 3;
    F_dB = 6;
    RCS = 10;
    Pt = 23;
    I = 0 ; 
    if (SCS==15)&&(MCS==5)
        N=480/3;
    elseif (SCS==30)&&(MCS==5)
        N=480/1.4;
    elseif (SCS==60)&&(MCS==5)
        N=480;
    elseif (SCS==15)&&(MCS==23)
        N=120/1.5 ;
    elseif (SCS==30)&&(MCS==23)
        N=120/1.1 ;
    elseif (SCS==60)&&(MCS==23)
        N=120;
    end
    
    temp = 3 * c^2 / (8 * pi_value^2 * M * N * Nant * (N^2 - 1) * SCS^2 * 1e6);
    disp(['CRLB_distance_temp: ', num2str(temp)]);
    SINR = CalculateSINR(Pt, G_dB, I, F_dB, fc, d, N, SCS,RCS);
    CRLB_distance =temp/SINR;
end


function SINR = CalculateSINR(Pt, G_dB, I, F_dB, fc, d, N, SCS,RCS)
    c = 3 * 10^8; % Speed of light
    T0 = 290;
    KB = physconst('Boltzmann');
    
    G = CalculatedB_Ratio(G_dB);
    F = CalculatedB_Ratio(F_dB);
    Pt = CalculatedB_Ratio(Pt) / 1000;
    
    Pr = Pt * G^2 * c^2 * RCS / ((4*pi)^3 * fc^2 * d^4);
    Pn = KB * T0 * F * N * SCS * 1e3;
    
    disp(['Pr: ', num2str(Pr)]);
    disp(['Pn: ', num2str(Pn)]);

    SINR = Pr / (Pn + I);
    disp(['SINR Ratio: ', num2str(SINR)]);
end


function dB_Ratio  = CalculatedB_Ratio(dB)
    dB_Ratio =  10.^(dB / 10);
end


