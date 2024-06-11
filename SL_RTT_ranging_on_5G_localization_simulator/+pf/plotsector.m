function plotsector(sysPar)
%PLOTSECTOR Plot single sector layout
% BSpositions     3* nBS     [x;y;z]
% BSorientations  1*nBS  angles pi
BSpositions = sysPar.BSPos;
BSorientations = sysPar.BSorientation;
[~,nBS] = size(BSpositions);   
theta1 = pi/3 *(-1 :0.1 :1)' +BSorientations;
rho1 = 7*ones(1, nBS);
[x1, y1] = pol2cart( theta1, rho1);
x1 = x1 + BSpositions(1,:);
x1(22,:) = BSpositions(1,:);
x1(23,:) = x1(1,:);
y1 = y1 + BSpositions(2,:);
y1(22,:) = BSpositions(2,:);
y1(23,:) = y1(1,:);
z1 = zeros(23, nBS) + BSpositions(3, :);
h = fill3(x1,y1,z1,[191 239 255]/256);
set(h,'handlevisibility','off');
h2 = plot3(x1,y1,z1,'Color',[131 139 131]/256,'LineWidth',0.5);
set(h2,'handlevisibility','off');
end
    