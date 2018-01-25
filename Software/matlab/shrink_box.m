function [box]=shrink_box(pts,box)

if min(pts(:,1))>box(1)
%     keyboard;
    box(1) = min(pts(:,1));
end
if max(pts(:,1))<box(2)
%     keyboard;
    box(2) = max(pts(:,1));
end
if min(pts(:,2))>box(3)
%     keyboard;
    box(3) = min(pts(:,2));
end
if max(pts(:,2))<box(4)
%     keyboard;
    box(4) = max(pts(:,2));
end
if min(pts(:,3))>box(5)
%     keyboard;
    box(5) = min(pts(:,3));
end
if max(pts(:,3))<box(6)
%     keyboard;
    box(6) = max(pts(:,3));
end

end