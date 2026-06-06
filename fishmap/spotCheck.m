close all; clear; clc;

load spots spots

spotMasks = {dir(matlab.project.rootProject().RootFolder+"\spots\masks\").name};

for iS = 1:height(spots)
    if ~any(strcmp(spotMasks, sprintf("map%d_spot%d_mask.png", spots.MapID(iS), spots.SpotID(iS))))
        sprintf("No spot mask for %s : %s", spots.MapName(iS), spots.SpotName(iS))
    end
end


spotMaps = {dir(matlab.project.rootProject().RootFolder+"\spots\maps\").name};

for iS = 1:height(spots)
    if ~any(strcmp(spotMaps, sprintf("map%d_spot%d_map.png", spots.MapID(iS), spots.SpotID(iS))))
        sprintf("No spot map for %s : %s", spots.MapName(iS), spots.SpotName(iS))
    end
end

%%
[~, ia, ~] = unique(spots(:, ["LayerName", "MapName"]), "rows");
[~, is] = sort(spots.SpotID(ia));
files = "D:\Documents\MATLAB\fishmap\spots\maps\"+compose("map%d_spot%d_map.png", spots.MapID(ia(is)), spots.SpotID(ia(is)));
files(~isfile(files)) = [];
montage(files);