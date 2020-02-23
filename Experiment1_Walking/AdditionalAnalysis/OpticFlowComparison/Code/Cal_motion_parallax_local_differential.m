%% ReadMe
% This funtion is to find the pairs on the image plane that share same image position but at different depths, and then calculate the difference in velocity between the pair.
%
% INPUTS:
% 		image_data - the dot position on the image plane.
% 		closeness_threshold: how close the two dots in the pair can be seen as sharing the same image position
%
% OUTPUTS:
% 		differential_image_data: velocity difference between the pairs
%
% Procedures:
% 		Step 1: Starting from the first data point
% 		Step 2: Find out whether there is a dot with which the distance is smaller than the threshold
% 		Step 3: If there are more than one dot in the near zone, find out the one with the largest distance or the largest speed difference.
%     Step 4: Remove the pair from image_data
%-----------------------------------------------------------------------------------------------------------------------------------------

%% Function
function differential_image_data = Cal_motion_parallax_local_differential_seq_raw(image_data, closeness_threshold)

%% Step 1: Starting

n_grid 		 = size(image_data, 1);

bottom_v     = 0.02;    % The minimal speed threshold - if lower than this speed, it is considered to be too slow to be perceivable.
weberfactor  = 0.05;

differential_image_data = [];

%% Step 2: Find pairs
if nargin == 1
    closeness_threshold = 0.2;
end

while n_grid > 0

    this_dot = image_data(1, :);
    image_data(1, :) = [];

    dot_dists = sqrt( (image_data(:, 1) - this_dot(1)).^2  + (image_data(:, 2) - this_dot(2)).^2 );

    % find out those dots within the pre-defined range
    range_id = find(dot_dists <= closeness_threshold);

    second_dot = [];

    % if there is any dots within the range
    if ~isempty(range_id)

        % if there is only one second dot
        if length(range_id) == 1

            second_dot = image_data(range_id, :);

            % Remove if both of the dots come from the target (label = 1 or 2)
            if this_dot(7) > 0 && second_dot(7) > 0
                n_grid = size(image_data, 1);
                continue;
            end

            % Remove if both at the same depth
            if this_dot(8) == second_dot(8)
                n_grid = size(image_data, 1);
                continue;
            end

        % if there is more than one second_dot, choose the one that is the closest from the chosen dot
        elseif length(range_id) > 1

            second_dots = image_data(range_id, :);

            % if the current dot is on the target
            if this_dot(7) > 0
                % Only the dots from other visual elements in the environment and not at the same depth will be considered.
                second_dots = second_dots(second_dots(:, 7) == 0 & second_dots(:, 8) ~= this_dot(8), :);

                if size(second_dots, 1) == 1
                    second_dot = second_dots;

                elseif size(second_dots, 1) > 1

                    second_dots_dist = sqrt((second_dots(:, 1) - this_dot(:, 1)).^2 + (second_dots(:, 2) - this_dot(:, 2)).^2);
                    second_dot = second_dots(second_dots_dist == min(second_dots_dist), :); % Find out the closest dot.

                    % If there is more than one potential second dot with the
                    % minimum distance to the current dot, find out the one
                    % with the larget speed difference.
                    if size(second_dot, 1) > 1
                        second_dot_sp_diff =  sqrt((second_dot(:, 3) - this_dot(3)).^2 + (second_dot(:, 4) - this_dot(4)).^2);
                        second_dot = second_dot(second_dot_sp_diff == max(second_dot_sp_diff), :);
                    end
                end

            % if the current dot is not on the target
            elseif this_dot(7) == 0

                second_dots = second_dots(second_dots(:, 8) ~= this_dot(8), :);         % Find out those dots that are not on the same depth as the current dot

                second_dots_dist = sqrt((second_dots(:, 1) - this_dot(:, 1)).^2 + (second_dots(:, 2) - this_dot(:, 2)).^2);
                second_dot = second_dots(second_dots_dist == min(second_dots_dist), :); % Find out the closest dot.

                % If there is more than one potential second dot with the
                % minimum distance to the current dot, find out the one
                % with the larget speed difference.
                if size(second_dot, 1) > 1
                    second_dot_sp_diff =  sqrt((second_dot(:, 3) - this_dot(3)).^2 + (second_dot(:, 4) - this_dot(4)).^2);
                    second_dot = second_dot(second_dot_sp_diff == max(second_dot_sp_diff), :);
                end

                % If there is still more than one potential second dot,
                % randomly choose one.
                if size(second_dot, 1) > 1
                    second_dot = second_dot( randsample( size(second_dot, 1), 1), :);
                end
            end

        end

        % Calculate the difference between the velocity vector of the two dots
        % Note the order between the two dots
        if ~isempty(second_dot)
            this_dot_sp    = sqrt(this_dot(3)^2 + this_dot(4)^2);
            second_dot_sp  = sqrt(second_dot(3)^2 + second_dot(4)^2);

            sp_diff = abs(this_dot_sp - second_dot_sp);

            % If the magnitude of the speed difference is lower than the
            % minimum threshold, or is smaller than 5% of the larger speed
            % of the two dots (defined by weber factor), the pair is
            % considered invalid.x
            if (sp_diff < bottom_v || sp_diff < weberfactor * max(this_dot_sp, second_dot_sp))
                second_dot = [];
            else
                if this_dot_sp > second_dot_sp  % Order the pair according to their speed magnitude
                    tmp_pair = [this_dot(1), this_dot(2), this_dot(3) - second_dot(3), this_dot(4) - second_dot(4)];
                else
                    tmp_pair = [this_dot(1), this_dot(2), second_dot(3) - this_dot(3), second_dot(4) - this_dot(4)];
                end
            end
        end
    end

    if ~isempty(second_dot)
        differential_image_data = [differential_image_data; tmp_pair];
        second_dot_id = find(image_data(:, 1) == second_dot(1) & image_data(:, 2) == second_dot(2) & image_data(:, 3) == second_dot(3));
        image_data(second_dot_id, :) = [];
    end

    n_grid = size(image_data, 1);
end

end
