close all; clear; clc;

darkLevel = 0.5;

% patterns = double(cat(4, 1+imread("blank.png"), ...
%     imread("diagonal.png"), ... % green
%     imread("confetti.png"), ... % magenta
%     imread("plaid.png"), ... % sea
%     imread("brick.png"), ... % red
%     imread("checkerboard.png"), ... % porp
%     imread("bubble.png"), ... % clay
%     imread("wave.png"), ... % cyan
%     imread("grid.png"), ... % blue
%     1-imread("trellis.png"), ... % other green
%     1-imread("shingles.png"), ... % mauve
%     1+imread("blank.png")));

patternName = ["blank.png", ...
    "forward diagonal.png", ... % sea
    "backwards diagonal.png", ... % red
    "vertical.png", ... % magenta
    "horizontal.png", ... % green
    "large grid.png", ... % porp
    "forward diagonal.png", ... % clay
    "backwards diagonal.png", ... % blue
    "horizontal.png", ... % mauve
    "diagonal cross.png", ... % cyan
    "vertical.png", ... % dark green
    "blank.png"];

patterns =  zeros(2048, 2048, 3, 12);
for iP = 1:length(patternName)
    [X, map] = imread(patternName(iP));
    pattern = double(ind2rgb(X, map));
    % patternMax = max(pattern, [], 'all');
    patterns(:, :, :, iP) = pattern*(1-darkLevel)+darkLevel;
end

save patterns patterns