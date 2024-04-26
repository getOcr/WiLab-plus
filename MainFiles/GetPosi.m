function[sysPar]=GetPosi(positionManagement,sysPar)
% This function aims to get the postions from the main function of Wilab+
%for localization
% Modificated by Jin on 2024/4/23 for functionizing the code

% 合并 x 和 y 坐标矩阵成一个位置矩阵
positionsVehicles = [positionManagement.XvehicleReal, positionManagement.YvehicleReal];
% 计算每个位置到 x=500 的距离
distances_to_500 = abs(positionsVehicles(:, 1) - 500);
% 找到离 x=500 最近的三个车辆位置用于定位
[sorted_distances, sorted_indices] = sort(distances_to_500);
nearest_indices = sorted_indices(1:3);
nearest_positions = positionsVehicles(nearest_indices, :);
% 对 nearest_positions 进行排序
sorted_nearest_positions = sortrows(nearest_positions);

All_positions=sorted_nearest_positions';
sysPar.BSPos = [All_positions(1, 1), All_positions(1, 3); All_positions(2, 1), All_positions(2, 3);sysPar.h_BS,sysPar.h_BS];
sysPar.UEPos = [All_positions(1, 2); All_positions(2, 2);sysPar.h_UE];


end