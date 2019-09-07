
% This function is to plot the distribution of magnitude of flow vectors on the x-axis and the motion parallax field
% 
% INPUT:
% 	thisCondition: the name of the condition in which the flow information will be calculated
%   dev_ang: the deviation between the walking direction and the direction to the target
% 
% OUTPUT:
% 	image_data: an image velocity matrix, including the image location of each vector (x, y), the velocity on the x-axis and y-axis respectively and the magnitude of speed.
% 				it also includes the noise of the speed and direction for each vector. 


function Cal_Flow_Info(thisCondition, dev_ang)

	if nargin == 1
		dev_ang = 10;
	end

	%% Set up the basic constant
	dz = 1/37; % distance that the viewer has moved for the duration of one frame, starting from 6m from the target

	img_w = 90; % define the size of FoV, according to the specs of Oculus DK2
	img_h = 50;

	vf_x = tand(img_w/2);
	vf_y = tand(img_h/2);

	pF = 1/(6 - dz); % the distance to the target after one frame

	Tr = [sind(dev_ang), 0, cosd(dev_ang)]; % calculating the transitional component
	Rr = [0, -pF*Tr(1), 0]; % calculating the rotational component

	%% Load the data
	load(['../', thisCondition, '/dotPosition.mat'])

	%% Calculate and plot the flow field
	%  Gaze to the direction of moving
	image_data_Tr = Cal_Image_Vectors(dotPosition, Tr, 0, img_w, img_h);

	%  Gaze fixed on the target while moving
	image_data_Rt = Cal_Image_Vectors(dotPosition, Tr, pF, img_w, img_h);

	%% Plot the distribution of magnitude of speed vectors as a function of x-axis
	image_data_Tr(:, 11) = abs(atand(image_data_Tr(:, 3)));

	target_idx = find(image_data_Tr(:, 11) == 0 & image_data_Tr(:, 1) < 0.25/6 & image_data_Tr(:, 1) > -0.25/6);

	target_data = image_data_Tr(target_idx, :);
	[scene_data, ~] = setdiff(image_data_Tr, target_data, 'rows');

	figure
	hold on
	scatter3(atand(scene_data(:, 1)), atand(scene_data(:, 2)), scene_data(:, 11), 50, [.5 .5 .5], 'filled')
	scatter3(atand(target_data(:, 1)), atand(target_data(:, 2)), target_data(:, 11), 50, [255/255, 191/255, 0], 'filled')
	xlim([-img_w/2 img_w/2])
	ylim([-img_h/2 img_h/2])
	zlim([0 25])
	set(gca, 'Ylabel', [])
	set(gca, 'Xlabel', [])
	set(gca, 'fontsize', 24)
	view(0, 0)
	set(gcf, 'Units', 'centimeters', 'OuterPosition', [5, 5, 21, 14]);
	colorbar('off')
	box on
	grid off
	set(gca, 'color', 'none')
	set(gcf, 'color', 'none')

	savefig(['../', thisCondition, '/SpeedMagnitudeDistribution'])
	print(['../', thisCondition, '/SpeedMagnitudeDistribution'], '-dsvg')


	%% Calculate the motion parallax
	closeness_threshold = 0.2 * sqrt(2);

	differential_data = Cal_motion_parallax_local_differential(image_data_Rt, tand(closeness_threshold));

	scale = 30;
	cross_size = 2;

	figure
	hold on
	box on
	quiver(atand(image_data_Rt(:, 1)), atand(image_data_Rt(:, 2)), scale * image_data_Rt(:, 3), scale * image_data_Rt(:, 4), 0, 'Color', [.5 .5 .5], 'MaxHeadSize', .1, 'LineWidth', 1)

	if size(differential_data, 1) > 1
	    quiver(atand(differential_data(:, 1)), atand(differential_data(:, 2)), scale * differential_data(:, 3), scale * differential_data(:, 4), 0, 'Color', 'r', 'MaxHeadSize', 1, 'LineWidth', 2.5) 
	end

	gazeat = 0;
	scatter(gazeat, 0, 150, [0, 0.4, 1], 'filled')
	plot([dev_ang - cross_size; dev_ang + cross_size], [0; 0], 'color', [0.4078    0.6235    0.2196], 'LineWidth', 4)
	plot([dev_ang; dev_ang], [-cross_size; cross_size], 'color', [0.4078    0.6235    0.2196], 'LineWidth', 4)

	xlim([-img_w/2 img_w/2])
	ylim([-img_h/2 img_h/2])
	set(gca, 'Ylabel', [])
	set(gca, 'Xlabel', [])
	set(gca, 'fontsize', 24)
	set(gca,'color','none')
	set(gcf, 'Units', 'centimeters', 'OuterPosition', [5, 5, 21, 14])
	set(gca, 'color', 'none')
	set(gcf, 'color', 'none')

	savefig(['../', thisCondition, '/FlowAndMotionParallaxField'])
	print(['../', thisCondition, '/FlowAndMotionParallaxField'], '-dsvg')




