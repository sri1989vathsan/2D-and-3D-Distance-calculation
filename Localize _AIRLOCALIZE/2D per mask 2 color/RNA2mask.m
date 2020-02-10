% Start with a folder and get a list of all subfolders.
% Finds and prints names of all PNG, JPG, and TIF images in
% that folder and all of its subfolders.

clc;% Clear the command window
clear;
workspace;  % Make sure the workspace panel is showing.
format longg;
format compact;
radius = 300; %radius of inclusion (for two channels)
dist = 100; %radius of exclusion (for the same channel)
alchk = 0; % 1 if you want to check alignment, 0 if you don't
mask1 = 'Cymask.tif'; %cytoplasmidc mask file name
mrnafile = 'Cy5.loc'; %Cy5 max projection file name

RNA_coloc2smask(mask1, mrnafile);

cprintf('Comments','Done\n')
