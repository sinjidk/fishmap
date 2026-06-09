close all; clear; clc;

warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')

folders = dir;
folders = folders([folders.isdir]);
folders = folders(3:end);

for iF = 1:length(folders)
    if exist(folders(iF).name + "/generateThisMap.m", "file")
        run(folders(iF).name + "/generateThisMap.m")
    end
end