close all; clear; clc;

spotData = readtable("FishingSpot.csv");

spotOverrides = table('Size', [height(spotData), 5], 'VariableNames', ["SpotID", "TerritoryOverride", "IsEmpty", "IsCurrent", "Description"], 'VariableTypes', ["uint16", "uint16", "logical", "logical", "string"]);
spotOverrides.SpotID = spotData.x_;
spotOverrides.IsCurrent(:) = true;

%% Define overrides
spotOverrides.Description(~any(spotData{:, 5:25}, 2)) = "Null row";
spotOverrides.Description(1) = "Undiscovered Fishing Hole";
spotOverrides.IsCurrent(2) = false;
spotOverrides.Description(2) = "?Dev Test Case?";
spotOverrides.IsEmpty = spotData.Item_0_ == 0;
spotOverrides.IsCurrent(~any(spotData{:, 5:25}, 2)) = false;
spotOverrides.IsCurrent(any(spotData.x_ == 147:154, 2), :) = false;
spotOverrides.TerritoryOverride(any(spotData.PlaceName == [2258 2259 2261 2262 2263 2264 3489 3532 3533], 2)) = 901;
spotOverrides.Description(any(spotData.PlaceName == [2258 2259 2261 2262 2263 2264 3489 3532 3533], 2)) = "Current Diadem";
spotOverrides.TerritoryOverride(any(spotData.PlaceName == [2257 2260], 2)) = 901;
spotOverrides.Description(any(spotData.PlaceName == [2258 2259 2261 2262 2263 2264 3489 3532 3533], 2)) = "Current Diadem";
spotOverrides.Description(any(spotData.x_ == 147:154, 2), :) = "Old Diadem";
spotOverrides.IsCurrent(any(spotData.x_ == 10001:10016, 2), :) = false;
spotOverrides.Description(any(spotData.x_ == 10001:10016, 2), :) = "Old Diadem";
spotOverrides.TerritoryOverride(spotData.PlaceName == 2507) = 759;
spotOverrides.Description(spotData.PlaceName == 2507) = "The Doman Enclave";
spotOverrides.TerritoryOverride(any(spotData.PlaceName == [4191 4192 4193 4194 4195], 2)) = 1073;
spotOverrides.Description(any(spotData.PlaceName == [4191 4192 4193 4194 4195], 2)) = "Elysion";
spotOverrides.TerritoryOverride(any(spotData.PlaceName == [5206 5207 5208 5209 5210 5211 5212 5213 5214], 2)) = 1237;
spotOverrides.Description(any(spotData.PlaceName == [5206 5207 5208 5209 5210 5211 5212 5213 5214], 2)) = "Sinus Ardorum";
spotOverrides.TerritoryOverride(any(spotData.PlaceName == [5286 5287 5288 5289 5290 5291 5292 5293 5294 5295 5296], 2)) = 1291;
spotOverrides.Description(any(spotData.PlaceName == [5286 5287 5288 5289 5290 5291 5292 5293 5294 5295 5296], 2)) = "Phaenna";
spotOverrides.TerritoryOverride(any(spotData.PlaceName == [5425 5426 5427 5428 5429 5430 5431], 2)) = 1310;
spotOverrides.Description(any(spotData.PlaceName == [5425 5426 5427 5428 5429 5430 5431], 2)) = "Oizys";
spotOverrides.TerritoryOverride(any(spotData.PlaceName == [5537 5538 5539 5540 5541 5542 5543 5544], 2)) = 1319;
spotOverrides.Description(any(spotData.PlaceName == [5537 5538 5539 5540 5541 5542 5543 5544], 2)) = "Auxesia";

%% Trim list
spotOverrides(spotOverrides.TerritoryOverride == 0 & ~spotOverrides.IsEmpty & spotOverrides.IsCurrent, :) = [];
spotOverrides.Properties.Description = "FFXIV version 7.51";
writetable(spotOverrides, "spotOverrides.csv");