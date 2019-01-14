function triangle_area = triangle_Area(P1,P2,P3)
% Calculate the area of a triangle
L1 = sqrt(sum((P1(:) - P2(:)).^2));
L2 = sqrt(sum((P2(:) - P3(:)).^2));
L3 = sqrt(sum((P3(:) - P1(:)).^2));
S = (L1+L2+L3)/2;
triangle_area = sqrt(S*(S-L1)*(S-L2)*(S-L3));