close all; clear; clc;

spotData = readtable("FishingSpot.csv");
placeData = readtable("PlaceName.csv");
mapData = readtable("Map.csv");

%% Remove inactive spots
spotData(spotData.PlaceName == 0, :) = [];
spotData(spotData.Item_0_ == 0, :) = [];
spotData(any(spotData.x_ == 147:154, 2), :) = []; % Old Diadem
spotData(any(spotData.x_ == 10001:10016, 2), :) = []; % Old Diadem

%% Set undefined territories
spotData.TerritoryType(spotData.PlaceName == 2507) = 759; % Doman Enclave
spotData.TerritoryType(any(spotData.PlaceName == [2258 2259 2261 2262 2263 2264 3489 3532 3533], 2)) = 901; % Diadem
spotData.TerritoryType(any(spotData.PlaceName == [4191 4192 4193 4194 4195], 2)) = 1073; % Elysion
spotData.TerritoryType(any(spotData.PlaceName == [5206 5207 5208 5209 5210 5211 5212 5213 5214], 2)) = 1237; % Sinus Ardorum
spotData.TerritoryType(any(spotData.PlaceName == [5286 5287 5288 5289 5290 5291 5292 5293 5294 5295 5296], 2)) = 1291; % Phaenna
spotData.TerritoryType(any(spotData.PlaceName == [5425 5426 5427 5428 5429 5430 5431], 2)) = 1310; % Oizys
spotData.TerritoryType(any(spotData.PlaceName == [5537 5538 5539 5540 5541 5542 5543 5544], 2)) = 1319; % Auxesia

%% Build info
spots = table('Size', [0, 5], 'VariableNames', ["SpotID", "MapID", "SpotName", "MapName", "LayerName"], 'VariableTypes', ["uint16", "uint16", "string", "string", "string"]);

iS = 0;
% the loop is weird and upside down because of obsolete restrictions, no longer needs to be this way but I'm too lazy to change it
while iS < height(spotData)
    spot = spotData(end-iS, :);
    spotName = placeData.Name{spot.PlaceName == placeData.x_};
    
    spotMaps = mapData(mapData.TerritoryType == spot.TerritoryType, :);
    for iM = height(spotMaps):-1:1
        map = spotMaps(iM, :);

        if strcmp(spot.Rare, 'True')
            spots(end+1, :) = {spot.x_, map.x_, spotName, placeData.Name{map.PlaceName == placeData.x_}, sprintf("%s (Lv. %d)", spotName, spot.GatheringLevel)};
        else
            spots(end+1, :) = {spot.x_, map.x_, spotName, placeData.Name{map.PlaceName == placeData.x_}, spotName};
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
spots(spots.MapID == 192, :) = []; % Not using subdivision
spots(spots.MapID == 193, :) = []; % Not using subdivision
spots(spots.MapID == 194, :) = []; % Not using subdivision
spots.LayerName(spots.SpotID == 107) = "Privateer Forecastle";
spots.LayerName(spots.SpotID == 108) = "Privateer Sterncastle (Lv. 50)";
spots.LayerName(spots.SpotID == 109) = "Riversmeet (under ridges)";
spots.LayerName(spots.SpotID == 115) = "Ashpool (under ridge)";
spots.LayerName(spots.SpotID == 121) = "Mourn (in mountain)";
spots.LayerName(spots.SpotID == 123) = "Anyx Old (in mountain)";
spots(spots.MapID == 365, :) = []; % Not using subdivision
spots(spots.MapID == 554, :) = []; % No fishing indoors
spots.LayerName(spots.SpotID == 214 & spots.MapID == 555) = "The Derelicts (The Canopy)";
spots(spots.MapID == 550, :) = []; % No fishing indoors
spots(spots.MapID == 551, :) = []; % No fishing indoors
spots.LayerName(spots.SpotID == 236) = "The Norvrandt Slope (underground)";
spots.LayerName(spots.MapID == 604) = "The Endeavor"; % Boat not in scope
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