clc;
clear;
close all;

rows = 3;
cols = 9;

while true
    pattern = zeros(rows, cols);
    for i = 1:rows
        % generate 5 random numbers in between 1 to cols
        positions = randperm(cols, 5);
        % set value to 1 at same 5 random positions
        pattern(i, positions) = 1;
    end
    % dimension 1 means adding along the rows, giving the sum of each column
    columnCount = sum(pattern, 1);
    if all(columnCount >= 1)
        break;
    end
end


ticket = zeros(rows, cols);

ranges = {
    1:9, ...
    10:19, ...
    20:29, ...
    30:39, ...
    40:49, ...
    50:59, ...
    60:69, ...
    70:79, ...
    80:90
};

for j = 1:cols

    % find rows where a number has to be placed
    selectedRows = find(pattern(:,j) == 1);

    % number of values required in this column
    n = length(selectedRows);

    % select unique random numbers from this column's range
    randomPositions = randperm(length(ranges{j}), n);

    numbers = ranges{j}(randomPositions);

    % arrange numbers in ascending order
    numbers = sort(numbers);

    % put the numbers into the selected rows
    ticket(selectedRows, j) = numbers;
end


disp('Tambola Ticket:');
disp(ticket);


% Cross-Check 
% Dimension 2: add along columns to count values in each row
disp('Number of values in each row:');
disp(sum(ticket > 0, 2));

% Dimension 1: add along rows to count values in each column
disp('Number of values in each column:');
disp(sum(ticket > 0, 1));

% Convert the matrix to one column and count all non-zero values
disp('Total number of values:');
disp(sum(ticket(:) > 0));
