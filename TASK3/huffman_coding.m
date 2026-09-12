clc;
clear;
close all;
total_start = tic;

I = imread('clipart.jpg'); 

if size(I,3) == 3
    I_gray = rgb2gray(I);
else
    I_gray = I;
end

data = I_gray(:);

fprintf('HUFFMAN CODING -\n');
fprintf('Image size      : %d x %d\n', size(I_gray,1), size(I_gray,2));
fprintf('Number of pixels: %d\n', numel(data));
fprintf('Data type       : %s\n', class(I_gray));

% HISTOGRAM / PROBABILITY 
counts = imhist(I_gray);
symbols = (0:255)';

used = counts > 0;

symbols_used = symbols(used);
counts_used = counts(used);

probabilities = counts_used / sum(counts_used);

num_symbols = length(symbols_used);
fprintf('Unique symbols  : %d\n', num_symbols);

% ENTROPY 
entropy_value = -sum(probabilities .* log2(probabilities));

% HUFFMAN DICTIONARY
fprintf('\nCreating Huffman dictionary...\n');

dict_start = tic;
[dict, avglen] = huffmandict(symbols_used, probabilities);
dict_time = toc(dict_start);

fprintf('Dictionary creation time: %.6f seconds\n', dict_time);

% ENCODING 
fprintf('\nEncoding image...\n');

encode_start = tic;
encoded_data = huffmanenco(data, dict);
encode_time = toc(encode_start);

% DECODING
fprintf('Decoding image...\n');

decode_start = tic;
decoded_data = huffmandeco(encoded_data, dict);
decode_time = toc(decode_start);

decoded_data = uint8(decoded_data);
decoded_image = reshape(decoded_data, size(I_gray));

% CHECK
MSE = mean((double(I_gray(:)) - double(decoded_image(:))).^2);
pixel_mismatch = sum(I_gray(:) ~= decoded_image(:));
pixel_match = (1 - pixel_mismatch/numel(data)) * 100;

if isequal(I_gray, decoded_image)
    fprintf('\nDecoded image is exactly same as original grayscale image.\n');
    fprintf('Pixel match: 100%%\n');
else
    fprintf('\nDecoded image is NOT same.\n');
end

% COMPRESSION METRICS
original_bits = numel(data) * 8;
compressed_bits = length(encoded_data);

compression_ratio = original_bits / compressed_bits;
compression_percentage = (1 - compressed_bits/original_bits) * 100;

coding_efficiency = (entropy_value / avglen) * 100;
redundancy = avglen - entropy_value;

fprintf('\nCOMPRESSION RESULTS - \n');
fprintf('Entropy                : %.4f bits/pixel\n', entropy_value);
fprintf('Average code length    : %.4f bits/pixel\n', avglen);
fprintf('Coding efficiency      : %.2f %%\n', coding_efficiency);
fprintf('Redundancy             : %.4f bits/pixel\n', redundancy);
fprintf('Original size          : %d bits\n', original_bits);
fprintf('Compressed size        : %d bits\n', compressed_bits);
fprintf('Compression ratio      : %.4f : 1\n', compression_ratio);
fprintf('Compression percentage : %.2f %%\n', compression_percentage);

% TIME 
total_time = toc(total_start);
fprintf('\nTIME ANALYSIS - \n');
fprintf('Dictionary time : %.6f seconds\n', dict_time);
fprintf('Encoding time   : %.6f seconds\n', encode_time);
fprintf('Decoding time   : %.6f seconds\n', decode_time);
fprintf('Total time      : %.6f seconds\n', total_time);

% MEMORY ANALYSIS
fprintf('\nMEMORY ANALYSIS - \n');
vars = whos;
total_variable_memory = sum([vars.bytes]);
fprintf('MATLAB variable memory: %.2f MB\n', total_variable_memory / (1024^2));

% COMPLEXITY
fprintf('\nCOMPLEXITY ANALYSIS - \n');
fprintf('Histogram calculation : O(N)\n');
fprintf('Huffman tree creation : O(K log K)\n');
fprintf('Encoding              : O(N)\n');
fprintf('Decoding              : O(N)\n');
fprintf('Overall approximately : O(N + K log K)\n');
fprintf('N = number of pixels, K = number of unique symbols\n');


% CODE LENGTH FOR EACH PIXEL
code_length = zeros(256,1);

for i = 1:length(dict)
    symbol = dict{i,1};
    code = dict{i,2};
    code_length(double(symbol)+1) = length(code);
end

pixel_code_length = code_length(double(I_gray)+1);

% OUTPUT 1: ORIGINAL + DECODED
figure();

subplot(1,2,1);
imshow(I_gray);
title('Original Grayscale Image');

subplot(1,2,2);
imshow(decoded_image);
title('Huffman Decoded Image');

sgtitle('Huffman Lossless Reconstruction');

saveas(gcf,'huffman_original_vs_decoded.png');

% OUTPUT 2: BIT LENGTH MAP + LENGTH DISTRIBUTION
figure();

subplot(1,3,1);
imagesc(pixel_code_length);
axis image;
colormap(gca,'turbo');   % better contrast than default blue-heavy colormap
colorbar;
xlabel('Pixel Column');
ylabel('Pixel Row');
title(['Codeword Length Map Turbo Mode (Min: ', num2str(min(pixel_code_length(:))), ...
    ', Max: ', num2str(max(pixel_code_length(:))), ' bits)']);

subplot(1,3,2);
histogram(pixel_code_length,'BinMethod','integers');
xlabel('Codeword Length (bits)');
ylabel('Number of Pixels');
title('Codeword Length Distribution');
grid on;

subplot(1,3,3);
imagesc(pixel_code_length);
axis image;
colorbar;
xlabel('Pixel Column');
ylabel('Pixel Row');
title(['Codeword Length Map (Min: ', num2str(min(pixel_code_length(:))), ...
    ', Max: ', num2str(max(pixel_code_length(:))), ' bits)']);
sgtitle('Huffman Codeword Analysis');

saveas(gcf,'huffman_code_length_analysis.png');

% OUTPUT 3: SYMBOL FREQUENCY
figure();

bar(symbols_used, probabilities);
xlabel('Pixel Intensity');
ylabel('Probability');
title('Huffman Symbol Probability Distribution');
grid on;

saveas(gcf,'huffman_symbol_frequency.png');

% OUTPUT 4: METRICS SUMMARY 
figure();
axis off;

text(0.05,0.90,'HUFFMAN CODING - PERFORMANCE SUMMARY','FontSize',18,'FontWeight','bold');

text(0.05,0.82,['Image size: ',num2str(size(I_gray,1)),' x ',num2str(size(I_gray,2))],'FontSize',13);
text(0.05,0.77,['Number of pixels: ',num2str(numel(data))],'FontSize',13);
text(0.05,0.72,['Unique symbols: ',num2str(num_symbols)],'FontSize',13);

text(0.05,0.64,['Entropy: ',num2str(entropy_value,'%.4f'),' bits/pixel'],'FontSize',13);
text(0.05,0.59,['Average code length: ',num2str(avglen,'%.4f'),' bits/pixel'],'FontSize',13);
text(0.05,0.54,['Coding efficiency: ',num2str(coding_efficiency,'%.2f'),' %'],'FontSize',13);
text(0.05,0.49,['Redundancy: ',num2str(redundancy,'%.4f'),' bits/pixel'],'FontSize',13);

text(0.05,0.41,['Original bits: ',num2str(original_bits)],'FontSize',13);
text(0.05,0.36,['Compressed bits: ',num2str(compressed_bits)],'FontSize',13);
text(0.05,0.31,['Compression ratio: ',num2str(compression_ratio,'%.4f'),':1'],'FontSize',13);
text(0.05,0.26,['Compression: ',num2str(compression_percentage,'%.2f'),' %'],'FontSize',13);

text(0.55,0.64,['Dictionary time: ',num2str(dict_time,'%.6f'),' s'],'FontSize',12);
text(0.55,0.59,['Encoding time: ',num2str(encode_time,'%.6f'),' s'],'FontSize',12);
text(0.55,0.54,['Decoding time: ',num2str(decode_time,'%.6f'),' s'],'FontSize',12);
text(0.55,0.49,['Total time: ',num2str(total_time,'%.6f'),' s'],'FontSize',12);

text(0.55,0.41,'LOSSLESS VERIFICATION','FontSize',13,'FontWeight','bold');
text(0.55,0.36,['MSE: ',num2str(MSE,'%.4f')],'FontSize',12);
text(0.55,0.31,['Pixel mismatches: ',num2str(pixel_mismatch)],'FontSize',12);
text(0.55,0.26,['Pixel match: ',num2str(pixel_match,'%.2f'),' %'],'FontSize',12);

saveas(gcf,'huffman_metrics_summary.png');

[sorted_counts, order] = sort(counts_used,'descend');
sorted_symbols = symbols_used(order);
sorted_probabilities = probabilities(order);

N = min(15,length(sorted_symbols));

figure();
axis off;
hold on;

title_str = 'Huffman Codebook - Most Frequent Symbols';
text(0.5,0.97,title_str,'FontSize',15,'FontWeight','bold', ...
    'HorizontalAlignment','center');

colHeaders = {'Intensity','Frequency','Probability','Huffman Code','Code Length'};
colX = [0.06 0.24 0.42 0.62 0.88];   % x-position of each column

rowTop = 0.90;          % y-position of header row
rowHeight = 0.055;      % vertical spacing between rows

% Header row
for c = 1:numel(colHeaders)
    text(colX(c),rowTop,colHeaders{c},'FontWeight','bold', ...
        'FontSize',11,'HorizontalAlignment','center');
end

% Header underline
annotation('line',[0.03 0.97],[rowTop-0.03 rowTop-0.03],'LineWidth',1.2);

% Data rows
for i = 1:N
    symbol = sorted_symbols(i);
    dict_index = find(symbols_used == symbol,1);

    code = dict{dict_index,2};
    codeStr = sprintf('%d', code);

    rowY = rowTop - 0.03 - i*rowHeight;

    rowData = { ...
        num2str(double(symbol)), ...
        num2str(sorted_counts(i)), ...
        sprintf('%.4f', sorted_probabilities(i)), ...
        codeStr, ...
        num2str(length(codeStr))};

    for c = 1:numel(rowData)
        text(colX(c),rowY,rowData{c},'FontSize',10, ...
            'HorizontalAlignment','center');
    end
end

xlim([0 1]);
ylim([0 1]);
hold off;

saveas(gcf,'huffman_codebook.png');

% SAVE NUMERICAL RESULTS
results.entropy = entropy_value;
results.average_code_length = avglen;
results.coding_efficiency = coding_efficiency;
results.redundancy = redundancy;
results.original_bits = original_bits;
results.compressed_bits = compressed_bits;
results.compression_ratio = compression_ratio;
results.compression_percentage = compression_percentage;
results.dictionary_time = dict_time;
results.encoding_time = encode_time;
results.decoding_time = decode_time;
results.total_time = total_time;
results.MSE = MSE;
results.pixel_mismatch = pixel_mismatch;
results.pixel_match = pixel_match;

save('huffman_results.mat','results');