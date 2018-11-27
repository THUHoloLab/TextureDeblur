function [S, T, M, w, Pp] = scaleProcess(varargin)

% % Scale source image, target image, etc

% default scale is 10
if nargin < 9
    
    scales = 10;    
    if nargin < 7
        times = 5;
    else
        times = varargin{7};
    end
else
    scales = varargin{8};
    times = varargin{7};
end  

S0 = varargin{1};
T0 = varargin{2};
M0 = varargin{3};
w0 = varargin{4};
Pp0 = varargin{5};
scale = varargin{6};
    
size_h = size(S0,1);
size_w = size(S0,2);
h = size_h / times;
w = size_w / times;

rows = round(h * times ^ ((scale - 1) / (scales - 1)));    
cols = round(w * times ^ ((scale - 1) / (scales - 1)));


if ~isempty(S0)
    S = imresize(S0, [rows cols],'nearest');
else
    S = [];
end

if ~isempty(T0)
    T = imresize(T0, [rows cols],'nearest');
else
    T = [];
end

if ~isempty(M0)
    M = imresize(M0, [rows cols],'nearest');
else
    M = [];
end

if ~isempty(w0)
    w = imresize(w0, [rows cols],'nearest');
else
    w = [];
end

if ~isempty(Pp0)
    Pp(:,1) = ( cols / size_w ) * (Pp0(:,1) - 0.5) + 0.5;
    Pp(:,2) = ( rows / size_h ) * (Pp0(:,2) - 0.5) + 0.5;
else
    Pp = [];
end

end
