function [Vtx Tris] = ReadSTL(FileName, Format)

% http://en.wikipedia.org/wiki/STL_(file_format)

disp(['read ' FileName]);

if ~exist('Format','var')
    Format = 'binary';
end
    
if strcmp(Format, 'binary')
    [Vtx Tris] = ReadSTLBlock_binary(FileName);
elseif strcmp(Format, 'ascii')
    error('ASCII format is not supported yet');
else
    error([Format ' is unknown format']);
end

% remove redundant vertices
disp('unify duplicated vertices');
[Vtx, Tris] = UnifyDuplicatedVertices(Vtx, Tris);


% Read binary STL format file
function [Vtx Tris] = ReadSTLBlock_binary(FileName)

fid = fopen(FileName, 'rb');

fread(fid, 80, 'schar'); % 80 character header 
TrisNum = fread(fid, 1, 'int'); % 4 byte unsigned integer indicating the number of triangular facets in the file

Tris = zeros(TrisNum, 3);
Vtx = zeros(TrisNum*3, 3);

% Ignore the normal of face
for i = 1:TrisNum
    V = fread(fid, 12, 'float');
    
    Vtx((i-1)*3+1, :) = V(4:6);
    Vtx((i-1)*3+2, :) = V(7:9);
    Vtx((i-1)*3+3, :) = V(10:12);
    Tris(i,:) = [ (i-1)*3+1 (i-1)*3+2 (i-1)*3+3 ];
    
    fread(fid, 2, 'schar'); % attribute byte count
end

fclose(fid);


