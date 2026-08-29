clc;
clear;
close all;

I = imread('autumn.png');
I_gray = rgb2gray(I);


% GLOBAL HISTOGRAM EQUALIZATION
% equalize the complete image at once
global_eq = histeq(I_gray);


% LOCAL HISTOGRAM EQUALIZATION 
% divide image into small blocks
block_size = 32;

[rows, cols] = size(I_gray);

local_eq = zeros(rows, cols, 'uint8');

for r = 1:block_size:rows
    for c = 1:block_size:cols

        % find current block boundaries
        r_end = min(r + block_size - 1, rows);
        c_end = min(c + block_size - 1, cols);

        % extract the block
        block = I_gray(r:r_end, c:c_end);

        % equalize the block separately
        block_eq = histeq(block);

        % put the block back
        local_eq(r:r_end, c:c_end) = block_eq;

    end
end


% ADAPTIVE HISTOGRAM EQUALIZATION
% enhances different local regions according to their local intensity distribution.
adaptive_eq = adapthisteq(I_gray, ...
    'NumTiles', [8 8], ...
    'ClipLimit', 1);


% CLAHE 
% CLAHE is Adaptive HE with contrast limiting.
% A smaller ClipLimit gives more controlled enhancement.
clahe = adapthisteq(I_gray, ...
    'NumTiles', [8 8], ...
    'ClipLimit', 0.01);

figure();

% Original
subplot(5,2,1);
imshow(I_gray);
title('Original Grayscale');

subplot(5,2,2);
imhist(I_gray);
title('Original Histogram');


% Global HE
subplot(5,2,3);
imshow(global_eq);
title('Global HE');

subplot(5,2,4);
imhist(global_eq);
title('Global HE Histogram');


% Local HE
subplot(5,2,5);
imshow(local_eq);
title('Local HE');

subplot(5,2,6);
imhist(local_eq);
title('Local HE Histogram');


% Adaptive HE
subplot(5,2,7);
imshow(adaptive_eq);
title('Adaptive HE');

subplot(5,2,8);
imhist(adaptive_eq);
title('Adaptive HE Histogram');


% CLAHE
subplot(5,2,9);
imshow(clahe);
title('CLAHE');

subplot(5,2,10);
imhist(clahe);
title('CLAHE Histogram');


% Save output
saveas(gcf, 'histogram_equalization_output.png');