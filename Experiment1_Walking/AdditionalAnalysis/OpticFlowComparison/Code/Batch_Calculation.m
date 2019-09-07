
clear all;
thisCondition = 'Line'; 
Cal_Flow_Info(thisCondition)
% In this condition there are 0 pairs of motion parallax.

clear all;
thisCondition = 'Cloud'; 
Cal_Flow_Info(thisCondition)
% In the Cloud condition there are 34 pairs of motion parallax.

clear all;
thisCondition = 'Outline'; 
Cal_Flow_Info(thisCondition)
% In the Outline condition there are 0 pairs of motion parallax.

clear all;
thisCondition = 'Room'; 
Cal_Flow_Info(thisCondition)
% In the Room condition there are 0 pairs of motion parallax.


%% Calculate the interquartile of speed magnitude at specific eccentricity 

scenes = {'Line', 'Outline', 'Cloud', 'Room'};
eccnts = [1, 2, 5, 10, 15, 20, 30];
eccnt_width = 0.5;

mean_speeds = zeros(length(scenes) * length(eccnts), 1);
interquartiles = zeros(length(scenes) * length(eccnts), 1);
in_which_scene = cell(length(scenes) * length(eccnts), 1);
at_which_eccnts = zeros(length(scenes) * length(eccnts), 1);
within_width = zeros(length(scenes) * length(eccnts), 1);

i = 1;
for this_condition = scenes
    for this_eccnts = eccnts
        [m, q] = Cal_Quartiles(char(this_condition), this_eccnts);
        mean_speeds(i) = m;
        interquartiles(i) = q;
        in_which_scene(i) = this_condition;
        at_which_eccnts(i) = this_eccnts;
        within_width(i) = eccnt_width;
        i = i + 1;
    end
end

quartiles = table(in_which_scene, at_which_eccnts, within_width, mean_speeds, interquartiles, 'VariableNames', {'Scene', 'Eccentricity', 'EccentricityWidth', 'Mean', 'Interquartile'});

writetable(quartiles, 'quartiles.csv', 'delimiter', ',')
        