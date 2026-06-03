close all; clear; clc;

load spots spots

spotMaps = {dir(matlab.project.rootProject().RootFolder+"\spots\").name};

for iS = 1:height(spots)
    if ~any(strcmp(spotMaps, sprintf("map%d_spot%d_mask.png", spots.MapID(iS), spots.SpotID(iS))))
        sprintf("No spot map for %s : %s", spots.MapName(iS), spots.SpotName(iS))
    end
end