clc;
clear;
close all;

I = imread('autumn.png');
I_gray = rgb2gray(I);
figure;

subplot(3,3,1);
imshow(I_gray);
title('Original Grayscale');

% extract and display all 8 bit planes
for k = 0:7

    % Extract the kth bit from every pixel
    bit_plane = bitget(I_gray, k + 1);

    % Display the bit plane
    subplot(3,3,k + 2);
    imshow(bit_plane, []);
    title(['Bit Plane ', num2str(k)]);
end