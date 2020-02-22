
%% Parameters of the outline
% Wall outline (width, height and depth)
wd = 12; ht = 3; dp = 12;

% Doorway outline (height and width)
dr_ht = 2.5; dr_wd = 0.5;

% Other
target_distance = 7;   % Distance from the starting point ([0, 0, 0])
dot_resolution = 0.01; % Sampling resolution

%% Calculate the dots
%  Notes:
%       1. Labels: 1 - Horizontal; 2 - Vertical
%  		2. Unlike the target post in the Line condition, the dimension of the lines that constituted the outline was fixed in pixels (2 pixels), therefore only one edge is calculated for each line.

% The top line of the front wall
l_fr_up_x = -wd/2:dot_resolution:wd/2;
l_fr_up_y = repmat(ht, size(l_fr_up_x));
l_fr_up_z = repmat(target_distance, size(l_fr_up_x));
l_fr_up_l = ones(size(l_fr_up_x)); 		% Label the sampled dots "1" as they are on a horizontal edge
l_fr_up   = [l_fr_up_x; l_fr_up_y; l_fr_up_z; l_fr_up_l];

% The bottom line of the front wall
l_fr_bm_x = l_fr_up_x;
l_fr_bm_y = l_fr_up_y - ht;
l_fr_bm_z = l_fr_up_z;
l_fr_bm_l = l_fr_up_l; 		% Same as above
l_fr_bm   = [l_fr_bm_x; l_fr_bm_y; l_fr_bm_z; l_fr_bm_l];

% The right line of the front wall
l_fr_rt_y = 0:dot_resolution:ht;
l_fr_rt_x = repmat(wd/2, size(l_fr_rt_y));
l_fr_rt_z = repmat(target_distance, size(l_fr_rt_y));
l_fr_rt_l = 2*ones(size(l_fr_rt_y)); 	% Label the sampled dots "2" as they are on a vertical edge
l_fr_rt   = [l_fr_rt_x; l_fr_rt_y; l_fr_rt_z; l_fr_rt_l];

% The left line of the front wall
l_fr_lf_y = l_fr_rt_y;
l_fr_lf_x = l_fr_rt_x - wd;
l_fr_lf_z = l_fr_rt_z;
l_fr_lf_l = l_fr_rt_l; 		% Same as above
l_fr_lf   = [l_fr_lf_x; l_fr_lf_y; l_fr_lf_z; l_fr_lf_l];

% The top line of the right wall
l_rt_up_z = (dp - target_distance):dot_resolution:target_distance;
l_rt_up_x = repmat(wd/2, size(l_rt_up_z));
l_rt_up_y = repmat(ht, size(l_rt_up_z));
l_rt_up_l = ones(size(l_rt_up_z)); 		% Label the sampled dots "1" as they are on a horizontal edge
l_rt_up   = [l_rt_up_x; l_rt_up_y; l_rt_up_z; l_rt_up_l];

% The bottom line of the right wall
l_rt_bm_z = l_rt_up_z;
l_rt_bm_x = l_rt_up_x;
l_rt_bm_y = l_rt_up_y - ht;
l_rt_bm_l = l_rt_up_l; 		% Same as above
l_rt_bm   = [l_rt_bm_x; l_rt_bm_y; l_rt_bm_z; l_rt_bm_l];

% The top line of the left wall
l_lf_up_z = l_rt_up_z;
l_lf_up_y = l_rt_up_y;
l_lf_up_x = l_rt_up_x - wd;
l_lf_up_l = l_rt_up_l; 		% Same as above
l_lf_up   = [l_lf_up_x; l_lf_up_y; l_lf_up_z; l_lf_up_l];

% The bottom line of the left wall
l_lf_bm_z = l_lf_up_z;
l_lf_bm_x = l_lf_up_x;
l_lf_bm_y = l_lf_up_y - ht;
l_lf_bm_l = l_lf_up_l; 		% Same as above
l_lf_bm   = [l_lf_bm_x; l_lf_bm_y; l_lf_bm_z; l_lf_bm_l];

% The top line of the doorway
dr_up_x   = -dr_wd/2:dot_resolution:dr_wd/2;
dr_up_y   = repmat(dr_ht, size(dr_up_x));
dr_up_z   = repmat(target_distance, size(dr_up_x));
dr_up_l   = ones(size(dr_up_x)); 		% Label the sampled dots "1" as they are on a horizontal edge
dr_up     = [dr_up_x; dr_up_y; dr_up_z; dr_up_l];

% The right line of the doorway
dr_rt_y	  = 0:dot_resolution:dr_ht;
dr_rt_x   = repmat(dr_wd/2, size(dr_rt_y));
dr_rt_z   = repmat(target_distance, size(dr_rt_y));
dr_rt_l   = 2*ones(size(dr_rt_y)); 		% Label the sampled dots "2" as they are on a vertical edge
dr_rt     = [dr_rt_x; dr_rt_y; dr_rt_z; dr_rt_l];

% The left line of the doorway
dr_lf_x   = dr_rt_x - dr_wd;
dr_lf_y   = dr_rt_y;
dr_lf_z	  = dr_rt_z;
dr_lf_l   = dr_rt_l; 		% Same as above
dr_lf 	  = [dr_lf_x; dr_lf_y; dr_lf_z; dr_lf_l];

% Put the sampled dots together
outline_dots_pos = [l_fr_up, l_fr_bm, l_fr_rt, l_fr_lf, l_rt_up, l_rt_bm, l_lf_up, l_lf_bm, dr_up, dr_rt, dr_lf]';

%% Plot the sampled dots viewed from starting point ([0, 0]) at the height of 1.5m
spv_x = outline_dots_pos(:, 1)./outline_dots_pos(:, 3);
spv_y = (outline_dots_pos(:, 2) - 1.5)./outline_dots_pos(:, 3);

fh = figure('Menu','none','ToolBar','none');
ah = axes('Units','Normalize','Position',[0 0 1 1]);
scatter(atand(spv_x), atand(spv_y), 1, 'filled')
xlim([-45 45])
ylim([-25 25])
set(gca,'XTick',[]);
set(gca,'YTick',[]);
box on
set(gcf, 'Units', 'centimeters', 'OuterPosition', [5, 5, 21, 14]);

savefig(['SampledDots'])
print(['SampledDots'], '-dsvg')

%% Export the position of the dots on the wall
dlmwrite('Outline_positions.csv', outline_dots_pos,'delimiter',',');

%% Calculate the position of the sampled dots relative to the viewer
eye_height = 1.5;
distance_to_target = 6;

% Get rid of those sampled dots that are behind the viewer
dotPosition = outline_dots_pos(find(outline_dots_pos(:, 3) > 0), :); 

% Calculate the relative position
dotPosition(:, 2) = dotPosition(:, 2) - eye_height;
dotPosition(:, 3) = dotPosition(:, 3) - (target_distance - distance_to_target);

save('dotPosition', 'dotPosition')