function [smoothPoints]=smooth3DPoints_sgolay(points)

smoothPoints = [];
L = length(points);

if L<3
    smoothPoints = points;
elseif L<5
    windowWidth = 3;
    polynomialOrder = 1;
elseif L<11
    windowWidth = 5;
    polynomialOrder = 2;
else
    windowWidth = 11;
    polynomialOrder = 3;    
end

% elseif L<10
%     windowWidth = 3;
%     polynomialOrder = 1;
% elseif L>=10
%     windowWidth = ceil(L*0.3);
%     polynomialOrder = 1;
% elseif L>13
%     windowWidth = ceil(L*0.3);
%     polynomialOrder = 1;
% elseif L>100
%     windowWidth = 30;
%     polynomialOrder = 1;
% end
%
% if mod(windowWidth,2) == 0
%     windowWidth = windowWidth - 1;
% end

if isempty(smoothPoints)
    smoothPoints(:,1)=sgolayfilt(points(:,1),polynomialOrder, windowWidth);
    smoothPoints(:,2)=sgolayfilt(points(:,2),polynomialOrder, windowWidth);
    smoothPoints(:,3)=sgolayfilt(points(:,3),polynomialOrder, windowWidth);
end
end

