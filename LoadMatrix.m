function [M] = LoadMatrix(FileName, precision)

% load the matrix saved as binary file
% first two elements record RowsNum and ColumnsNum,the rest record matrix
% content.

fid = fopen(FileName, 'rb');

RowsNum = fread(fid, 1, 'int');
ColumnsNum = fread(fid, 1, 'int');
M = fread(fid, RowsNum*ColumnsNum, precision);
M = reshape(M, ColumnsNum, RowsNum)';

fclose(fid);
