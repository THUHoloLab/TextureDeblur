function [ VertexListOut ] = RT_INV( VertexListIn, R, T )
% VertexListOut = VertexListIn;

tx = VertexListIn(:,1) - T(1);
ty = VertexListIn(:,2) - T(2);
tz = VertexListIn(:,3) - T(3);
VertexListOut = [tx ty tz] * R;




