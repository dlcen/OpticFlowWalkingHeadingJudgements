%% ReadMe
% This funtion is to find the pairs on the image plane that share same image position but at different depths, and then calculate the difference in velocity between the pair.
%
% INPUTS:
% 		grid_data - the dot position on the image plane.
% 		closeness_threshold: how close the two dots in the pair can be seen as sharing the same image position
%
% OUTPUTS:
% 		differential_grid_data: velocity difference between the pairs
% 
% Procedures:
% 		Step 1: Obtain combination of the dots
% 		Step 2: Find pairs 
% 		Step 3: Calculate velocity difference

%% Function
function differential_grid_data = Cal_motion_parallax_local_differential(grid_data, closeness_threshold)

%% Step 1: Obtain combination of the dots
	n_grid 		= size(grid_data, 1);
	id_grid 	= 1:n_grid;

	raw_pairs 	= combnk(id_grid, 2);
    n_raw_pairs = size(raw_pairs, 1);

%% Step 2: Find pairs 
	if nargin == 1
		closeness_threshold = 0.2;
	end

	% Calculate the distance between the two dots in each pair
	dot_1_x 	= grid_data(raw_pairs(:, 1), 1);
	dot_1_y 	= grid_data(raw_pairs(:, 1), 2);
	dot_2_x 	= grid_data(raw_pairs(:, 2), 1);
	dot_2_y 	= grid_data(raw_pairs(:, 2), 2);

	pair_dist 	= sqrt((dot_1_x - dot_2_x).^2 + (dot_1_y - dot_2_y).^2);

	idx_pairs   = find(pair_dist < closeness_threshold);
	n_idx_pairs = length(idx_pairs);

	if isempty(idx_pairs)
		differential_grid_data = [];
	end

	% Find out whether a same dot appears in more than one pairs - will add this if there is a need in the future

%% Step 3: Calculate velocity difference
	differential_grid_data = NaN(n_idx_pairs, 6);

	% Potision on the image plane (use the position of the first dot in the pair)
	differential_grid_data(:, 1) = dot_1_x(idx_pairs);
	differential_grid_data(:, 2) = dot_1_y(idx_pairs);

	% Velocity along the x- and y-axis
	dot_1_vx = grid_data(raw_pairs(:, 1), 3);
	dot_1_vy = grid_data(raw_pairs(:, 1), 4);
	dot_2_vx = grid_data(raw_pairs(:, 2), 3);
	dot_2_vy = grid_data(raw_pairs(:, 2), 4);
    
    pair_1_vx 	= dot_1_vx(idx_pairs);
	pair_1_vy 	= dot_1_vy(idx_pairs);
	pair_2_vx  	= dot_2_vx(idx_pairs);
	pair_2_vy   = dot_2_vy(idx_pairs);
    
	% Which one is faster?
	pair_1_v  = sqrt(pair_1_vx.^2 + pair_1_vy.^2);
	pair_2_v  = sqrt(pair_2_vx.^2 + pair_2_vy.^2);

	from_1_2_id = find(pair_1_v >= pair_2_v);
	from_2_1_id = find(pair_1_v <  pair_2_v);

	differential_grid_data(from_1_2_id, 3) =  pair_1_vx(from_1_2_id) - pair_2_vx(from_1_2_id);
	differential_grid_data(from_1_2_id, 4) =  pair_1_vy(from_1_2_id) - pair_2_vy(from_1_2_id);
    differential_grid_data(from_1_2_id, 5) =  pair_1_v(from_1_2_id);
    differential_grid_data(from_1_2_id, 6) =  pair_2_v(from_1_2_id);

	differential_grid_data(from_2_1_id, 3) =  pair_2_vx(from_2_1_id) - pair_1_vx(from_2_1_id);
	differential_grid_data(from_2_1_id, 4) =  pair_2_vy(from_2_1_id) - pair_1_vy(from_2_1_id);
    differential_grid_data(from_2_1_id, 5) =  pair_2_v(from_2_1_id);
    differential_grid_data(from_2_1_id, 6) =  pair_1_v(from_2_1_id);
    
%% Exclude those with a very small differential speed
    weberfactor = 0.05;
    bottom_v    = 0.02;
    
    abs_v = sqrt(differential_grid_data(:, 3).^2 + differential_grid_data(:, 4).^2);
    
    small_id = find(abs_v < bottom_v | abs_v < differential_grid_data(:, 5) * weberfactor);
    
    if ~isempty(small_id); differential_grid_data(small_id, :) = []; end
    
end