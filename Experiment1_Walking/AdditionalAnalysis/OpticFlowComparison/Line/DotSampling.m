
%% Dimension of the target post and the distance to the starting point ([0, 0, 0])
line_X = [-0.01, 0.01];
line_Y = 3;
line_Z = 7;

%% Sample dots on the target post:
%  Notes:
%		1. Choose a resolution for sampling the target post arbitrarily.
%       2. Label: 1 - on a horizontal edge; 2 - on a vertical edge.

dot_resolution = 0.01;

% Sampling the top edge of the target post
line_dots_up_x = [line_X(1): dot_resolution: line_X(2)];
line_dots_up_y = repmat(line_Y, size(line_dots_up_x));
line_dots_up_l = ones(size(line_dots_up_x)); % Label the sampled dots "1" as they are on a horizontal edge

% Sampling the bottom edge of the target post
line_dots_down_x = [line_X(1): dot_resolution: line_X(2)];
line_dots_down_y = zeros(size(line_dots_down_x));
line_dots_down_l = ones(size(line_dots_down_x)); % Label the sampled dots "1" as they are on a horizontal edge

% Sampling the left edge of the target post
line_dots_left_y = [0: dot_resolution: line_Y]; 
line_dots_left_x = repmat(line_X(1), size(line_dots_left_y));
line_dots_left_l = 2*ones(size(line_dots_left_y)); % Label the sampled dots "2" as they are on a vertical edge

% Sampling the right edge of the target post
line_dots_right_y = [0: dot_resolution: line_Y]; 
line_dots_right_x = repmat(line_X(2), size(line_dots_right_y));
line_dots_right_l = 2*ones(size(line_dots_right_y)); % Label the sampled dots "2" as they are on a vertical edge

% Put the sampled points together along each dimension
line_dots_x = [line_dots_up_x'; line_dots_down_x'; line_dots_left_x'; line_dots_right_x'];
line_dots_y = [line_dots_up_y'; line_dots_down_y'; line_dots_left_y'; line_dots_right_y'];
line_dots_l = [line_dots_up_l'; line_dots_down_l'; line_dots_left_l'; line_dots_right_l'];

% Add the depth of the target post
line_dots_z = repmat(line_Z, size(line_dots_x));

% Put the location data together
line_dots_pos = [line_dots_x, line_dots_y, line_dots_z, line_dots_l];

%% Export the position of the dots on the wall
dlmwrite('Line_positions.csv', line_dots_pos,'delimiter',',');
