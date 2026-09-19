clc;
clear;
close all;

% START PERFORMANCE MEASUREMENT
total_start = tic;

% INPUT IMAGES
image_files = {'cameraman.jpg','coins.jpg'};

% PARAMETERS
% LoG parameters
sigma = 1.0;

% MATLAB LoG uses: n = ceil(3*sigma)*2 + 1
log_kernel_size = ceil(3*sigma)*2 + 1;
log_threshold = 0.03;

% DoG parameters
sigma1 = 1.0;
sigma2 = 2.0;
dog_kernel_size1 = 2*ceil(2*sigma1) + 1;
dog_kernel_size2 = 2*ceil(2*sigma2) + 1;
dog_threshold = 0.03;

% PROCESS EACH IMAGE
for img_num = 1:length(image_files)
    % READ IMAGE
    I = imread(image_files{img_num});
    % Keep original image for display
    I_original = I;

    if size(I,3) == 3
        I_gray = rgb2gray(I);
    else
        I_gray = I;
    end

    I_gray = im2double(I_gray);

    fprintf('Input Image : %s\n', image_files{img_num});
    fprintf('Image size  : %d x %d\n', ...
        size(I_gray,1),size(I_gray,2));
    fprintf('Data type   : %s\n',class(I_gray));

    % MANUAL LoG
    center = floor(log_kernel_size/2);
    [X,Y] = meshgrid(-center:center,-center:center);

    % Gaussian component
    gaussian_kernel = exp(-(X.^2 + Y.^2)/(2*sigma^2));
    gaussian_kernel = gaussian_kernel / sum(gaussian_kernel(:));

    % Laplacian of Gaussian
    log_kernel = ((X.^2 + Y.^2 - 2*sigma^2) / sigma^4) .* gaussian_kernel;
    log_kernel = log_kernel - mean(log_kernel(:));

    % Apply LoG
    manual_log_response = imfilter(I_gray, log_kernel,'replicate');

    % Displayable LoG response
    manual_log = mat2gray(abs(manual_log_response));

    % MANUAL DoG
    % Gaussian kernel 1
    center1 = floor(dog_kernel_size1/2);
    [X1,Y1] = meshgrid(-center1:center1, -center1:center1);

    gaussian1 = exp(-(X1.^2 + Y1.^2)/(2*sigma1^2));
    gaussian1 = gaussian1 / sum(gaussian1(:));

    % Gaussian kernel 2
    center2 = floor(dog_kernel_size2/2);
    [X2,Y2] = meshgrid(-center2:center2, -center2:center2);

    gaussian2 = exp(-(X2.^2 + Y2.^2)/(2*sigma2^2));
    gaussian2 = gaussian2 / sum(gaussian2(:));

    % Gaussian smoothing
    smooth1 = imfilter(I_gray, gaussian1,'replicate');
    smooth2 = imfilter(I_gray, gaussian2,'replicate');

    % Difference of Gaussians
    manual_dog_response = smooth1 - smooth2;

    % Displayable DoG response
    manual_dog = mat2gray(abs(manual_dog_response));

    % ZERO CROSSING FUNCTION - LoG
    manual_log_zero = zeros(size(manual_log_response));

    for r = 2:size(manual_log_response,1)-1
        for c = 2:size(manual_log_response,2)-1
            center_value = manual_log_response(r,c);
            neighbors = manual_log_response(r-1:r+1,c-1:c+1);

            % Convert 3x3 neighborhood to vector and remove center pixel
            neighbors = neighbors(:);
            neighbors(5) = [];
            neighbor_min = min(neighbors);
            neighbor_max = max(neighbors);

            % Check for positive-to-negative or negative-to-positive transition
            if center_value > 0
                if neighbor_min < -log_threshold
                    manual_log_zero(r,c) = 1;
                end

            elseif center_value < 0
                if neighbor_max > log_threshold
                    manual_log_zero(r,c) = 1;
                end
            end
        end
    end

    % ZERO CROSSING FUNCTION - DoG
    manual_dog_zero = zeros(size(manual_dog_response));

    for r = 2:size(manual_dog_response,1)-1
        for c = 2:size(manual_dog_response,2)-1
            center_value = manual_dog_response(r,c);
            neighbors = manual_dog_response(r-1:r+1,c-1:c+1);

            % Convert 3x3 neighborhood to vector and remove center pixel
            neighbors = neighbors(:);
            neighbors(5) = [];
            neighbor_min = min(neighbors);
            neighbor_max = max(neighbors);

            % Check for positive-to-negative or negative-to-positive transition
            if center_value > 0
                if neighbor_min < -dog_threshold
                    manual_dog_zero(r,c) = 1;
                end

            elseif center_value < 0
                if neighbor_max > dog_threshold
                    manual_dog_zero(r,c) = 1;
                end
            end
        end
    end

    % MATLAB BUILT-IN LoG
    % MATLAB LoG already performs zero-crossing detection.
    % Same sigma is explicitly supplied so that the comparison is more meaningful.
    builtin_log = edge(I_gray, 'log', log_threshold, sigma);

    % MATLAB BUILT-IN DoG
    % MATLAB does not have a direct edge(I,'dog') method.
    % Therefore Gaussian filtering is performed using MATLAB's built-in imgaussfilt function.
    builtin_smooth1 = imgaussfilt(I_gray, sigma1, 'FilterSize',dog_kernel_size1, 'Padding','replicate');
    builtin_smooth2 = imgaussfilt(I_gray, sigma2, 'FilterSize',dog_kernel_size2, 'Padding','replicate');

    % Built-in Gaussian Difference
    builtin_dog_response = builtin_smooth1 - builtin_smooth2;

    % Displayable DoG response
    builtin_dog_response_display = mat2gray(abs(builtin_dog_response));

    % ZERO CROSSING - BUILT-IN DoG RESPONSE
    builtin_dog_zero = zeros(size(builtin_dog_response));
    for r = 2:size(builtin_dog_response,1)-1
        for c = 2:size(builtin_dog_response,2)-1
            center_value = builtin_dog_response(r,c);
            neighbors = builtin_dog_response(r-1:r+1,c-1:c+1);

            % Convert 3x3 neighborhood to vector and remove center pixel
            neighbors = neighbors(:);
            neighbors(5) = [];
            neighbor_min = min(neighbors);
            neighbor_max = max(neighbors);

            % Check zero crossing
            if center_value > 0
                if neighbor_min < -dog_threshold
                    builtin_dog_zero(r,c) = 1;
                end

            elseif center_value < 0
                if neighbor_max > dog_threshold
                    builtin_dog_zero(r,c) = 1;
                end
            end
        end
    end

    fig = figure('Name','Second-Order Edge Detection', ...
        'NumberTitle','off', 'Color','w', ...
        'Units','pixels', 'Position',[80 50 1400 820]);

    annotation(fig,'textbox', [0.20 0.94 0.60 0.045], ...
        'String','Second-Order Edge Detection', ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','middle', 'FontSize',17, ...
        'FontWeight','bold', 'EdgeColor','none');

    % 1. ORIGINAL
    ax(1) = subplot(2,4,1);
    imshow(I_original);
    title('Original', 'FontSize',12, 'FontWeight','bold');

    % 2. LoG MANUAL RESPONSE
    ax(2) = subplot(2,4,2);
    imshow(manual_log);
    title('LoG - Manual Response', 'FontSize',12, 'FontWeight','bold');

    % 3. LoG ZERO CROSSING
    ax(3) = subplot(2,4,3);
    imshow(manual_log_zero);
    title('LoG - Zero Crossing', 'FontSize',12, 'FontWeight','bold');

    % 4. LoG BUILT-IN
    ax(4) = subplot(2,4,4);
    imshow(builtin_log);
    title('LoG - Built-in', 'FontSize',12, 'FontWeight','bold');

    % 5. GRAYSCALE
    ax(5) = subplot(2,4,5);
    imshow(I_gray);
    title('Grayscale', 'FontSize',12, 'FontWeight','bold');

    % 6. DoG MANUAL RESPONSE
    ax(6) = subplot(2,4,6);
    imshow(manual_dog);
    title('DoG - Manual Response', 'FontSize',12, 'FontWeight','bold');

    % 7. DoG ZERO CROSSING
    ax(7) = subplot(2,4,7);
    imshow(manual_dog_zero);
    title('DoG - Zero Crossing', 'FontSize',12, 'FontWeight','bold');

    % 8. DoG BUILT-IN FILTERING + ZERO CROSSING
    ax(8) = subplot(2,4,8);
    imshow(builtin_dog_zero);
    title('DoG - Built-in + Zero Crossing', 'FontSize',12, 'FontWeight','bold');

    % ADJUST SUBPLOT POSITIONS
    % Increase gap between title and first row
    for k = 1:4
        p = get(ax(k),'Position');
        p(2) = p(2) - 0.025;
        set(ax(k),'Position',p);
    end

    % Reduce gap between row 1 and row 2
    for k = 5:8
        p = get(ax(k),'Position');
        p(2) = p(2) + 0.035;
        set(ax(k),'Position',p);
    end

    % SAVE FIGURE
    [~, image_name, ~] = fileparts(image_files{img_num});
    output_file = ['second_order_comparison_' image_name '.png'];
    exportgraphics(gcf,output_file,'Resolution',200);
    close(fig);
end


% TOTAL EXECUTION TIME
total_time = toc(total_start);

% MEMORY ANALYSIS
vars_after = whos;
memory_after = sum([vars_after.bytes]);
memory_used = memory_after/(1024^2);

fprintf('PERFORMANCE ANALYSIS\n');
fprintf('Total execution time : %.6f seconds\n', total_time);
fprintf('MATLAB variable memory : %.4f MB\n', memory_used);

% CPU INFORMATION
try
    cpu_info = feature('numcores');
    num_cores = cpu_info.Physical;
    fprintf('CPU cores : %d\n', num_cores);
catch
    fprintf('CPU core information : Not available\n');
end

% SYSTEM RAM
try
    [user,system] = memory;
    max_array_memory_gb = user.MaxPossibleArrayBytes/(1024^3);
    available_ram_gb = user.MemAvailableAllArrays/(1024^3);

    fprintf('Available system RAM : %.2f GB\n', available_ram_gb);
    fprintf('Maximum MATLAB array memory : %.2f GB\n', max_array_memory_gb);
catch
    fprintf('System RAM information : Not available\n');
end

% TIME COMPLEXITY
fprintf('\nTime Complexity:\n');
fprintf('LoG : O(N)\n');
fprintf('DoG : O(N)\n');
fprintf('Zero Crossing : O(N)\n');
fprintf('Overall : O(N)\n');
fprintf('N = number of image pixels\n');

% MEMORY LEAKAGE INDICATOR
fprintf('\nMemory Leakage:\n');
fprintf('Memory usage reported above is the MATLAB variable memory.\n');
fprintf('A positive memory increase between repeated runs can indicate memory growth.\n');