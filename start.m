clearvars; clc; close all

% Unsupervised texture reconstruction method using bidirectional similarity function for 3-D measurements

N = 3;                  % the number of views
dirPath = '.\data\';	

% load source texture images
I = cell(1,N);
for k = 1:N
    
    I{k}=im2double(imread([dirPath, num2str(k),'\',num2str(k),'A.rocD.jpg']));
end
disp('loading texture image done£¡');

tex_h = size(I{1},1);
tex_w = size(I{1},2);

% load stl file
[vtx, tris] = ReadSTL([dirPath 'porcelain.stl'], 'binary');

Pp = cell(1,N);
DelTris = cell(1,N);
Nrm = cell(1,N);
Vtx = cell(1,N);

% calculate UV Coordinates
for k = 1:N
    [Pp{k}, DelTris{k}, Nrm{k}, Vtx{k}] = savePp([dirPath, num2str(k),'\'], vtx, tris, tex_h, tex_w);
end
disp('calculating UV Coordinates done£¡');

Ss = I;

% select the area to be optimized 
pos = [2120,948,985,959];   

% label triangular faces of the selected area
DelVtx = (Pp{3}(:,1)<pos(1) | Pp{3}(:,1)>pos(1)+pos(3)-1 | Pp{3}(:,2)<pos(2) | Pp{3}(:,2)>pos(2)+pos(4)-1);
DelTris_Common = zeros(size(tris));
DelTris_Common(:) = DelVtx(tris(:));
DelTris_Common = any(DelTris_Common,2);

ValidTris = cell(1,N);
ValidPp = cell(1,N);
for k = 1:N
    DelTris{k} = DelTris_Common | DelTris{k};
    ValidTris{k} = tris;
    ValidTris{k}(DelTris{k},:) = [];
    ValidPp{k} = Pp{k}(ValidTris{k}(:),:);
end


% crop the selected area
Map = cell(N,N);
mask = cell(1,N);
row_start = zeros(1,N);
row_end = zeros(1,N);
col_start = zeros(1,N);
col_end = zeros(1,N);
for k = 1:N           
    Map{k,k} = immapping(Ss{k},Pp{k},Pp{k},DelTris{k},DelTris{k},tris);
    
    row_start(k) = floor(min(ValidPp{k}(:,2)));
    row_end(k) = ceil(max(ValidPp{k}(:,2)));
    col_start(k) = floor(min(ValidPp{k}(:,1)));
    col_end(k) = ceil(max(ValidPp{k}(:,1)));
        
    mask{k} = double(repmat(Map{k,k}(:,:,3),[1 1 3]));
    Ss{k} = Ss{k}.*mask{k};
end

for k = 1:N
    Ss{k} = I{k}(row_start(k):row_end(k), col_start(k):col_end(k),:); 
    Pp{k}(:,2) = Pp{k}(:,2) - row_start(k) + 1; 
    Pp{k}(:,1) = Pp{k}(:,1) - col_start(k) + 1;     
end

% texture optimization algorithm
[T,M] = targetTexture(Ss, N, tris, Vtx, Nrm, Pp, DelTris);

% save target texture images
Imod = I;
for k = 1:N
    Imod{k}(row_start(k):row_end(k), col_start(k):col_end(k),:) = T{k};
    Imod{k} = I{k}.*double(~mask{k}) + Imod{k}.*double(mask{k});
    imwrite(Imod{k},['.\image\',char(k+64),'.rocD.mod.jpg'])
end