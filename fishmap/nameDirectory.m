close all; clear; clc;


%% Spearfishing nodes
spearData = readtable("SpearfishingNotebook.csv");
placeData = readtable("PlaceName.csv");
mapData = readtable("Map.csv");

spears = table('Size', [0, 4], 'VariableNames', ["SpearID", "MapID", "SpearName", "MapName"], 'VariableTypes', ["uint16", "uint16", "string", "string"]);

for iS = 1:height(spearData)
    spear = spearData(iS, :);
    spearName = placeData.Name{spear.PlaceName == placeData.x_};
    
    spearMaps = mapData(mapData.TerritoryType == spear.TerritoryType, :);
    for iM = height(spearMaps):-1:1
        map = spearMaps(iM, :);

        if strcmp(spear.IsShadowNode, 'True')
            spears(end+1, :) = {spear.x_, map.x_, spearName + " (Hidden Spearfishing)", placeData.Name{map.PlaceName == placeData.x_}};
        else
            spears(end+1, :) = {spear.x_, map.x_, spearName + " (Spearfishing)", placeData.Name{map.PlaceName == placeData.x_}};
        end
    end
end

%% Make manual corrections
spears(spears.MapID == 551, :) = []; % No fishing indoors

%% Generate directory
load spots.mat spots

directory = unique([compose("%s\n%s\n\n", spears.SpearName, spears.MapName);
    compose("%s\n[%s](#%s)\n\n", spots.SpotName, spots.MapName, spots.JumpName)]);

[~, iSort] = sort(replace(directory, '*', ''));
directory = directory(iSort);

d1 = join(directory(1:floor(end/2)), '');
d2 = join(directory((floor(end/2)+1):end), '');