function [R,T] = LoadAlignMatrix_from_imalign(FileName)

M = importdata(FileName);

R = M.data(1:3, 1:3);
T = M.data(1:3, 4);
