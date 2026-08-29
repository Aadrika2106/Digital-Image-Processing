clc;
clear;
close all;

cover = imread('cover.jpg');

watermark = imread('watermark.jpg');

% make sure both images are RGB
if size(cover,3) == 1
    cover = cat(3,cover,cover,cover);
end

if size(watermark,3) == 1
    watermark = cat(3,watermark,watermark,watermark);
end

% resize watermark
watermark = imresize(watermark,[size(cover,1),size(cover,2)]);


% WATERMARKING 

% transparency of watermark
alpha = 0.3;

% convert to double for blending
cover_double = im2double(cover);
watermark_double = im2double(watermark);

% create watermarked image
watermarked = (1-alpha)*cover_double + alpha*watermark_double;

% convert back to uint8
watermarked = im2uint8(watermarked);

figure();

subplot(2,2,1);
imshow(cover);
title('Original Cover Image');

subplot(2,2,2);
imshow(watermark);
title('Watermark Image');

subplot(2,2,3);
imshow(watermarked);
title('Watermarked Image');

imwrite(watermarked,'watermarked_image.png');
saveas(gcf,'watermarking_output.png');
