clc;
clear;
close all;

% START PERFORMANCE MEASUREMENT
total_start = tic;

% INPUT IMAGES
image_files = {'cameraman.jpg','coins.jpg'};

% PROCESS EACH IMAGE
for img_num = 1:length(image_files)
    % READ IMAGE
    I = imread(image_files{img_num});
    % Keep original image for display
    I_original = I;
    % Convert to grayscale
    if size(I,3) == 3
        I_gray = rgb2gray(I);
    else
        I_gray = I;
    end
    I_gray = im2double(I_gray);
   
    fprintf('Input Image : %s\n', image_files{img_num});
    fprintf('Image size  : %d x %d\n', size(I_gray,1), size(I_gray,2));
    fprintf('Data type   : %s\n', class(I_gray));

    % MANUAL EDGE DETECTION
    % MANUAL ROBERTS
    roberts_x = [1  0;
                 0 -1];
    roberts_y = [0  1;
                -1  0];
    Rx = imfilter(I_gray, roberts_x, 'replicate');
    Ry = imfilter(I_gray, roberts_y, 'replicate');
    manual_roberts = sqrt(Rx.^2 + Ry.^2);
    manual_roberts = mat2gray(manual_roberts);

    % MANUAL SOBEL
    sobel_x = [-1  0  1;
               -2  0  2;
               -1  0  1];
    sobel_y = [-1 -2 -1;
                0  0  0;
                1  2  1];
    Sx = imfilter(I_gray, sobel_x, 'replicate');
    Sy = imfilter(I_gray, sobel_y, 'replicate');
    manual_sobel = sqrt(Sx.^2 + Sy.^2);
    manual_sobel = mat2gray(manual_sobel);

    % MANUAL PREWITT
    prewitt_x = [-1  0  1;
                 -1  0  1;
                 -1  0  1];
    prewitt_y = [-1 -1 -1;
                  0  0  0;
                  1  1  1];
    Px = imfilter(I_gray, prewitt_x, 'replicate');
    Py = imfilter(I_gray, prewitt_y, 'replicate');
    manual_prewitt = sqrt(Px.^2 + Py.^2);
    manual_prewitt = mat2gray(manual_prewitt);

    % MATLAB BUILT-IN EDGE DETECTION
    builtin_roberts = edge(I_gray, 'roberts');
    builtin_sobel = edge(I_gray, 'sobel');
    builtin_prewitt = edge(I_gray, 'prewitt');

    fig = figure('Name','First-Order Edge Detection', ...
        'NumberTitle','off','Color','w', ...
        'Units','pixels','Position',[80 50 1400 820]);

    annotation(fig,'textbox',[0.20 0.94 0.60 0.045], ...
        'String','First-Order Edge Detection', ...
        'HorizontalAlignment','center','VerticalAlignment','middle', ...
        'FontSize',17,'FontWeight','bold','EdgeColor','none');

    % 1. ORIGINAL IMAGE
    ax1 = subplot(2,4,1);
    imshow(I_original);
    title('Original','FontSize',12,'FontWeight','bold');

    % 2. ROBERTS MANUAL
    ax2 = subplot(2,4,2);
    imshow(manual_roberts);
    title('Roberts - Manual','FontSize',12,'FontWeight','bold');

    % 3. SOBEL MANUAL
    ax3 = subplot(2,4,3);
    imshow(manual_sobel);
    title('Sobel - Manual','FontSize',12,'FontWeight','bold');

    % 4. PREWITT MANUAL
    ax4 = subplot(2,4,4);
    imshow(manual_prewitt);
    title('Prewitt - Manual','FontSize',12,'FontWeight','bold');

    % 5. GRAYSCALE IMAGE
    ax5 = subplot(2,4,5);
    imshow(I_gray);
    title('Grayscale','FontSize',12,'FontWeight','bold');

    % 6. ROBERTS BUILT-IN
    ax6 = subplot(2,4,6);
    imshow(builtin_roberts);
    title('Roberts - Built-in','FontSize',12,'FontWeight','bold');

    % 7. SOBEL BUILT-IN
    ax7 = subplot(2,4,7);
    imshow(builtin_sobel);
    title('Sobel - Built-in','FontSize',12,'FontWeight','bold');

    % 8. PREWITT BUILT-IN
    ax8 = subplot(2,4,8);
    imshow(builtin_prewitt);
    title('Prewitt - Built-in','FontSize',12,'FontWeight','bold');

    % ADJUST SUBPLOT POSITIONS
    % Get current positions
    p1 = get(ax1,'Position');
    p2 = get(ax2,'Position');
    p3 = get(ax3,'Position');
    p4 = get(ax4,'Position');
    p5 = get(ax5,'Position');
    p6 = get(ax6,'Position');
    p7 = get(ax7,'Position');
    p8 = get(ax8,'Position');

    % Increase gap between title and first row
    p1(2) = p1(2) - 0.025;
    p2(2) = p2(2) - 0.025;
    p3(2) = p3(2) - 0.025;
    p4(2) = p4(2) - 0.025;

    % Reduce gap between row 1 and row 2 
    p5(2) = p5(2) + 0.035;
    p6(2) = p6(2) + 0.035;
    p7(2) = p7(2) + 0.035;
    p8(2) = p8(2) + 0.035;

    % Apply positions
    set(ax1,'Position',p1);
    set(ax2,'Position',p2);
    set(ax3,'Position',p3);
    set(ax4,'Position',p4);
    set(ax5,'Position',p5);
    set(ax6,'Position',p6);
    set(ax7,'Position',p7);
    set(ax8,'Position',p8);

    % SAVE FIGURE
    [~, image_name, ~] = fileparts(image_files{img_num});
    output_file = ['first_order_comparison_' image_name '.png'];
    exportgraphics(fig,output_file,'Resolution',200);
    close(fig);
end

% TOTAL EXECUTION TIME
total_time = toc(total_start);

% MEMORY ANALYSIS
vars_after = whos;
memory_after = sum([vars_after.bytes]);
memory_used = memory_after / (1024^2);

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
    [user, system] = memory;
    max_array_memory_gb = user.MaxPossibleArrayBytes / (1024^3);
    available_ram_gb = user.MemAvailableAllArrays / (1024^3);
    fprintf('Available system RAM : %.2f GB\n',available_ram_gb);
    fprintf('Maximum MATLAB array memory : %.2f GB\n',max_array_memory_gb);
catch
    fprintf('System RAM information : Not available\n');
end

% TIME COMPLEXITY
fprintf('\nTime Complexity:\n');
fprintf('Roberts : O(N)\n');
fprintf('Sobel   : O(N)\n');
fprintf('Prewitt : O(N)\n');
fprintf('Overall : O(N)\n');
fprintf('N = number of image pixels\n');

% MEMORY LEAKAGE INDICATOR
fprintf('\nMemory Leakage:\n');
fprintf('Memory usage reported above is the MATLAB variable memory.\n');
fprintf('A positive memory increase between repeated runs can indicate memory growth.\n');