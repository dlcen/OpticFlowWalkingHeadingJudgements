% This function is to calculate the values of the speed quartile for a specific condition.
%
% INPUT:
%
%   thisCondition: the name of the condition
%   eccentricity
%
% OUTPUT:
%   values of the quartile

function [m, q] = Cal_Quartile(thisCondition, eccentricity, eccentricity_width, dev_ang)

	switch nargin
	 	case 3
	 		dev_ang = 10;
	 	case 2
	 		eccentricity_width = 0.5;
	 		dev_ang = 10;

	end

	%% Set up the basic constant
	dz = 1/37; % distance that the viewer has moved for the duration of one frame, starting from 6m from the target

	img_w = 90; % define the size of FoV, according to the specs of Oculus DK2
	img_h = 50;

	vf_x = tand(img_w/2);
	vf_y = tand(img_h/2);

	target_distance = 6;
	pF = 1/(target_distance - dz); % the distance to the target after one frame

	Tr = [sind(dev_ang), 0, cosd(dev_ang)]; % calculating the transitional component
	Rr = [0, -pF*Tr(1), 0]; % calculating the rotational component

	%% Load the data
	load(['../', thisCondition, '/dotPosition.mat'])

	%% Calculate and plot the flow field
	%  Gaze to the direction of moving (so there is only translation component)
	image_data_Tr = Cal_Image_Vectors(dotPosition, Tr, 0, img_w, img_h);

	%% Calculate the eccentricity for each dot
	%  Calculate the location of the target
	fix_x = tand(dev_ang);
	fix_y = 0;

	%  Calculate the distance between each dot to the centre of the gaze
	image_data_Tr(:, 11) = sqrt((image_data_Tr(:, 1) - fix_x).^2 + (image_data_Tr(:, 2) - fix_y).^2);

	%  Transform the unit of the distances to degree
	image_data_Tr(:, 12) = atand(image_data_Tr(:, 11));

	% Transform the unit of speed magnitude to degree
	image_data_Tr(:, 13) = atand(image_data_Tr(:, 5));

	%  Plot a figure to check the data
	% figure
	% hold on
	% scatter(image_data_Tr(:, 12), image_data_Tr(:, 13), 50, [.5 .5 .5], 'filled')
	% xlabel('Eccentricity (^{\circ})')
 %    ylabel('Speed vector magnitude (^{\circ}/s)')
	% set(gca, 'fontsize', 24)
	% set(gcf, 'Units', 'centimeters', 'OuterPosition', [5, 5, 21, 14]);
	% box on
	% grid off

	%% Calculate the quartile
	%  Select the data within the eccentricity range
	this_data = image_data_Tr(image_data_Tr(:, 12) >= eccentricity - eccentricity_width & image_data_Tr(:, 12) <= eccentricity + eccentricity_width, 13);

	if size(this_data, 1) < 4 && size(this_data, 1) > 1
		m = mean(this_data); q = 0;
		fprintf('There are only %d dots within this eccentricity range.\n', size(this_data, 1));
		fprintf('The mean of the speed magnitude of these dots is: %.2f degree/s.\n', m);
    elseif size(this_data, 1) >= 4
		m = mean(this_data);
		q = iqr(this_data);
        fprintf('There are %d dots within this eccentricity range.\n', size(this_data, 1));
        fprintf('The mean of the speed magnitude of these dots is: %.2f degree/s.\n', m);
        fprintf('The interquartile of the speed magnitude of these dots is: %.2f degree/s.\n', q);
    elseif size(this_data, 1) == 0
        m = 0; q = 0;
		fprintf('There is no dot within this eccentricity range.\n');
    elseif size(this_data, 1) == 1
        m = this_data; q = 0;
		fprintf('There is only one dot within this eccentricity range.\n');
        fprintf('The speed magnitude of this data is: %.2f degree/s.\n', m);
    end
