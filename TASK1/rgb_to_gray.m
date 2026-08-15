clc;
clear;
close all;

% read image as array
I = imread('autumn.png');


disp('Image size:');
disp(size(I));
disp('Image datatype:');
disp(class(I));


% extract the individual RGB channels
R = I(:,:,1);    % Dimension 3, channel 1: Red
G = I(:,:,2);    % Dimension 3, channel 2: Green
B = I(:,:,3);    % Dimension 3, channel 3: Blue


% convert the RGB image into a grayscale image
I_gray = rgb2gray(I);

figure;

subplot(2,3,1);
imshow(I);
title('Original RGB Image');

subplot(2,3,2);
imshow(R);
title('Red Channel');

subplot(2,3,3);
imshow(G);
title('Green Channel');

subplot(2,3,4);
imshow(B);
title('Blue Channel');

subplot(2,3,5);
imshow(I_gray);
title('Grayscale Image');
clc;
clear;
close all;

% read image as array
I = imread('autumn.png');

% display image size and datatype
disp('Image size:');
disp(size(I));

disp('Image datatype:');
disp(class(I));


% extract the individual RGB channels
R = I(:,:,1);    % Dimension 3, channel 1: Red
G = I(:,:,2);    % Dimension 3, channel 2: Green
B = I(:,:,3);    % Dimension 3, channel 3: Blue


% convert to double to avoid overflow while adding pixel values
R_d = double(R);
G_d = double(G);
B_d = double(B);


% 1. Red channel method (Useful when red-channel info is important)
gray_R = R;

% 2. Green channel method (Useful for vegetation/forest analysis)
gray_G = G;

% 3. Blue channel method (Useful when blue-channel info is important)
gray_B = B;


% 4. Average method
gray_avg = uint8((R_d + G_d + B_d) / 3);


% 5. Weighted average / luminance method
% Human vision is more sensitive to green than red and blue
gray_weighted = uint8(0.299*R_d + 0.587*G_d + 0.114*B_d);


% 6. Maximum channel method (Uses the strongest intensity among the three channels)
gray_max = uint8(max(cat(3,R_d,G_d,B_d), [], 3));


% 7. Minimum channel method (Uses the lowest intensity among the three channels)
gray_min = uint8(min(cat(3,R_d,G_d,B_d), [], 3));


% 8. MATLAB built-in grayscale conversion
gray_builtin = rgb2gray(I);

figure;

subplot(3,3,1);
imshow(I);
title('Original RGB');

subplot(3,3,2);
imshow(gray_R);
title('Red Channel');

subplot(3,3,3);
imshow(gray_G);
title('Green Channel');

subplot(3,3,4);
imshow(gray_B);
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
