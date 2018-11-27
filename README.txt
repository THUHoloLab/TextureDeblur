This matlab code is used for eliminating artifacts like blurring, ghosting and color discontinuity in texture image of 3-D measurements.

1. Run the start, the algorithm will be unsupervised performed and generate optimized texture images saved in '.\image'.

2. Description of the functions

targetTexture.m	- texture image optimization function
savePp.m		- texture mappingng to obtain UV coordinates
immapping.m	- pixel remapping function, which implement image projection between different view.
weight.m		- weight calculation function
nnmex.mexw64 / votemex.mexw64	- PatchMatch algorithm proposed by Barnes et al.  It is a compiled machine code for a Windows 64-bit setup. see more details in nnmex.m and votemex.m
Others are helper functions.