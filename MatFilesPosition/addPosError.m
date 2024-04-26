function [Xvehicle, Yvehicle] = addPosError(XvehicleReal,YvehicleReal,sigma)
% Add positioning error based on the Gaussian model

Nvehicles = length(XvehicleReal(:,1));
error = sigma.*randn(Nvehicles,1);               % Generate error samples(生成一个长度为 Nvehicles 的随机误差向量，其中每个误差值都是从均值为零、标准差为 sigma 的正态分布中生成的)
angle = 2*pi.*rand(Nvehicles,1);                 % Generate random angles(生成一个长度为 Nvehicles 的随机角度向量，其中每个角度都是在 [0, 2*pi) 范围内均匀分布的)

Xvehicle = (XvehicleReal + error.*cos(angle));
Yvehicle = (YvehicleReal + error.*sin(angle));

end

%%%%%%%这个函数的目的是模拟实际定位系统中由于各种原因引起的误差，通过在车辆的真实位置上添加随机的定位误差。使用生成的误差和角度，按照极坐标到直角坐标的转换，将定位误差添加到真实的车辆坐标中。