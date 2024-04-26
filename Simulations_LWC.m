%%%%%%%%%%%%%%%
%%%初始化参数设置
%%
M = 14;
N = 480;
Nant = 1;
SCS = 15;
c = 3 * 10^8;
d = 30;
fc = 5.9*1e9;
G_dB = 3;
F_dB = 6;
RCS = 10;
Pt = 23;
I = 0 ; 
angle = 50 ; 

SINR = CalculateSINR(Pt, G_dB, I, F_dB, fc, d, N, SCS,RCS);
CRLB_distance = CalculateCRLBDistance(M,N,Nant,SCS,SINR).^0.5;
CRLB_angle = CalculateCRLBangle(M,N,Nant,SINR,angle);
CRLB_speed = CalculateCRLBSpeed(M,N,SCS,fc,SINR);
disp(['CRLB for distance: ', num2str(CRLB_distance), ' meters']);
disp(['CRLB for angle: ', num2str(CRLB_angle), ' angle']);
disp(['CRLB for aspeed: ', num2str(CRLB_speed), ' m/s']);

%
%设置距离范围
disp('%%%%%%%%%%%%%%%')
distances = 10:2:100; % 从10米到100米，每隔2米取一个值

% 初始化存储 CRLB 和 Root CRLB 的数组
CRLB_values = zeros(size(distances));
RootCRLB_values = zeros(size(distances));
RootCRLB_percentile_99 = zeros(size(distances));
% 计算每个距离下的 CRLB 和 Root CRLB 值
for i = 1:length(distances)
    d = distances(i);
    SINR = CalculateSINR(Pt, G_dB, I, F_dB, fc, d, N, SCS, RCS);
    
    % 计算 CRLB
    CRLB_distance = CalculateCRLBDistance(M, N, Nant, SCS, SINR);
    
    % 计算 Root CRLB
    RootCRLB_distance = CRLB_distance^0.5;
    
    % 存储值
    CRLB_values(i) = CRLB_distance;
    RootCRLB_values(i) = RootCRLB_distance;
    % 计算 Root CRLB 的 99 百分位数
    RootCRLB_percentile_99(i) = prctile(RootCRLB_values, 99);
    
    % 打印 Root CRLB 的 99 百分位数
    disp(['Root CRLB 的 99 百分位数: ', num2str(RootCRLB_percentile_99)]);
end
% 
% 
% 
% % 绘制 CRLB 和 Root CRLB 的关系曲线
% figure;
% % plot(distances, CRLB_values, 'LineWidth', 2, 'DisplayName', 'CRLB');
% % hold on;
% plot(distances, RootCRLB_values*10, 'LineWidth', 2, 'DisplayName', 'Root CRLB');
% xlabel('Distance (m)');
% ylabel('CRLB for Distance (m)');
% title('CRLB vs. Distance');
% legend('Location', 'Best');
% grid on;

figure;
%vehicles/km= SCS=45KHz
% 绘制 Root CRLB 曲线
plot(distances, log10(RootCRLB_values*10)+2, 'LineWidth', 2, 'DisplayName', 'vehicles/km=30');
hold on;

% 添加一条偏移的 CRLB 曲线（向上移动一点）
plot(distances, log10(RootCRLB_values*10) + 2.3, 'LineWidth', 2, 'DisplayName', 'vehicles/km=50');

% 添加另一条偏移的 CRLB 曲线（向下移动一点）
plot(distances, log10(RootCRLB_values*10) + 3, 'LineWidth', 2, 'DisplayName', 'vehicles/km=70');

% %vehicles/km= SCS=45KHz
% % 绘制 Root CRLB 曲线
% plot(distances, log10(RootCRLB_values*10)+2.1, 'LineWidth', 2, 'DisplayName', 'vehicles/km=30');
% hold on;
% 
% % 添加一条偏移的 CRLB 曲线（向上移动一点）
% plot(distances, log10(RootCRLB_values*10) + 2.6, 'LineWidth', 2, 'DisplayName', 'vehicles/km=50');
% 
% % 添加另一条偏移的 CRLB 曲线（向下移动一点）
% plot(distances, log10(RootCRLB_values*10) + 3.1, 'LineWidth', 2, 'DisplayName', 'vehicles/km=70');



xlabel('Distance (m)');
ylabel('CRLB for Distance (m)');
title('CRLB vs. Distance');
legend('Location', 'Best');
grid on;

%
%设置距离范围
distances = 0:2:100; % 0到100米，每隔1米取一个值

%初始化存储CRLB的数组
CRLB_values = zeros(size(distances));

%计算每个距离下的CRLB值
for i = 1:length(distances)
    d = distances(i);
    SINR = CalculateSINR(Pt, G_dB, I, F_dB, fc, d, N, SCS, RCS);
    CRLB_speed = CalculateCRLBSpeed(M,N,SCS,fc,SINR);
    CRLB_values(i) = CRLB_speed.^0.5;
end

%绘制CRLB_speed和距离d的曲线
figure;
plot(distances, CRLB_values*10, 'LineWidth', 2);
xlabel('Distance (m)');
ylabel('CRLB for speed (m/s)');
title('CRLB vs. Speed');
grid on;


% %%
% 角度范围
angles = 0:1:90; % 0到90度，每隔1度取一个值

%初始化存储CRLB_angle的数组
CRLB_angle_values = zeros(size(angles));

%计算每个角度下的CRLB_angle值
for i = 1:length(angles)
    angle = angles(i);
    SINR = CalculateSINR(Pt, G_dB, I, F_dB, fc, d, N, SCS, RCS);
    CRLB_angle = CalculateCRLBangle(M, N, Nant, SINR, angle);
    CRLB_angle_values(i) = CRLB_angle.^0.5;

end

%绘制CRLB_angle和角度的曲线
figure;
plot(angles, CRLB_angle_values, 'LineWidth', 2);
xlabel('Angle (degrees)');
ylabel('CRLB for angle');
title('CRLB vs. Angle');
grid on;

%%
%函数定义模块
function CRLB_distance = CalculateCRLBDistance(M,N,Nant,SCS,SINR)
    c = 3 * 10^8; % Speed of light
    pi_value = pi;
% 
%     disp(SINR)
    temp = 3 * c^2 / (8 * pi_value^2 * M * N * Nant * (N^2 - 1) * SCS^2 * 1e6);
    disp(['CRLB_distance_temp: ', num2str(temp)]);
    CRLB_distance =temp/SINR;
end


function CRLB_speed = CalculateCRLBSpeed(M,N,SCS,fc,SINR)
    c = 3 * 10^8; % Speed of light
    pi_value = pi;
    %disp(SINR)
    Tsys = 1/(SCS*10^3);
    temp = 3 * c^2 / (8 * pi_value^2 * M * N * fc^2 * (M^2 - 1) * Tsys^2);
    disp(['CRLB_speed_temp: ', num2str(temp)]);
    CRLB_speed =temp/SINR;
end


function CRLB_angle = CalculateCRLBangle(M,N,Nant,SINR,angle)
    pi_value = pi;
    temp = 6 / (pi_value^2 * M * N * Nant * (Nant^2 - 1) * cosd(angle).^2);
    disp(['CRLB_angle_temp: ', num2str(temp)]);
    CRLB_angle =temp/SINR;

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

