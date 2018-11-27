function Nrm = GetVertexNormals_Area(Vtx, Tris)

% Calculates the normal vector of faces and vertices

VtxNum = size(Vtx,1);
TrisNum = size(Tris,1);

Nrm = zeros(VtxNum,3);
Area = zeros(VtxNum,1);
TriNrm = zeros(TrisNum,3);


for i = 1:TrisNum
    TriNrm(i,:) = cross( Vtx(Tris(i,1),:) - Vtx(Tris(i,3),:) , ...
                         Vtx(Tris(i,2),:) - Vtx(Tris(i,3),:) );
    A = norm(TriNrm(i,:)); if A ~= 0, TriNrm(i,:) = TriNrm(i,:) / A; end % uniformization
    triangle_area = triangle_Area(Vtx(Tris(i,1),:),Vtx(Tris(i,2),:),Vtx(Tris(i,3),:));
    Area(Tris(i,1)) = Area(Tris(i,1)) + triangle_area;  
    Area(Tris(i,2)) = Area(Tris(i,2)) + triangle_area; 
    Area(Tris(i,3)) = Area(Tris(i,3)) + triangle_area; 
    Nrm(Tris(i,1),:) = Nrm(Tris(i,1),:) + TriNrm(i,:).*triangle_area;
    Nrm(Tris(i,2),:) = Nrm(Tris(i,2),:) + TriNrm(i,:).*triangle_area;
    Nrm(Tris(i,3),:) = Nrm(Tris(i,3),:) + TriNrm(i,:).*triangle_area;      

end

for i = 1:VtxNum
    if Area(i) ~= 0 
       Nrm(i,:) = Nrm(i,:) ./ Area(i);
    end
    A = norm(Nrm(i,:));
    if A ~= 0
       Nrm(i,:) = Nrm(i,:) / A;
    end
end
