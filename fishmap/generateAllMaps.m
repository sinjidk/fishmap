close all; clear; clc;

folders = dir;
folders = folders([folders.isdir]);
folders = folders(3:end);

for iF = 1:length(folders)
    run(folders(iF).name + "/mapSettings.m")
end