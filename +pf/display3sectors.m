function display3sectors( BSpos, BSorients, ISD)
%display3sectors Display 3-sector layout
% BSpositions     3* nBS     [x;y;z]
% BSorientations  1*nBS  angles pi
% BSpositions = [11 21 31 41 51 61; 11 11 11 21 21 21; 3 3 3 3 3 3];
% BSorientations = zeros(1,6);
% ISD =5;
[~,nBS] = size(BSpos);

% for nb = 1 : nBS
%     
theta1 = pi/3 + BSorients;
theta2 = pi + BSorients;
theta3 = -pi/3 + BSorients;
rho = ISD*ones(1,nBS);
[x1,y1] = pol2cart(theta1, rho);
[x2,y2] = pol2cart(theta2, rho);
[x3,y3] = pol2cart(theta3, rho);
x_1 = x1 + BSpos(1, :);
y_1 = y1 + BSpos(2, :);
x_2 = x2 + BSpos(1, :);
y_2 = y2 + BSpos(2, :);
x_3 = x3 + BSpos(1, :);
y_3 = y3 + BSpos(2, :);
for nb = 1 : nBS
   p = plot( [ BSpos(1, nb) x_1(nb)], [ BSpos(2, nb) y_1(nb)], ...
       [ BSpos(1,nb) x_2(nb) ], [ BSpos(2,nb) y_2(nb)], [BSpos(1,nb) x_3(nb)],...
       [BSpos(2,nb) y_3(nb)]);
    p(1).Color = 'red'; p(1).LineWidth = 0.7; p(2).Color = 'red';
    p(2).LineWidth = 0.7; p(3).Color = 'red'; p(3).LineWidth = 0.7;
    hold on;
end
    