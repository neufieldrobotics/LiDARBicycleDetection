function [smoothPoints]=smooth3DPoints_med(points)

smoothPoints = [];
L = length(points);

if L<3
    smoothPoints = points;
elseif L<10
    polynomialOrder = 3;
elseif L>=10
    polynomialOrder = 4;
elseif L>13
    polynomialOrder = 5;
elseif L>100
    polynomialOrder = 6;
end

if isempty(smoothPoints)
    smoothPoints(:,1)=medfilt1(points(:,1),polynomialOrder);
    smoothPoints(:,2)=medfilt1(points(:,2),polynomialOrder);
    smoothPoints(:,3)=medfilt1(points(:,3),polynomialOrder);
end
end

