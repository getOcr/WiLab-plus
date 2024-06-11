function Angle_est = dbf1_angle_tdoa(PE,data);
%dbf1_angle_tdoa 2-dimension DBF algorithm for angle and tdoa estimation.
%
% DESCRIPITION
%   The dimension of data is nSC * nRx * nTx. One of nRx and nTx should be
%   1. Anticlockwise is consisent with
%   positive angles.

% Developer: Jia. Institution: PML. Date: 2021/08/06

[nSC,L] = size(data);
if L == 1
    data = permute(data, [1 3 2]);
end

RangeMax = 50; % m
data1 = data.';
freq_index = (1:12:nSC);
x_extracted = data1(:, freq_index);
x_2d = x_extracted(:);
as_range = freq_index.';
as_position = (0:L-1)';
Interval1 = 1;
theta = -65:Interval1:65;
range = 0:Interval1:RangeMax;
[Angle_tmp, R_tmp] = dbf_ang_rng(PE, x_2d, theta, range, as_range, as_position  );
Interval2 = 0.1;
theta = Angle_tmp*180/pi-Interval1 :Interval2 :Angle_tmp*180/pi+Interval1;
range = R_tmp-Interval1 :Interval2 : R_tmp+Interval1;
[Angle_est, ~] = dbf_ang_rng(PE, x_2d, theta, range, as_range, as_position  );
end

function [Angle_est, R_est] = dbf_ang_rng(PE, x_2d, theta, range, as_range, as_position  );
Spatial_spectrum =zeros(length(range), length(theta));
for i_range=1:length(range)
    for i_theta=1:length(theta)
        a = kron(exp(-1i*2*pi*as_range*PE.deltaf*range(i_range)/PE.c), ...
            exp(1i*pi*as_position*sin(theta(i_theta)/180*pi)));
        Spatial_spectrum(i_range,i_theta)=10*log(sum( abs(a' * x_2d) .^2,2) );
    end
end
 
[range_index, angle_index] = find(Spatial_spectrum == max(max(Spatial_spectrum)));
R_est = range(range_index);
Angle_est=theta(angle_index)/180*pi;
end