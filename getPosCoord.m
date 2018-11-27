function [lamda1, lamda2, lamda3, Pos, DelPix] = getPosCoord(UV1, UV2, UV3)

% calculate barycentric coordinate of triangular facet, return each pixel's 
% barycentric coordinate 'lamda1'£¬'lamda2'£¬'lamda3', and upper-left triangular 
% pixel coordinates in bounding box 'Pos'.
%
% https://en.wikipedia.org/wiki/Barycentric_coordinate_system

x1 = UV1(1);    y1 = UV1(2);
x2 = UV2(1);    y2 = UV2(2);
x3 = UV3(1);    y3 = UV3(2);

maxx = ceil(max([x1 x2 x3]));
minx = floor(min([x1 x2 x3]));
maxy = ceil(max([y1 y2 y3]));
miny = floor(min([y1 y2 y3]));

Pos = [minx maxx miny maxy];
[x,y] = meshgrid(minx:maxx, miny:maxy);

T = [x1-x3 x2-x3;y1-y3 y2-y3];
detT = det(T);

lamda1 = ((y2-y3)*(x-x3) + (x3-x2)*(y-y3)) / detT;
lamda2 = ((y3-y1)*(x-x3) + (x1-x3)*(y-y3)) / detT;
lamda3 = 1 - lamda1 - lamda2;

% Find the pixel whose coordinates are non-negative and mark it as '1'
DelPix = lamda1 >= 0 & lamda2 >= 0 & lamda3 >= 0;
