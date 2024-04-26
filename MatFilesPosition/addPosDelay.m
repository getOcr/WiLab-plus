function [Xvehicle,Yvehicle,PosUpdateIndex] = addPosDelay(Xvehicle,Yvehicle,XvehicleReal,YvehicleReal,IDvehicle,indexNewVehicles,...
    indexOldVehicles,indexOldVehiclesToOld,posUpdateAllVehicles,PosUpdatePeriod)
% Update positions of vehicles in the current positioning update period
% (PosUpdatePeriod)

% Initialize temporary Xvehicle and Yvehicle
Nvehicles = length(IDvehicle);
XvehicleTemp = zeros(Nvehicles,1);
YvehicleTemp = zeros(Nvehicles,1);

% Position of new vehicles in the scenario immediately updated （将新车辆的真实坐标直接复制到临时坐标数组中）
XvehicleTemp(indexNewVehicles) = XvehicleReal(indexNewVehicles);  
YvehicleTemp(indexNewVehicles) = YvehicleReal(indexNewVehicles);

% Copy old coordinates to temporary Xvehicle and Yvehicle      （将旧车辆的坐标从当前坐标数组中复制到临时坐标数组中）
XvehicleTemp(indexOldVehicles) = Xvehicle(indexOldVehiclesToOld);
YvehicleTemp(indexOldVehicles) = Yvehicle(indexOldVehiclesToOld);
Xvehicle = XvehicleTemp;
Yvehicle = YvehicleTemp;

% Find index of vehicles in the scenario whose position will be updated
PosUpdateIndex = find(posUpdateAllVehicles(IDvehicle)==PosUpdatePeriod);

% Update positions
Xvehicle(PosUpdateIndex) = XvehicleReal(PosUpdateIndex);
Yvehicle(PosUpdateIndex) = YvehicleReal(PosUpdateIndex);

end
%%%这个函数的目的是根据不同的条件更新车辆的位置信息
