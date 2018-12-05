function w = weight(T, tris, Vtx, DelTris, Pp, Nrm)

% calculate the composite weight: w = cos(theta)/d.^2

tex_h = size(T,1);
tex_w = size(T,2);
    
d_2 = Vtx(:,1).^2 + Vtx(:,2).^2 + Vtx(:,3).^2;
dmin = min(d_2);

% Get vertex weights
w_vtx = dmin * (Nrm(:,3).^2) ./ d_2;       

% Interpolate to get the weight of each pixel
w = zeros(tex_h,tex_w);
tris( DelTris,:) = []; 

for i = 1:size(tris,1)
    
    UV1 = Pp(tris(i,1),:);
    UV2 = Pp(tris(i,2),:);
    UV3 = Pp(tris(i,3),:);
    
    w1 = w_vtx(tris(i,1));
    w2 = w_vtx(tris(i,2));
    w3 = w_vtx(tris(i,3));
    
    [lamda1, lamda2, lamda3, Pos, DelPix] = getPosCoord(UV1, UV2, UV3);
    w_patch = (w1*lamda1 + w2*lamda2 + w3*lamda3).*DelPix;
    
    w(Pos(3):Pos(4),Pos(1):Pos(2)) = w(Pos(3):Pos(4),Pos(1):Pos(2)).*~DelPix + w_patch;

end

% edge weight
depth = zeros(tex_h,tex_w);

for i = 1:size(tris,1)
    
    UV1 = Pp(tris(i,1),:);
    UV2 = Pp(tris(i,2),:);
    UV3 = Pp(tris(i,3),:);
    
    d1 = d_2(tris(i,1));
    d2 = d_2(tris(i,2));
    d3 = d_2(tris(i,3));
    
    [lamda1, lamda2, lamda3, Pos, DelPix] = getPosCoord(UV1, UV2, UV3);
    w_patch = (d1*lamda1 + d2*lamda2 + d3*lamda3).*DelPix;
    
    depth(Pos(3):Pos(4),Pos(1):Pos(2)) = depth(Pos(3):Pos(4),Pos(1):Pos(2)).*~DelPix + w_patch;

end


% mask = (depth~=0);
% BW = edge(mask);
% w_border = bwdist(BW);
% bmax = max(w_border(:));
% w_border(w_border>(bmax/10)) = (bmax/2);
% w_border = w_border + 0.05*bmax;
% 
% w_border = w_border.*mask;
% border_max = max(w_border(:));
% w_border = w_border / border_max;
% w = w.*w_border;

w = repmat(w,[1 1 3]);

end