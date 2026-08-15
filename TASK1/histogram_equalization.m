clc;
clear;
close all;

I = imread('autumn.png');

I_gray = rgb2gray(I);
I_double = double(I_gray);

% number of possible intensity levels for an 8-bit image
L = 256;

% find the histogram of the grayscale image manually

% 'counts' contains the number of pixels for each intensity
[counts, ~] = imhist(I_gray);

% normalize the histogram to get the PDF; total number of pixels = numel(I_gray)
pdf = counts / numel(I_gray);

% calculate the CDF; cumsum() keeps adding the previous probabilities
cdf = cumsum(pdf);

% create new intensity mapping using CDF; round() converts the values to integer intensity levels
mapping = round((L - 1) * cdf);

% apply intensity mapping to every pixel
% +1 is used because MATLAB array indexing starts from 1, while image intensity values start from 0
I_manual = uint8(mapping(I_gray + 1));

% histogram equalization using MATLAB's built-in function
I_builtin = histeq(I_gray);


figure;

subplot(2,3,1);
imshow(I_gray);
title('Original Grayscale');

subplot(2,3,2);
imshow(I_manual);
title('Manual Equalization');

subplot(2,3,3);
imshow(I_builtin);
title('MATLAB histeq');

subplot(2,3,4);
imhist(I_gray);
title('Original Histogram');

subplot(2,3,5);
imhist(I_manual);
title('Manual Equalized Histogram');

subplot(2,3,6);
imhist(I_builtin);
title('histeq Histogram');
