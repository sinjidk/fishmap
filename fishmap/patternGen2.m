close all; clear; clc;

darkLevel = 0.5;
spacing = 16;
width = 4;
center = 1024.5;

patterns =  ones(2048, 2048, 3, 12);
blankPattern = ones(2048, 2048, 3);

patternAngles = [{[]}, ...
    {45}, ... % sea
    {-45}, ... % red
    {90}, ... % magenta
    {0}, ... % green
    {-45}, ... % porp
    {45}, ... % clay
    {[0 90]}, ... % blue
    {0}, ... % mauve
    {[45 -45]}, ... % cyan
    {90}, ... % dark green
    {[]}];

baseLine = -2047:spacing:4096;
% offset = center - spacing/2 - median(baseLine);
offset = 0;
baseLine = [repmat(center, size(baseLine)); offset+baseLine; ones(size(baseLine))];
for iP = 1:length(patternAngles)
    angles = patternAngles{iP};
    pattern = blankPattern;
    for angle = angles
        rotMatrix = [cosd(angle) -sind(angle) -center*cosd(angle)+center*sind(angle)+center; 
            sind(angle) cosd(angle) -center*sind(angle)-center*cosd(angle)+center];
        centerLine = (rotMatrix*baseLine)';
        offsetPoint = (rotMatrix*[-2048; center; 1])'-[center center];
        pattern = insertShape(pattern,"line",[centerLine+offsetPoint, ...
            centerLine-offsetPoint], ...
            "LineWidth", width, "ShapeColor", 'k');
    end

    % pattern = insertShape(pattern, "circle", [center center 7.5]);
    % figure; imshow(pattern)
    patterns(:, :, :, iP) = pattern*(1-darkLevel)+darkLevel;
end

save patterns patterns