clc;
clear;
close all;

% PERFORMANCE MEASUREMENT - START
total_start = tic;


I = imread('autumn.png');
I_rgb = I;
I_gray = rgb2gray(I);


% Display image information
disp('INPUT INFORMATION -');
disp(['Image size: ', mat2str(size(I_gray))]);
disp(['Image datatype: ', class(I_gray)]);
disp(['Number of pixels: ', num2str(numel(I_gray))]);

% Haar wavelet is used for decomposition.
% DWT divides the image into four subbands:
% LL -> Approximation / low-frequency information
% LH -> Horizontal details
% HL -> Vertical details
% HH -> Diagonal details

dwt_start = tic;

[LL, LH, HL, HH] = dwt2(double(I_gray), 'haar');

dwt_time = toc(dwt_start);

% IMAGE RECONSTRUCTION
reconstruct_start = tic;
reconstructed = idwt2(LL, LH, HL, HH, 'haar');
reconstruct_time = toc(reconstruct_start);

% Convert reconstructed image to uint8
reconstructed = uint8(reconstructed);

% MEMORY INFORMATION

disp(' ');
disp('MEMORY INFORMATION -');
whos I I_gray LL LH HL HH reconstructed

figure();


subplot(2,3,1);
imshow(I_rgb);
title('Original RGB Image');

subplot(2,3,2);
imshow(I_gray);
title('Grayscale Image');

subplot(2,3,3);
imshow(LL, []);
title('LL - Approximation');

subplot(2,3,4);
imshow(LH, []);
title('LH - Horizontal Details');

subplot(2,3,5);
imshow(HL, []);
title('HL - Vertical Details');

subplot(2,3,6);
imshow(HH, []);
title('HH - Diagonal Details');

saveas(gcf, 'dwt_output.png');

figure;

subplot(1,3,1);
imshow(I_rgb);
title('Original RGB');

subplot(1,3,2);
imshow(I_gray);
title('Original Grayscale');

subplot(1,3,3);
imshow(reconstructed);
title('Reconstructed Image');


saveas(gcf, 'dwt_reconstructed_output.png');

% PERFORMANCE RESULTS

total_time = toc(total_start);

disp(' ');
disp('PERFORMANCE ANALYSIS -');

disp(['DWT Execution Time       : ', num2str(dwt_time), ' seconds']);
disp(['Reconstruction Time      : ', num2str(reconstruct_time), ' seconds']);
disp(['Total Execution Time     : ', num2str(total_time), ' seconds']);

disp(' ');
disp('Time Complexity: O(N)');
disp('where N is the number of image pixels.');

disp(' ');
disp('Memory Usage: Check the Bytes column produced by WHOS.');

disp(' ');
disp('CPU Utilisation: System-level CPU utilisation is not');
disp('measured here because MATLAB does not provide a');
disp('portable exact CPU-percentage measurement for this code.');
disp('It can be monitored using Windows Task Manager.');

disp(' ');
disp('Memory Leak Check: Run the program repeatedly and');
disp('check for abnormal increase in MATLAB memory usage.');