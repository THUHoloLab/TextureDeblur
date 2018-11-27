function [Pp,DelTris,Nrm,U] = savePp(dirPath, vtx, tris, tex_h, tex_w)

% calculate UV Coordinates

% read the calibration data 
[ R_SLR, T_SLR, fc, cc, kc, R, T ] = loadPara(dirPath);

% load calibration data with noise
load(['R_kc_noise',dirPath(end-1),'.mat'],'R','kc');

Vtx = RT_INV(vtx,R,T);
Vtx(:,[1,2]) = Vtx(:,[2,1]);
Vtx(:,3) = -Vtx(:,3);

% inverse projection to calculate UV
Pp = project2_oulu(Vtx',R_SLR,T_SLR,fc,cc,kc);
Pp = Pp';

Y = R_SLR*Vtx' + T_SLR*ones(1,size(Vtx,1));
Z = Y(3,:);
Z = Z';
U = Y';

trisZ = zeros(size(tris));
trisZ(:) = Z(tris(:));
trisZ = sum(trisZ,2);
[~,ind] = sort(trisZ);

Nrm = GetVertexNormals_Area(U, tris);

% invalid vertex and face list, '1' to be delete,'0' to be reserve
DelVtx = (Nrm(:,3)>0 | Pp(:,1)<1 | Pp(:,1)>tex_w | Pp(:,2)<1 | Pp(:,2)>tex_h);
DelTris = zeros(size(tris));
DelTris(:) = DelVtx(tris(:));
DelTris = any(DelTris,2);

% % remove occluded triangular faces
% Depth = zeros(tex_h,tex_w);
% for i = 1:size(tris,1)
%     k = ind(i);
%     if ~DelTris(k)
%         
%         UV1 = Pp(tris(k,1),:);
%         UV2 = Pp(tris(k,2),:);
%         UV3 = Pp(tris(k,3),:);
% 
%         Z1 = Z(tris(k,1));
%         Z2 = Z(tris(k,2));
%         Z3 = Z(tris(k,3));
%         
%         [lamda1, lamda2, lamda3, Pos, DelPix] = getPosCoord(UV1, UV2, UV3);
%         
%         dep_cur = (Z1*lamda1 + Z2*lamda2 + Z3*lamda3).*DelPix;
%         dep_exis =  Depth(Pos(3):Pos(4),Pos(1):Pos(2));
%         dep_overlap = dep_cur & dep_exis;
%         
%         if ~any(dep_cur(:)) || any(dep_overlap(:))
%             
%             DelTris(k) = 1;
% 
%         else
%             Depth(Pos(3):Pos(4),Pos(1):Pos(2)) = Depth(Pos(3):Pos(4),Pos(1):Pos(2)).*(~DelPix) + dep_cur.*DelPix;
%             
%         end
%         
%          
%     end
%     
% end

end
% save([dirPath,'Pp.mat'],'Pp','DelTris')