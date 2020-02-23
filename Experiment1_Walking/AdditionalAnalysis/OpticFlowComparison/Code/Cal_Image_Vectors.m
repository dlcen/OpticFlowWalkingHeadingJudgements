
% This function is to calculate the velocity vectors on the image plane based on the translation and environment
%
% INPUT:
% 	env_dots: position of sampled dots in the environment (NOTE: should already taking viewer's position into account)
% 	T: translation [Tx, Ty, Tz]
%   img_w, img_h: the parameter of the size of the image plane, to exclude those dots outside the vision.
%
% OUTPUT:
% 	image_data: an image velocity matrix, including the image location of each vector (x, y), the velocity on the x-axis and y-axis respectively and the magnitude of speed.
%-------------------------------------------------------------------------

function image_data = Cal_Image_Vectors(env_dots, T,  pF, img_w, img_h)

nDots = size(env_dots, 1);

% Calculate the position of the dots on the image plane
image_x = env_dots(:, 1)./env_dots(:, 3);
image_y = env_dots(:, 2)./env_dots(:, 3);

% Calculate the velocity elements on the x-axis and y-axis on the image plane
image_vx = (env_dots(:, 1).* T(3) - env_dots(:, 3).* T(1) + T(1) * pF * (env_dots(:, 1).^2 + env_dots(:, 3).^2))./env_dots(:, 3).^2;
image_vy = (env_dots(:, 2).* T(3) - env_dots(:, 3).* T(2) + T(1) * pF * (env_dots(:, 1) .* env_dots(:, 2)))./env_dots(:, 3).^2;

h_rst_id = find(env_dots(:, 4) == 1); 	% Find out those sampled dots along a horizontal line.
r_rst_id = find(env_dots(:, 4) == 2); 	% Find out those sampled dots along a vertical line.

if ~isempty(h_rst_id)
    image_vx(h_rst_id) = 0; 						% For those dots on a horizontal line, make the image speed on the x-axis to be 0.
end

if ~isempty(r_rst_id)
    image_vy(r_rst_id) = 0; 						% For those dots on a vertical line, make the image speed on the y-axis to be 0.
end

image_v  = sqrt(image_vx.^2 + image_vy.^2);

% Calculate the direction of the velocity vector
image_dir = atand(image_vx./image_vy);

% Make the value of the direction to be within the range [0, 360]
for i = 1:nDots
    if image_vy(i) < 0
        image_dir(i) = image_dir(i) + 180;
    elseif image_vx(i) < 0
        image_dir(i) = image_dir(i) + 360;
    end
end

% Put together
image_data = NaN(nDots, 8);

image_data(:, 1) = image_x;
image_data(:, 2) = image_y;
image_data(:, 3) = image_vx;
image_data(:, 4) = image_vy;
image_data(:, 5) = image_v;
image_data(:, 6) = image_dir;
image_data(:, 7) = env_dots(:, 4);
image_data(:, 8) = env_dots(:, 3);

% Exclude those outside the vision
vf_x = tand(img_w/2); vf_y = tand(img_h/2);

image_data = image_data(image_data(:, 1) >= -vf_x & image_data(:, 1) <= vf_x & image_data(:, 2) >= -vf_y & image_data(:, 2) <= vf_y, :);

end
