
%% Get the position of the dots
cloud_dotPosition = readtable('Cloud_positions_6300.csv');
cloud_dotPosition = table2array(cloud_dotPosition);

cloud_dotPosition(:, 2) = cloud_dotPosition(:, 2) + 1.5;
cloud_dotPosition(:, 3) = cloud_dotPosition(:, 3) + 1;

% Label the dots: 0 - no restriction on the direction of flow vectors
cloud_dotPosition = [cloud_dotPosition, zeros(size(cloud_dotPosition, 1), 1)];

%% Add the sampled dots from the target post
line_dotPosition = readtable('Line_positions.csv');
line_dotPosition = table2array(line_dotPosition);

%% Put the position of the cloud dots and target dots together
dotPosition = [cloud_dotPosition; line_dotPosition];

% Check the dot positions
figure; scatter3(dotPosition(:, 1), dotPosition(:, 3), dotPosition(:, 2))

%% Plot the sampled dots viewed from starting point ([0, 0]) at the height of 1.5m
spv_x = dotPosition(:, 1)./dotPosition(:, 3);
spv_y = (dotPosition(:, 2) - 1.5)./dotPosition(:, 3);

fh = figure('Menu','none','ToolBar','none');
ah = axes('Units','Normalize','Position',[0 0 1 1]);
scatter(atand(spv_x), atand(spv_y), 1, 'filled')
xlim([-45 45])
ylim([-25 25])
set(gca,'XTick',[]);
set(gca,'YTick',[]);
box on
set(gcf, 'Units', 'centimeters', 'OuterPosition', [5, 5, 21, 14]);

savefig(fh, 'SampledDots.fig')
print(fh, 'SampledDots', '-dsvg')

%% Calculate the position of the sampled dots relative to the viewer

dotPosition(:, 2) = dotPosition(:, 2) - 1.5;
dotPosition(:, 3) = dotPosition(:, 3) - 1;

% Remove the dots that are behind the viewer
dotPosition = dotPosition(dotPosition(:, 3) > 0, :);

% Check the dot positions
figure; scatter3(dotPosition(:, 1), dotPosition(:, 3), dotPosition(:, 2))

%% Save the position data
save('dotPosition.mat', 'dotPosition')