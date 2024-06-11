function plotLayout(sysPar,data);
%plotLayout Display BSs and UEs layout.
figure;
BSPos = sysPar.BSPos;
UEPos = sysPar.UEPos;
plot3( BSPos(1,:), BSPos(2,:), BSPos(3,:),'ro','MarkerSize',7);
hold on;grid on;axis equal;
str = strcat('reference UE ',num2str( (1: sysPar.nBS).' ) );
text( BSPos(1,:)-0.5, BSPos(2,:)+1.5, BSPos(3,:)+1.5, str);
plot3( UEPos(1,:), UEPos(2,:), UEPos(3,:),'bx','MarkerSize',7);
str = strcat('target UE ',num2str( (1: sysPar.nUE).' ) );
text( UEPos(1,:)-0.5, UEPos(2,:)+1.5, UEPos(3,:)+1.5, str);
pos = [ BSPos, UEPos];
axismax = max(pos,[],2) + [10;10;1]; 
axismin = min(pos,[],2) - [10;10;2];
edge = [axismin, axismax].';
axis(edge(:));
xlabel('x-axis / m');ylabel('y-axis / m');
zlabel('z-axis / m');
title('System Layout');
hl=legend('reference UE','target UE',...
    'Location','NorthEast');
set(hl,'edgecolor','k','FontSize',11);
set(gca,'FontSize',11);
end