close all; clear; clc;

load spots spots

spotMasks = {dir(matlab.project.rootProject().RootFolder+"\spots\masks\").name};

for iS = 1:height(spots)
    if ~any(strcmp(spotMasks, sprintf("map%d_spot%d_mask.png", spots.MapID(iS), spots.SpotID(iS))))
        sprintf("No spot mask for %s : %s", spots.MapName(iS), spots.LayerName(iS))
    end
end


spotMaps = {dir(matlab.project.rootProject().RootFolder+"\spots\maps\").name};

for iS = 1:height(spots)
    if ~any(strcmp(spotMaps, sprintf("map%d_spot%d_map.png", spots.MapID(iS), spots.SpotID(iS))))
        sprintf("No spot map for %s : %s", spots.MapName(iS), spots.LayerName(iS))
    end
end

%% check files
[~, ia, ~] = unique(spots(:, ["LayerName", "MapName"]), "rows");
[~, is] = sortrows(spots(ia, ["MapID", "SpotID"]));
mapFiles = matlab.project.rootProject().RootFolder+"\spots\maps\"+compose("map%d_spot%d_map.png", spots.MapID(ia(is)), spots.SpotID(ia(is)));
mapFiles(~isfile(mapFiles)) = [];
maskFiles = matlab.project.rootProject().RootFolder+"\spots\masks\"+compose("map%d_spot%d_mask.png", spots.MapID(ia(is)), spots.SpotID(ia(is)));
maskFiles(~isfile(maskFiles)) = [];
imSizes = zeros(size(mapFiles));
spotSizes = zeros(size(maskFiles));
for iF = 1:length(mapFiles)
    imSizes(iF) = length(imread(mapFiles(iF)));
    spotSizes(iF) = sum(imread(maskFiles(iF)) > 0, 'all');
end

figure; histogram(imSizes, [511.5 512.5:10.0196:1023.5 1024.5:10:2048.5], "Normalization", "percentage")
xlabel("Map Size")
ylabel("Percent of maps with size")

figure; h = scatterhist(spotSizes, imSizes);
xlabel("Area of Spot Mask")
ylabel("Spot Map Size")
set(gcf, 'Color', 'w')
grid on
yticks(512:512:2048)
set(gca, "XScale", "log")
set(h(2), "XScale", "log")

%% montage
figure;
img = montage(mapFiles);
imwrite(img.CData, matlab.project.rootProject().RootFolder+"\spots\montage.png")