%function nnfield=nnmex(A, B, [algo='cpu'], [patch_w=7], [nn_iters=5], [rs_max=100000], [rs_min=1], [rs_ratio=0.5], [rs_iters=1.0], [cores=2], ...
% [win_size=[INT_MAX INT_MAX]], [nnfield_prev=[]], [nnfield_prior=[]], [prior_winsize=[]])
%
%Input signals A, B, are 3D arrays of size either hxwx3 (image mode) or hxwxn (descriptor mode).
%  In image mode, the input images are broken up into overlapping patches of size patch_w x patch_w
%    (allowed data types: uint8, or floats in [0, 1], which are quantized).
%  In descriptor mode, the inputs have an n dimensional descriptor at each (x, y) coordinate
%    (allowed data types: uint8, or floats of any range, which are not quantized).
%
%Returns NN field (hxwx3, int32) mapping A -> B.
%Channel 1 is x coord, channel 2 is y coord, channel 3 is squared L2 distance.
% (In descriptor mode with float input, the output NN field is also a float, to avoid overflow.)
%
%Options are:
%algo x      - One of 'cpu', 'gpucpu', 'cputiled'
%patch_w p   - Width (and height) of patch.
%nn_iters n  - Iters of randomized NN algo
%rs_max w    - Maximum width for RS
%rs_min w    - Minimum width for RS
%rs_ratio r  - Ratio (< 1) of successive RS sizes
%rs_iters n  - Iters (double precision) of RS algorithm
%cores n     - Cores to run GPU-CPU algorithm on
%win_size [w h] - size of search window [2*h+1 x 2*w+1] arround the input pixel location 
%				(interpolated linearly to the output coordinates in case of different
%				sizes). Slower but allows to limit the search space locally.
%nnfield_prev- (hxwx3, double) initial mapping A -> B. The final result is
%				the minimum distance between initial mapping and random initialization + a
%				few final iterations. The squared distance channel in nnfield_prev is not used.
%nnfield_prior - (hxwx2) field that constrains the search in a local window around the locations in B defined by the ann_window field.
%prior_winsize - (hxwx2) array matching ann_window that defines localy the window size - first channel for window width, second channel for the hight.
%
%------------------------------------------------------------------------%
% Copyright 2008-2009 Adobe Systems Inc., for noncommercial use only.
% Citation:
%   Connelly Barnes, Eli Shechtman, Adam Finkelstein, and Dan B Goldman.
%   PatchMatch: A Randomized Correspondence Algorithm for Structural Image
%   Editing. ACM Transactions on Graphics (Proc. SIGGRAPH), 28(3), 2009
%   http://www.cs.princeton.edu/gfx/pubs/Barnes_2009_PAR/
% Main contact: csbarnes@cs.princeton.edu  (Connelly)
% Version: 1.0, 21-June-2008
%------------------------------------------------------------------------%

