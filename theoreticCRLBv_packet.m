%%%W=40M 
clear;
clc;

d = 10:2:50;
d2 = 5:2:45;
root_CRLB_15kHz_MCS5 = zeros(size(d)); % 创建一个与 d 相同大小的零矩阵用于存储计算结果
root_CRLB_30kHz_MCS5 = zeros(size(d));
root_CRLB_60kHz_MCS5 = zeros(size(d));
root_CRLB_15kHz_MCS23 = zeros(size(d));
root_CRLB_30kHz_MCS23 = zeros(size(d));
root_CRLB_60kHz_MCS23 = zeros(size(d));
for i = 1:length(d)
    root_CRLB_15kHz_MCS5(i) = sqrt(CalculateCRLBVelocity(15, 350, d(i)));
    root_CRLB_30kHz_MCS5(i) = sqrt(CalculateCRLBVelocity(30, 350, d(i)));
    root_CRLB_60kHz_MCS5(i) = sqrt(CalculateCRLBVelocity(60, 350, d(i)));
    root_CRLB_15kHz_MCS23(i) = sqrt(CalculateCRLBVelocity(15, 1000, d2(i)));
    root_CRLB_30kHz_MCS23(i) = sqrt(CalculateCRLBVelocity(30, 1000, d2(i)));
    root_CRLB_60kHz_MCS23(i) = sqrt(CalculateCRLBVelocity(60, 1000, d2(i)));
end

% 绘图
figure;
hold on;
loglog(d, root_CRLB_15kHz_MCS5, 'b-o', 'linewidth',1.2 , 'MarkerFaceColor', 'blue', 'DisplayName', 'PacketSize: 350, SCS: 15 kHz');
loglog(d, root_CRLB_30kHz_MCS5, 'r-s', 'linewidth',1.2 , 'MarkerFaceColor', 'red', 'DisplayName', 'PacketSize: 350 , SCS: 30 kHz');
loglog(d, root_CRLB_60kHz_MCS5, 'black-h', 'linewidth',1 , 'MarkerFaceColor', 'black', 'DisplayName', 'PacketSize: 350, SCS: 60 kHz');

loglog(d2, root_CRLB_15kHz_MCS23, 'b--o', 'linewidth',1.2 , 'MarkerFaceColor', 'yellow', 'DisplayName', 'PacketSize: 1000, SCS: 15 kHz');
loglog(d2, root_CRLB_30kHz_MCS23, 'r--s', 'linewidth',1.2 , 'MarkerFaceColor', 'yellow', 'DisplayName', 'PacketSize: 1000, SCS: 30 kHz');
loglog(d2, root_CRLB_60kHz_MCS23, 'black--h', 'linewidth',1 , 'MarkerFaceColor', 'yellow','DisplayName', 'PacketSize: 1000, SCS: 60 kHz');

hold off;
% 设置纵坐标范围
%ylim([1e-3, 1e-1]);
% 设置图例
legend('Location', 'best');

% 设置坐标轴标签
xlabel('收发车辆之间的距离[m]');
ylabel('速度估计的克拉美罗界[m/s]');

% 设置标题
title('速度估计的克拉美罗界受数据包大小和SCS的影响');

% 网格显示
grid on;
set(gca, 'XScale', 'log', 'YScale', 'log'); % 确保坐标轴是对数刻度


function CRLB_v = CalculateCRLBVelocity(SCS,Packet,d)
    c = 3 * 10^8; % Speed of light
    MCS = 5;
    pi_value = pi;
    M = 14;
    Nant = 1;
    fc = 5.9*1e9;
    G_dB = 3;
    F_dB = 6;
    RCS = 10;
    Pt = 23;
    I = 0 ; 
    Tsym = 1/(SCS);
    if (SCS==15)&&(Packet==350)
        N=480;
    elseif (SCS==30)&&(Packet==350)
        N=480;
    elseif (SCS==60)&&(Packet==350)
        N=480;

    elseif (SCS==15)&&(Packet==1000)
        N=1200 ;
    elseif (SCS==30)&&(Packet==1000)
        N=1200 ;
    elseif (SCS==60)&&(Packet==1000)
        N=1200;
    end
    
    %temp = 3 * c^2 / (8 * pi_value^2 * M * N * Nant * (N^2 - 1) * SCS^2 * 1e6);
    temp = 3*c*c/(8*pi*pi*Tsym^2*fc^2*M*N*(M*M-1));
    disp(['CRLB_v_temp: ', num2str(temp)]);
    SINR = CalculateSINR(Pt, G_dB, I, F_dB, fc, d, N, SCS,RCS);
    CRLB_v =temp/SINR;
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