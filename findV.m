function V = findV(Snn,patch_w)

% find the number of patches for the completeness terms

m = size(Snn,1);
n = size(Snn,2);

Tx = Snn(1:end-patch_w+1,1:end-patch_w+1,1) + 1;        
Ty = Snn(1:end-patch_w+1,1:end-patch_w+1,2) + 1;

Tv = zeros(m,n);
ind = sub2ind([m,n],Ty(:),Tx(:));
tbl = tabulate(ind);
Tv(tbl(:,1)) = tbl(:,2);

overlap_area = zeros(2*patch_w-1, 2*patch_w-1);
overlap_area(1:patch_w,1:patch_w) = 1;
V = filter2(overlap_area,Tv);
V = repmat(V,1,1,3);
