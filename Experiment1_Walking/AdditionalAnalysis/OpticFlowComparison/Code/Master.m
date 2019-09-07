
clear all;

%% Set up the basic constant
dz = 1/37; % distance that the viewer has moved for the duration of one frame, starting from 6m from the target

img_w = 90; % define the size of FoV, according to the specs of Oculus DK2
img_h = 50;

vf_x = tand(img_w/2);
vf_y = tand(img_h/2);

T = [0, 0, 1];

pF = 1/(6 - dz); % the distance to the target after one frame

dev_ang = 10;
Tr = [sind(dev_ang), 0, cosd(dev_ang)]; % calculating the transitional component
Rr = [0, -pF*Tr(1), 0]; % calculating the rotational component

%% Load the data
load(['../', thisCondition, '/dotPosition.mat'])

%% Calculate and plot the flow field
%  Gaze fixed on the target while moving
image_data = Cal_Image_Vectors(dotPosition, Tr, pF, img_w, img_h);

image_data(:, 11) = atand(image_data(:, 5));

%% Plot the vector field
figure
scatter3(atand(image_data(:, 1)), atand(image_data(:, 2)), image_data(:, 11), 100, image_data(:, 11), 'filled'); colormap jet; colorbar; caxis([0 25])
xlim([-img_w/2 img_w/2])
ylim([-img_h/2 img_h/2])
zlim([0 25])
set(gca, 'Ylabel', [])
set(gca, 'Xlabel', [])
set(gca, 'fontsize', 24)
view(0, 90)
set(gcf, 'Units', 'centimeters', 'OuterPosition', [5, 5, 21, 14]);
h = colorbar;
box on
grid off
set(h, 'ylim', [0 25])
set(gca, 'color', 'none')
set(gcf, 'color', 'none')

savefig(['../', thisCondition, 'Figures/SpeedMagnitudeField'])
print(['../', thisCondition, 'Figures/SpeedMagnitudeField'], '-dsvg')

%% Calculate the motion parallax
closeness_threshold = 0.2 * sqrt(2);

% differential_data = Cal_motion_parallax_local_differential(valid_grid_data, atand(closeness_threshold));
differential_data = Cal_motion_parallax_local_differential_seq_raw(image_data, tand(closeness_threshold));

% small_threshold = closeness_threshold * Tr(3);
% 
% differential_data_speed = sqrt(differential_data(:, 3).^2 + differential_data(:, 4).^2);
% small_id = find(differential_data_speed < small_threshold);
% 
% if ~isempty(small_id)
%     differential_data(small_id, :) = [];
% end

scale = 30;
cross_size = 2;


figure
hold on
box on
quiver(atand(image_data(:, 1)), atand(image_data(:, 2)), scale * image_data(:, 3), scale * image_data(:, 4), 0, 'Color', [.75 .75 .75], 'MaxHeadSize', .1, 'LineWidth', .75)
% scatter(atand(image_data(:, 1)), atand(image_data(:, 2)), 1, 'MarkerEdgeColor', [0.5, 0.5, 0.5], 'MarkerEdgeAlpha', .5)
if size(differential_data, 1) > 1
    quiver(atand(differential_data(:, 1)), atand(differential_data(:, 2)), scale * differential_data(:, 3), scale * differential_data(:, 4), 0, 'Color', 'r', 'MaxHeadSize', 1, 'LineWidth', 1.5) %[.8 .4 0]
end

gazeat = 0;
scatter(gazeat, 0, 50, [0.3010, 0.7450, 0.9330], 'filled')
plot([dev_ang - cross_size; dev_ang + cross_size], [0; 0], 'color', [0.4660, 0.6740, 0.1880], 'LineWidth', 2)
plot([dev_ang; dev_ang], [-cross_size; cross_size], 'color', [0.4660, 0.6740, 0.1880], 'LineWidth', 2)

xlim([-img_w/2 img_w/2])
ylim([-img_h/2 img_h/2])
% xlabel('Retinal X [\circ]')
% ylabel('Retinal Y [\circ]')
set(gca, 'Ylabel', [])
set(gca, 'Xlabel', [])
set(gca, 'fontsize', 24)
set(gca,'color','none')
set(gcf, 'Units', 'centimeters', 'OuterPosition', [5, 5, 21, 14])
set(gca, 'color', 'none')
set(gcf, 'color', 'none')
% set(gca, 'color', [0 0 0],'Xcolor','w','Ycolor','w');
% set(gcf, 'color', [0 0 0]);
% set(gca, 'XTick', (-45:15:45), 'YTick', [-25:5:25])
% set(gcf, 'InvertHardCopy', 'off')

if ~exist('Figures', 'dir'); mkdir('Figures'); end

savefig('Figures/Motion_parallax_rotation_lite')
% print('Figures/Motion_parallax_rotation_lite', '-dsvg')
% print('Figures/Motion_parallax_rotation_lite', '-dpng', '-r300')




