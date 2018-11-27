function [Vtx Tris] = UnifyDuplicatedVertices(Vtx, Tris)

% % 将X排序，按次序判断冗余
% [Y, SortIdx] = sort(Vtx(:,1));
% 
% VtxIdxMap = zeros(size(Vtx,1),1);
% VtxOld = Vtx;
% 
% Vtx(1,:) = VtxOld(SortIdx(1),:);
% VtxIdxMap(SortIdx(1)) = 1;
% Index = 1;
% for i = 2:size(SortIdx,1)
%     for j = Index : -1 : 1
%         if VtxOld(SortIdx(i),1) ~= Vtx(j,1)
%             Index = Index + 1; 
%             Vtx(Index,:) = VtxOld(SortIdx(i),:);
%             break;
%         end
%         if VtxOld(SortIdx(i),1) == Vtx(j,1) && ...
%            VtxOld(SortIdx(i),2) == Vtx(j,2) && ...
%            VtxOld(SortIdx(i),3) == Vtx(j,3)
%             break;
%         end        
%     end
%     VtxIdxMap(SortIdx(i)) = Index;
% end
% Vtx = Vtx(1:Index,:);
% 
% for i = 1:size(Tris,1)
%     Tris(i,:) = [ VtxIdxMap(Tris(i,1)) VtxIdxMap(Tris(i,2)) VtxIdxMap(Tris(i,3)) ];
% end

% 分块计算去除冗余
VtxNum = size(Vtx,1);
[Vtx Index VtxIdx] = Unify_cube(zeros(VtxNum,3), 0, zeros(VtxNum,1), Vtx, (1:VtxNum)');
Vtx = Vtx(1:Index,:);
for i = 1:size(Tris,1)
    Tris(i,:) = [ VtxIdx(Tris(i,1)) VtxIdx(Tris(i,2)) VtxIdx(Tris(i,3)) ];
end

% % 直接计算去除冗余
% [Vtx Tris] = UnifyDuplicatedVertices_simple(Vtx, Tris);


function [GlobalVtx GlobalIndex GlobalVtxIdx] = Unify_cube(GlobalVtx, GlobalIndex, GlobalVtxIdx, Vtx, VtxIdx)

if size(Vtx,1) < 300
    Start = GlobalIndex+1;
    for i = 1:size(Vtx,1)
        a = 0;
        for j = Start : GlobalIndex
            if sum(Vtx(i,:) == GlobalVtx(j,:)) == 3
                a = j;
                break;
            end
        end
        if a == 0
            GlobalIndex = GlobalIndex + 1;
            GlobalVtx(GlobalIndex,:) = Vtx(i,:);
            GlobalVtxIdx(VtxIdx(i)) = GlobalIndex;
        else
            GlobalVtxIdx(VtxIdx(i)) = a;
        end
    end
    return;
end

Border = [ min(Vtx(:,1)) , max(Vtx(:,1)) ;
           min(Vtx(:,2)) , max(Vtx(:,2)) ;
           min(Vtx(:,3)) , max(Vtx(:,3)) ] ;

Length = [ Border(1,2) - Border(1,1) , ...
           Border(2,2) - Border(2,1) , ...
           Border(3,2) - Border(3,1) ] ;

[C Direction] = max( Length );
MeanBorder = Border(Direction,1) + Length(Direction)/2;

Border1 = Border;
Border1(Direction,:) = [ Border(Direction,1) , MeanBorder ];
Border2 = Border;
Border2(Direction,:) = [ MeanBorder , Border(Direction,2) ];

Index1 = 0;
Index2 = 0;
PerSectNum1 = 100000; % 分段读入时每段读入的个数
PrepTotalNum1 = PerSectNum1; % 已申请的总数
Vtx1 = zeros(PrepTotalNum1, 3);
VtxIdx1 = zeros(PrepTotalNum1, 1);
PerSectNum2 = 100000; % 分段读入时每段读入的个数
PrepTotalNum2 = PerSectNum2; % 已申请的总数
Vtx2 = zeros(PrepTotalNum2, 3);
VtxIdx2 = zeros(PrepTotalNum2, 1);
for i = 1:size(Vtx,1)
    if Vtx(i,Direction) <= MeanBorder
        if PrepTotalNum1 == Index1
            PrepTotalNum1 = PrepTotalNum1 + PerSectNum1;
            Vtx1(Index1+1:PrepTotalNum1, :) = zeros(PerSectNum1, 3);
            VtxIdx1(Index1+1:PrepTotalNum1, :) = zeros(PerSectNum1, 1);
        end
        
        Index1 = Index1 + 1;
        Vtx1(Index1,:) = Vtx(i,:);
        VtxIdx1(Index1,:) = VtxIdx(i,:);
    else
        if PrepTotalNum2 == Index2
            PrepTotalNum2 = PrepTotalNum2 + PerSectNum2;
            Vtx2(Index2+1:PrepTotalNum2, :) = zeros(PerSectNum2, 3);
            VtxIdx2(Index2+1:PrepTotalNum2, :) = zeros(PerSectNum2, 1);
        end        
        
        Index2 = Index2 + 1;
        Vtx2(Index2,:) = Vtx(i,:);
        VtxIdx2(Index2,:) = VtxIdx(i,:);
    end
end
Vtx1 = Vtx1(1:Index1, :);
VtxIdx1 = VtxIdx1(1:Index1, :);
Vtx2 = Vtx2(1:Index2, :);
VtxIdx2 = VtxIdx2(1:Index2, :);
if Index1 > 0
    [GlobalVtx GlobalIndex GlobalVtxIdx] = Unify_cube(GlobalVtx, GlobalIndex, GlobalVtxIdx, Vtx1, VtxIdx1);
end
if Index2 > 0
    [GlobalVtx GlobalIndex GlobalVtxIdx] = Unify_cube(GlobalVtx, GlobalIndex, GlobalVtxIdx, Vtx2, VtxIdx2);
end


function [Vtx Tris] = UnifyDuplicatedVertices_simple(Vtx, Tris)
% 直接计算去除冗余
VtxIdx = 1:size(Vtx,1);
VtxOld = Vtx;
Index = 0;
for i = 1:size(VtxOld,1)
    a = 0;
    for j = 1:Index
        if sum(VtxOld(i,:) == Vtx(j,:)) == 3
            a = j;
            break;
        end
    end
    if a == 0
        Index = Index + 1;
        Vtx(Index,:) = VtxOld(i,:);
        VtxIdx(i) = Index;
    else
        VtxIdx(i) = a;
    end
end
Vtx = Vtx(1:Index,:);

for i = 1:size(Tris,1)
    Tris(i,:) = [ VtxIdx(Tris(i,1)) VtxIdx(Tris(i,2)) VtxIdx(Tris(i,3)) ];
end