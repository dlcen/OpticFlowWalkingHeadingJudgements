clc; clear all

meanErr = readtable('../Data/Female_Trial1_MeanErr_4m.csv');

combNo  = 20000;
grpSize = 41

permutation_grp = cell2mat(arrayfun(@(dummy) sort(randperm(grpSize, 7)), 1:combNo, 'UniformOutput', false)');
permutation_grp = unique(permutation_grp, 'rows');

if size(permutation_grp, 1) < combNo
    while size(permutation_grp, 1) < combNo
        chs_grp  = sort(randperm(grpSize, 7));
        [l, c]   = ismember(chs_grp, permutation_grp, 'rows');
        if c == 0
            permutation_grp = [permutation_grp; chs_grp];
        end
    end
end

permutation_grp = reshape(permutation_grp, 1, combNo * 7);

rowIdx = repmat([1:combNo], 1, 7); 

combIdx = sub2ind([combNo, grpSize], rowIdx, permutation_grp);

Scenes = {'Line', 'Outline', 'DotCloud', 'Room'};
combMean = zeros(combNo, 4);

for i = 1:4

	thisScene = Scenes{i};

	thisData = meanErr.meanErr(strcmp(meanErr.Scene, thisScene));

	thisDataGrid = repmat(thisData, 1, combNo);
	thisDataGrid = thisDataGrid.';

	thisCombData = thisDataGrid(combIdx);
	thisCombData = reshape(thisCombData, combNo, 7);

	combMean(:, i) = mean(thisCombData, 2);
end 

combTalbe = array2table(combMean, 'VariableNames', Scenes);

writetable(combTalbe, '../Data/Female_Trial1_MeanErr_Combinations.csv', 'Delimiter',',','QuoteStrings',true);
