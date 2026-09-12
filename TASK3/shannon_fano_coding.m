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

fprintf('SHANNON-FANO CODING - \n');
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

dict_start = tic;

% Sort by probability, descending (this is required by the algorithm)
[sortedProb, sortOrder] = sort(probabilities, 'descend');
sortedSymbols = symbols_used(sortOrder);

codeMap = shannonFanoBuild(sortedSymbols, sortedProb);

dict_time = toc(dict_start);
fprintf('Codebook creation time: %.6f seconds\n', dict_time);

% Build a fast lookup table: codes_lookup{intensity+1} = code string
codes_lookup = cell(256,1);
for i = 1:num_symbols
    sym = symbols_used(i);
    codes_lookup{sym+1} = codeMap(double(sym));
end

%  ENCODING
fprintf('\nEncoding image...\n');
encode_start = tic;

pixelCodes = codes_lookup(double(data)+1);   % cell array, one code per pixel
bitstream = [pixelCodes{:}];                 % concatenate into one long string

encode_time = toc(encode_start);

%  DECODING
fprintf('Decoding image...\n');

decode_start = tic;

% Invert the codebook: code string -> symbol
invMap = containers.Map('KeyType','char','ValueType','double');
for i = 1:num_symbols
    sym = symbols_used(i);
    invMap(codes_lookup{sym+1}) = double(sym);
end

totalPixels = numel(data);
decoded_data = zeros(totalPixels,1,'uint8');

buffer = '';
ptr = 1;

for i = 1:length(bitstream)
    buffer = [buffer bitstream(i)]; 

    if isKey(invMap, buffer)
        decoded_data(ptr) = invMap(buffer);
        ptr = ptr + 1;
        buffer = '';

        if ptr > totalPixels
            break;
        end
    end
end

decode_time = toc(decode_start);

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
code_lengths = cellfun(@length, codes_lookup(symbols_used+1));
avglen = sum(probabilities .* code_lengths);

original_bits = numel(data) * 8;
compressed_bits = length(bitstream);

compression_ratio = original_bits / compressed_bits;
compression_percentage = (1 - compressed_bits/original_bits) * 100;

coding_efficiency = (entropy_value / avglen) * 100;
redundancy = avglen - entropy_value;

fprintf('\nCOMPRESSION RESULTS\n');
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
fprintf('\nTIME ANALYSIS\n');
fprintf('Dictionary time : %.6f seconds\n', dict_time);
fprintf('Encoding time   : %.6f seconds\n', encode_time);
fprintf('Decoding time   : %.6f seconds\n', decode_time);
fprintf('Total time      : %.6f seconds\n', total_time);
fprintf('(Note: decoding is done bit-by-bit manually, so it is slower\n');
fprintf(' than MATLAB''s built-in huffmandeco for large images.)\n');

% MEMORY ANALYSIS
fprintf('\nMEMORY ANALYSIS\n');
vars = whos;
total_variable_memory = sum([vars.bytes]);
fprintf('MATLAB variable memory: %.2f MB\n', total_variable_memory / (1024^2));

% COMPLEXITY
fprintf('\nCOMPLEXITY ANALYSIS\n');
fprintf('Histogram calculation  : O(N)\n');
fprintf('Shannon-Fano splitting : O(K log K)\n');
fprintf('Encoding               : O(N)\n');
fprintf('Decoding               : O(N) bit-level operations\n');
fprintf('Overall approximately  : O(N + K log K)\n');
fprintf('N = number of pixels, K = number of unique symbols\n');


% CODE LENGTH FOR EACH PIXEL
code_length_lut = zeros(256,1);
for i = 1:num_symbols
    sym = symbols_used(i);
    code_length_lut(sym+1) = length(codes_lookup{sym+1});
end

pixel_code_length = code_length_lut(double(I_gray)+1);

% OUTPUT 1: ORIGINAL + DECODED
figure();

subplot(1,2,1);
imshow(I_gray);
title('Original Grayscale Image');

subplot(1,2,2);
imshow(decoded_image);
title('Shannon-Fano Decoded Image');
sgtitle('Shannon-Fano Lossless Reconstruction');
saveas(gcf,'shannon_fano_original_vs_decoded.png');

% OUTPUT 2: BIT LENGTH MAP + LENGTH DISTRIBUTION
figure();

subplot(1,3,1);
imagesc(pixel_code_length);
axis image;
colormap(gca,'turbo');   % better contrast than default blue-heavy colormap
colorbar;
xlabel('Pixel Column');
ylabel('Pixel Row');
title(['Codeword Length Map Turbo Mode(Min: ', num2str(min(pixel_code_length(:))), ...
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

sgtitle('Shannon-Fano Codeword Analysis');
saveas(gcf,'shannon_fano_code_length_analysis.png');

% OUTPUT 3: SYMBOL FREQUENCY
figure();

bar(symbols_used, probabilities);
xlabel('Pixel Intensity');
ylabel('Probability');
title('Shannon-Fano Symbol Probability Distribution');
grid on;
saveas(gcf,'shannon_fano_symbol_frequency.png');

% OUTPUT 4: METRICS SUMMARY
figure();
axis off;

text(0.05,0.90,'SHANNON-FANO CODING - PERFORMANCE SUMMARY','FontSize',18,'FontWeight','bold');

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

saveas(gcf,'shannon_fano_metrics_summary.png');

%  OUTPUT 5: TOP SHANNON-FANO CODES TABLE
[sorted_counts, order] = sort(counts_used,'descend');
sorted_symbols = symbols_used(order);
sorted_probabilities = probabilities(order);

N = min(15,length(sorted_symbols));

figure();
axis off;
hold on;

text(0.5,0.97,'Shannon-Fano Codebook - Most Frequent Symbols', ...
    'FontSize',15,'FontWeight','bold','HorizontalAlignment','center');

colHeaders = {'Intensity','Frequency','Probability','Shannon-Fano Code','Code Length'};
colX = [0.06 0.24 0.42 0.62 0.88];

rowTop = 0.90;
rowHeight = 0.055;

for c = 1:numel(colHeaders)
    text(colX(c),rowTop,colHeaders{c},'FontWeight','bold', ...
        'FontSize',11,'HorizontalAlignment','center');
end

annotation('line',[0.03 0.97],[rowTop-0.03 rowTop-0.03],'LineWidth',1.2);

for i = 1:N
    sym = sorted_symbols(i);
    codeStr = codes_lookup{sym+1};

    rowY = rowTop - 0.03 - i*rowHeight;

    rowData = { ...
        num2str(double(sym)), ...
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

saveas(gcf,'shannon_fano_codebook.png');

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

save('shannon_fano_results.mat','results');

%  LOCAL FUNCTION: RECURSIVE SHANNON-FANO SPLIT
%  symbolsSorted, probsSorted must already be sorted by probability
%  in DESCENDING order. Returns a containers.Map: symbol -> code (char)

function codeMap = shannonFanoBuild(symbolsSorted, probsSorted)

    n = numel(symbolsSorted);

    if n == 1
        codeMap = containers.Map('KeyType','double','ValueType','any');
        codeMap(double(symbolsSorted(1))) = '0';
        return;
    end

    % Find the split point where cumulative probability on both
    % sides is as close to equal as possible.
    cumProb = cumsum(probsSorted);
    total = cumProb(end);

    leftSum  = cumProb(1:end-1);
    rightSum = total - leftSum;

    diffs = abs(leftSum - rightSum);
    [~, splitIdx] = min(diffs);   % splitIdx = size of left group

    leftSymbols = symbolsSorted(1:splitIdx);
    leftProbs   = probsSorted(1:splitIdx);

    rightSymbols = symbolsSorted(splitIdx+1:end);
    rightProbs   = probsSorted(splitIdx+1:end);

    leftMap  = shannonFanoBuild(leftSymbols, leftProbs);
    rightMap = shannonFanoBuild(rightSymbols, rightProbs);

    codeMap = containers.Map('KeyType','double','ValueType','any');

    lk = keys(leftMap);
    for i = 1:numel(lk)
        codeMap(lk{i}) = ['0' leftMap(lk{i})];
    end

    rk = keys(rightMap);
    for i = 1:numel(rk)
        codeMap(rk{i}) = ['1' rightMap(rk{i})];
    end
end