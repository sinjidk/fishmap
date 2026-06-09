close all; clear; clc;

spotData = readtable("FishingSpot.csv");
placeData = readtable("PlaceName.csv");
mapData = readtable("Map.csv");
overrideData = readtable("spotOverrides.csv");

%% Implement overrides
for iO = 1:height(overrideData)
    override = overrideData(iO, :);
    if ~override.IsCurrent || override.IsEmpty
        spotData(spotData.x_ == override.SpotID, :) = [];
    end

    spotData.TerritoryType(spotData.x_ == override.SpotID) = override.TerritoryOverride;
end

%% Build info
spots = table('Size', [0, 9], 'VariableNames', ["SpotID", "MapID", "SpotName", "MapName", "LayerName", "JumpName", "SpotX", "SpotY", "MapMarkerRange"], 'VariableTypes', ["uint16", "uint16", "string", "string", "string", "string", "uint16", "uint16", "uint16"]);

iS = 0;
% the loop is weird and upside down because of obsolete restrictions, no longer needs to be this way but I'm too lazy to change it
while iS < height(spotData)
    spot = spotData(end-iS, :);
    spotName = placeData.Name{spot.PlaceName == placeData.x_};
    
    spotMaps = mapData(mapData.TerritoryType == spot.TerritoryType, :);
    for iM = height(spotMaps):-1:1
        map = spotMaps(iM, :);

        jumpName = replace(lower(placeData.Name{map.PlaceName == placeData.x_}), {' ', '''', '*'}, '');

        if strcmp(spot.Rare, 'True')
            spots(end+1, :) = {spot.x_, map.x_, spotName, placeData.Name{map.PlaceName == placeData.x_}, sprintf("%s (Lv. %d)", spotName, spot.GatheringLevel), jumpName, spot.X, spot.Z, map.MapMarkerRange};
        else
            spots(end+1, :) = {spot.x_, map.x_, spotName, placeData.Name{map.PlaceName == placeData.x_}, spotName, jumpName, spot.X, spot.Z, map.MapMarkerRange};
        end
    end
    
    iS = iS+1;
end
    
spots = flipud(spots);

%% Make manual corrections
spots(spots.MapID == 209, :) = []; % No fishing indoors
spots(spots.MapID == 180, :) = []; % No fishing indoors
spots(spots.MapID == 105, :) = []; % No fishing indoors
spots(spots.MapID == 548, :) = []; % No fishing indoors
spots(spots.MapID == 74, :) = []; % No fishing indoors
spots(spots.MapID == 549, :) = []; % No fishing indoors
spots(spots.MapID == 181, :) = []; % Who are you?
spots(spots.MapID == 93, :) = []; % No fishing indoors
spots.LayerName(spots.MapID == 192) = "Mist (Subdivision)";
spots.MapName(spots.MapID == 192) = "Mist Subdivision";
spots.JumpName(spots.MapID == 192) = "mistsubdivision";
spots.LayerName(spots.MapID == 193) = "The Lavender Beds (Subdivision)";
spots.MapName(spots.MapID == 193) = "The Lavender Beds Subdivision";
spots.JumpName(spots.MapID == 193) = "thelavenderbedssubdivision";
spots.LayerName(spots.MapID == 194) = "The Goblet (Subdivision)";
spots.MapName(spots.MapID == 194) = "The Goblet Subdivision";
spots.JumpName(spots.MapID == 194) = "thegobletsubdivision";
spots.LayerName(spots.SpotID == 107) = "Privateer Forecastle";
spots.LayerName(spots.SpotID == 108) = "Privateer Sterncastle (Lv. 50)";
spots.LayerName(spots.SpotID == 109) = "Riversmeet (under ridges)";
spots.LayerName(spots.SpotID == 115) = "Ashpool (under ridge)";
spots.LayerName(spots.SpotID == 121) = "Mourn (in mountain)";
spots.LayerName(spots.SpotID == 123) = "Anyx Old (in mountain)";
spots.LayerName(spots.MapID == 365 & spots.SpotID == 197) = "Shirogane (Subdivision)";
spots.LayerName(spots.MapID == 365 & spots.SpotID == 198) = "The Silver Canal (Lv. 65) (Subdivision)";
spots.MapName(spots.MapID == 365) = "Shirogane Subdivision";
spots.JumpName(spots.MapID == 365) = "shiroganesubdivision";
spots(spots.MapID == 554, :) = []; % No fishing indoors
spots.MapName(spots.MapID == 498) = "Eulmore (The Buttress)";
spots.MapName(spots.MapID == 555) = "Eulmore (The Canopy)";
spots.LayerName(spots.SpotID == 214 & spots.MapID == 555) = "The Derelicts (The Canopy)";
spots.JumpName(spots.MapID == 555) = "thecanopy";
spots(spots.MapID == 550, :) = []; % No fishing indoors
spots(spots.MapID == 551, :) = []; % No fishing indoors
spots.LayerName(spots.SpotID == 236) = "The Norvrandt Slope (underground)";
spots.LayerName(spots.MapID == 604) = "The Endeavor";
spots.LayerName(spots.SpotID == 265) = "Wakeful Torana";
spots(spots.MapID == 750, :) = []; % The maps are identical, I will keep current version
spots.LayerName(spots.SpotID == 274) = "The Frozen Fissure (underground)";
spots(spots.MapName == "Elysion" & spots.MapID ~= 801, :) = []; % Only keep final version
spots(spots.MapName == "Sinus Ardorum" & spots.MapID ~= 1031, :) = []; % Only keep final version
spots(spots.MapName == "Phaenna" & spots.MapID ~= 1086, :) = []; % Only keep final version
spots(spots.MapName == "Oizys" & spots.MapID ~= 1160, :) = []; % Only keep final version
spots(spots.MapName == "Auxesia" & spots.MapID ~= 1266, :) = []; % Only keep final version
spots.LayerName(any(spots.SpotID == [10121 10139 10140], 2)) = "Upper SL Float";
spots.LayerName(any(spots.SpotID == [10122 10133 10141 10142], 2)) = "Central SL Channel";
spots.LayerName(any(spots.SpotID == [10123 10134 10143], 2)) = "Western SL Tributary";
spots.LayerName(any(spots.SpotID == [10124 10135 10144 10147], 2)) = "Lower SL Float";

%%
save spots spots
writetable(spots, "spots.csv")