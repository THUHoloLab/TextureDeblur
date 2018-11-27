function Map = immapping(I1,Pp1,Pp2,DelTris1,DelTris2,tris)

% view 2 project to view 1, return I1 -> I2 mapping coordinates
% Channel 1 is x-coordinate, channel 2 is y-coordinate, channel 3 label valid pixel.

Map = zeros(size(I1),'int32');
tris( DelTris1 | DelTris2,:) = [];      % delete the row marked as '1' in the triangle list

for i = 1:size(tris,1)
    
    I1_UV1 = Pp1(tris(i,1),:);
    I1_UV2 = Pp1(tris(i,2),:);
    I1_UV3 = Pp1(tris(i,3),:);
    [lamda1, lamda2, lamda3, Pos, DelPix] = getPosCoord(I1_UV1, I1_UV2, I1_UV3);

    I2_UV1 = Pp2(tris(i,1),:);
    I2_UV2 = Pp2(tris(i,2),:);
    I2_UV3 = Pp2(tris(i,3),:);
    
    x = I2_UV1(1)*lamda1 + I2_UV2(1)*lamda2 + I2_UV3(1)*lamda3;
    y = I2_UV1(2)*lamda1 + I2_UV2(2)*lamda2 + I2_UV3(2)*lamda3;
    x = int32(x.*DelPix) - 1;
    y = int32(y.*DelPix) - 1;
    
        Map(Pos(3):Pos(4),Pos(1):Pos(2),1) = Map(Pos(3):Pos(4),Pos(1):Pos(2),1).*int32(~DelPix) + x.*int32(DelPix);
        Map(Pos(3):Pos(4),Pos(1):Pos(2),2) = Map(Pos(3):Pos(4),Pos(1):Pos(2),2).*int32(~DelPix) + y.*int32(DelPix);
        Map(Pos(3):Pos(4),Pos(1):Pos(2),3) = Map(Pos(3):Pos(4),Pos(1):Pos(2),3) | DelPix;

end
