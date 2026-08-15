clc;
clear;
close all;

% read the RGB image as array
I = imread('autumn.png');

% display image size and datatype
disp('Image size:');
disp(size(I));

disp('Image datatype:');
disp(class(I));


% extract the individual RGB channels
% Dimension 3 represents the colour channel
R = I(:,:,1);    % Channel 1: Red
G = I(:,:,2);    % Channel 2: Green
B = I(:,:,3);    % Channel 3: Blue


% create colour versions only for better visualisation of each channel
R_image = cat(3, R, zeros(size(R), 'uint8'), zeros(size(R), 'uint8'));
G_image = cat(3, zeros(size(G), 'uint8'), G, zeros(size(G), 'uint8'));
B_image = cat(3, zeros(size(B), 'uint8'), zeros(size(B), 'uint8'), B);


% convert RGB channels to double to avoid overflow during addition
R_d = double(R);
G_d = double(G);
B_d = double(B);


% 1. Red channel method
gray_R = R;


% 2. Green channel method (useful for example in vegetation/forest images)
gray_G = G;


% 3. Blue channel method
gray_B = B;


% 4. Average method
gray_avg = uint8((R_d + G_d + B_d) / 3);


% 5. Weighted average / luminance method
% Human vision is more sensitive to green than red and blue
gray_weighted = uint8(0.299*R_d + 0.587*G_d + 0.114*B_d);


% 6. Maximum channel method
% Selects the highest intensity among R, G and B at each pixel
gray_max = uint8(max(cat(3, R_d, G_d, B_d), [], 3));


% 7. Minimum channel method
% Selects the lowest intensity among R, G and B at each pixel
gray_min = uint8(min(cat(3, R_d, G_d, B_d), [], 3));


% 8. MATLAB built-in RGB to grayscale conversion
gray_builtin = rgb2gray(I);

figure;

subplot(3,3,1);
imshow(I);
title('Original RGB');

subplot(3,3,2);
imshow(R_image);
title('Red Channel');

subplot(3,3,3);
imshow(G_image);
title('Green Channel');

subplot(3,3,4);
imshow(B_image);
title('Blue Channel');

subplot(3,3,5);
imshow(gray_avg);
title('Average Method');

subplot(3,3,6);
imshow(gray_weighted);
title('Weighted Method');

subplot(3,3,7);
imshow(gray_max);
title('Maximum Method');

subplot(3,3,8);
imshow(gray_min);
title('Minimum Method');

subplot(3,3,9);
imshow(gray_builtin);
title('MATLAB rgb2gray');
