
%% Get the position of the dots
cloud_dotPosition = readtable('Cloud_positions_6300.csv');
cloud_dotPosition = table2array(dotPosition);

% Get rid of those dots that are behind the viewer
cloud_dotPosition = dotPosition(dotPosition(:, 3) > 0, :);

% Label the dots: 0 - no restriction on the direction of flow vectors
cloud_dotPosition = [cloud_dotPosition, zeros(size(cloud_dotPosition, 1), 1)];

%% Add the sampled dots from the target post
line_dotPosition = readtable('Line_position.csv');
line_dotPosition = table2array(line_dotPosition);

% Set the position of the target sampled dots to be relative to the viewer
line_dotPosition(:, 2) = line_dotPosition(:, 2) - 1.5;
line_dotPosition(:, 3) = line_dotPosition(:, 3) - 1;

%% Put the position of the cloud dots and target dots together
dotPosition = [cloud_dotPosition; line_dotPosition];

%% Save the position data
save('dotPosition.mat', 'dotPosition')