
function [ R_SLR, T_SLR, fc, cc, kc, R, T ] = loadPara(dirPath)
    KK_right_l2m = LoadMatrix([dirPath 'kk_right'],'double');
    kc = LoadMatrix([dirPath 'kc_right'],'double');
    R_SLR = LoadMatrix([dirPath 'D_R'],'double');
    T_SLR = LoadMatrix([dirPath 'D_T'],'double');

    KK_right_l2m(1,3) = KK_right_l2m(1,3)+1;
    KK_right_l2m(2,3) = KK_right_l2m(2,3)+1;

    fc = [ KK_right_l2m(1,1);KK_right_l2m(2,2) ];
    cc = [ KK_right_l2m(1,3);KK_right_l2m(2,3) ];
    
   [R, T] =  LoadAlignMatrix_from_imalign([dirPath 'RT.txt']);
end

