function [T,M]= targetTexture(Ss, N, tris, Vtx, Nrm, Pp, DelTris)

% generate target image by using PatchMatch
% Ss        - Source texture image
% N         - The number of views
% tris      - Triangle list read from stl file
% Vtx       - Vertex list read from stl file
% Nrm       - normal vector of faces and vertices
% Pp        - UV Coordinates of vertices
% DelTris	- Invalid triangular facet list

patch_w = 7;                    % patch size
L = patch_w.^2;             	% the number of pixels in one patch
a = 0.1;                        % coherence term weight
lamda = 2;                      % consistency term weight
iters = 50;                     % number of Iterations
scales = 10;                    % Multi-scale optimization series
E = zeros(scales,iters);        % energy function
cores = feature('numCores')/2;	% Use more cores for more speed
algo = 'cputiled';

% f_id = fopen(['./Log/',datestr(now,'yyyy-mm-dd HH-MM-SS'),'.txt'],'wt');      % log parameter to the log file
% fprintf(f_id,'Coherence Weight = %d\n',a);
% fprintf(f_id,'Consistency Weight = %d\n',lamda);
% fprintf(f_id,'scales = %d\n\n',scales);
% fclose(f_id);


% calculate weight w1,...,wN
Ww = cell(1,N);
for k = 1:N
    Ww{k}= weight(Ss{k}, tris, Vtx{k}, DelTris{k}, Pp{k}, Nrm{k});
end
disp('calculating weight done£¡');

Tij = cell(1,N);
wij = cell(1,N);

figure(2)
h = plot(0,E(1,1));title('Energy function')
axis([1 iters 0 0.04]);

%% Start iterative optimization
% initialize M1,...,MN, T1,...,TN
T = Ss;
M = Ss;

S = cell(1,N);
w = cell(1,N);
P = cell(1,N);
Map = cell(N,N);

% Multi-scale iterative optimization
for scale = 1:scales     

tex_h = zeros(1,N);
tex_w = zeros(1,N);
U = cell(1,N);
ann_winsize = cell(1,N);
ann_prior = cell(1,N);

for k = 1:N
    [S{k},T{k},M{k},w{k},P{k}] = scaleProcess(Ss{k},T{k},M{k},Ww{k},Pp{k},scale,8,scales);
    tex_h(k) = size(S{k},1);
    tex_w(k) = size(S{k},2);
    
    % limit the search region
    ann_winsize{k} = 0.03 * sqrt(tex_w(k) * tex_h(k)) * ones(tex_h(k),tex_w(k),2,'int32');
    ann_prior{k} = zeros(tex_h(k),tex_w(k),3,'int32');
    [nnx,nny] = meshgrid(1:tex_w(k)-patch_w+1,1:tex_h(k)-patch_w+1);
    ann_prior{k}(1:end-patch_w+1,1:end-patch_w+1,1) = nnx - 1;
    ann_prior{k}(1:end-patch_w+1,1:end-patch_w+1,2) = nny - 1;

    % calculate the number of patches for the completeness terms,
    U{k} = filter2(ones(patch_w,patch_w),ones(tex_h(k)-patch_w+1,tex_w(k)-patch_w+1),'full');	
    U{k} = repmat(U{k},1,1,3);

end

DelTris_outside = cell(1,N);
for k = 1:N
    DelTris_outside{k} = DelTrisList(P{k}, tris, tex_w(k), tex_h(k));
    DelTris{k} = DelTris{k} | DelTris_outside{k};
end

for k = 1:N
    for l = 1:N 
        Map{k,l} = immapping(S{l},P{l},P{k},DelTris{l},DelTris{k},tris);
    end
end

    % calculate the initial E2
    E2 = 0;
    for view = 1:N
        
        for j = 1:N            

                mask = repmat(Map{j,view}(:,:,3),[1 1 3]);
                Tj = votemex(T{j},Map{j,view}, [], algo, 1, [], [], [], [], double(~mask));          
                wj = votemex(w{j},Map{j,view}, [], algo, 1, [], [], [], [], double(~mask));      
                Tij{j} = im2double(Tj);
                wij{j} = im2double(wj);
        end
        
        Ec = 0;
        for j = 1:N
            Ec = Ec + wij{j}(:,:,1).*sum((Tij{j} - M{view}).^2,3);  
        end
        
        E2 = E2 + (1/N)*sum(sum(Ec));
        
    end   

disp(['Scale',num2str(scale)]);
tic
for iter = 1:iters    
         
%% Optimizing T with Fixing M
    E1 = 0; 
    for view = 1:N

        % PatchMatch
        Snn = nnmex(S{view}, T{view}, algo, patch_w, [], [], [], [], [], cores, [], [], ann_prior{view}, ann_winsize{view}); % completeness
        Tnn = nnmex(T{view}, S{view}, algo, patch_w, [], [], [], [], [], cores, [], [], ann_prior{view}, ann_winsize{view}); % coherence

        % Voting
        Similar_Term = votemex(S{view}, Tnn, Snn, algo, patch_w, [], [], a, 1-a);
        
        % Similarity_Term
        Similar_Term = im2double(Similar_Term);
        V = findV(Snn,patch_w);
        Similar_Term = (U{view}/L + a*V/L).*Similar_Term;
        
        % Consistency_Term
        Consistency_Term = zeros(tex_h(view),tex_w(view),3);
        N_sum = zeros(tex_h(view),tex_w(view),3);

        for k = 1:N
            mask = repmat(Map{k,view}(:,:,3),[1 1 3]);
            Mn = M{k};
            Mk = votemex(Mn, Map{k,view}, [], algo, 1, [], [], [], [], double(~mask));
            Consistency_Term = Consistency_Term + im2double(Mk).*double(mask); 
            count = (Mk ~= 0);
            N_sum = N_sum + count;
        end
        

        Consistency_Term = lamda * w{view} .* Consistency_Term ./ N_sum;	
        ValidPix = ~isnan(Consistency_Term);
        Consistency_Term(~ValidPix) = 0;
        
        % Combined_Terms
        T{view} = (Similar_Term + Consistency_Term) ./ (U{view}/L + a*V/L + lamda*w{view}.*double(ValidPix));
        
        % The last iteration E1
        E_BSD = (sum(sum(Snn(1:end-patch_w+1,1:end-patch_w+1,3))) + a*sum(sum(Tnn(1:end-patch_w+1,1:end-patch_w+1,3))))/L;
        E1 = E1 + E_BSD/65025;  % Pixel normalization (65025 = 255 * 255)
        
    end

    % The last iteration E
    E(scale,iter) = (E1 + lamda * E2) / (sum(tex_h.*tex_w));
    set(h,'XData',1:iter,'YData',E(scale,1:iter));
    refreshdata(h);
            
    clearvars Mn Pk Pi DelTrisk DelTrisi Similar_Term Consistency_Term mask
  
    
%% Optimizing M with Fixing T
    E2 = 0;
    for view = 1:N
        
        Tsum = zeros(tex_h(view),tex_w(view),3);
        wsum = zeros(tex_h(view),tex_w(view),3);

        for j = 1:N           

                mask = repmat(Map{j,view}(:,:,3),[1 1 3]);
                Tj = votemex(T{j},Map{j,view}, [], algo, 1, [], [], [], [], double(~mask));          
                wj = votemex(w{j},Map{j,view}, [], algo, 1, [], [], [], [], double(~mask));      
                Tj = im2double(Tj);
                wj = im2double(wj);

            Tij{j} = Tj;
            wij{j} = wj;
            Tsum = Tsum + wj.*Tj; 
            wsum = wsum + wj;
        end
        
        M{view} = Tsum ./ wsum;
        M{view}(isnan(M{view})) = 0;
        
        Ec = 0;
        for j = 1:N
            Ec = Ec + wij{j}(:,:,1).*sum((Tij{j} - M{view}).^2,3);  
        end
        
        % The current iteration E2
        E2 = E2 + (1/N)*sum(sum(Ec));
        
    end
    

    clearvars Tn Pi Pj DelTrisi DelTrisj Tsum wsum

    figure(3);
    subplot(2,3,1);imshow(T{1},[]);title('T1');
    subplot(2,3,2);imshow(T{2},[]);title('T2');
    subplot(2,3,3);imshow(T{3},[]);title('T3');
    subplot(2,3,4);imshow(M{1},[]);title(['M1£¨',num2str(tex_h(1)),'x',num2str(tex_w(1)),'£©']);
    subplot(2,3,5);imshow(M{2},[]);title(['M2£¨',num2str(tex_h(2)),'x',num2str(tex_w(2)),'£©']);
    subplot(2,3,6);imshow(M{3},[]);title(['M3£¨',num2str(tex_h(3)),'x',num2str(tex_w(3)),'£©']);
    suptitle(['Scale ',num2str(scale),' iteration ',num2str(iter)])

    drawnow 

    % condition of convergence
    if iter > 3
        if round(E(scale,iter-1),4) == round(E(scale,iter-2),4) && round(E(scale,iter),4) == round(E(scale,iter-1),4)
           break;
        end
    end

end

disp(['iterations:',num2str(iter),',elapsed time:',num2str(toc),'s']);
% iters = iters - 5;

end

