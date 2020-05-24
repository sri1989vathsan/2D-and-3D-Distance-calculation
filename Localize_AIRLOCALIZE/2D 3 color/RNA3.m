%%% The script analyzes "3 color smFISH" data within subfolders and saves
%%% the output within those subfolders

%%% Each subfolder should contain a list of files required for analysis
%%% within the subfolder - 5p.loc, 3p.loc and mid.loc corresponding to the
%%% localization files for the signals from 5' 3' and middle regions of
%%% the mRNA and Cymask.tif, Nucmask.tif which are the cytoplasmic and
%%% nuclear masks respsectively

%%% The output is saved within subfolders - 'Cytoplasmic Distances.csv' and
%%% 'Nuclear Distances.csv' contain distance information, 'Cytoplasmic
%%% Absolute Coordinates.csv' and 'Nuclear Absolute Coordinates.csv'
%%% (in pixels) contains the coordinates for the localized spots and
%%% 'Cytoplasmic Relative Coordinates.csv' and 'Nuclear Relative
%%% Coordinates.csv' (in nm) contains the relatved coordinates with
%%% respect to the reference

%%% The combined data is saved as 'Nuclear Distances All.csv', 'Cytoplasmic
%%% Distances All.csv', 'Cytoplasmic Absolute Coordinates All.csv',
%%% 'Nuclear Absolute Coordinates.csv', 'Cytoplasmic Relative Coordinates
%%% All.csv' and 'Nuclear Relative Coordinates All.csv' in the parent
%%% folder

%%% Open Example Files/3 color and run this file within that folder as an
%%% example

clc;% Clear the command window
clear;
workspace;  % Make sure the workspace panel is showing.
format long;
pixelsize = 39.682539;
radius = 300; % radius of exclusion (for the same channel)
dist = 100; % radius of inclusion (for two different channels)
mask1 = 'Cymask.tif'; % cytoplasmic mask file name
mask2 = 'Nucmask.tif'; % use '' in case there is only one mask
%filenames for the three signals from within the same mRNA
mrnafile = ["5p.loc"; "mid.loc"; "3p.loc"];
%%% reference used to allocate spots from other channels are neighbours.
%%% Available options: '5p', '3p' and 'mid'. For eg. If 'mid' is set as
%%% reference then the spots within the mid channel will be used to
%%% neighbouring spots within the 5p and 3p channels
reference=["mid"];

topLevelFolder = pwd; %current working directory
allSubFolders = genpath(topLevelFolder);

% Parse into a cell array.
remain = allSubFolders;
listOfFolderNames = {};

%%% Generate list of subfolders
while true
    [singleSubFolder, remain] = strtok(remain, ';');
    if isempty(singleSubFolder)
        break;
    end
    listOfFolderNames = [listOfFolderNames singleSubFolder];
end
numberOfFolders = length(listOfFolderNames);

%%% Check if there exists subfolders
if numberOfFolders == 1
    cprintf('err','error: No subfolders\n');
    return
end

nucdists = {};
cytdists = {};
nucposs = {};
cytposs = {};
nucrelposs = {};
cytrelposs = {};

% Process all image files in those folders.
for k = 1 : numberOfFolders-1
    
    thisFolder = listOfFolderNames{k+1};
    cd(thisFolder)
    %% Analyze data within the subfolder
    if exist('3p.loc', 'file') == 2 && exist('Cymask.tif','file') == 2
        [nucdist,cytdist,nucpos,cytpos,nucrelpos,cytrelpos] = ...
            RNA_coloc3(mask1, mask2, mrnafile, pixelsize, ...
            radius, dist,reference);
    else
        cprintf('err','No files to process\n')
    end
    
    nucdists = [nucdists;nucdist];
    cytdists = [cytdists;cytdist];
    nucposs = [nucposs;nucpos];
    cytposs = [cytposs;cytpos];
    nucrelposs = [nucrelposs;nucrelpos];
    cytrelposs = [cytrelposs;cytrelpos];
    
    cd ..
end

cell2csv('Cytoplasmic Distances All.csv',cytdists,',');
cell2csv('Cytoplasmic Absolute Coordinates All.csv',cytposs);
cell2csv('Cytoplasmic Relative Coordinates All.csv',cytrelposs);

cell2csv('Nuclear Distances All.csv',nucdists,',');
cell2csv('Nuclear Absolute Coordinates All.csv',nucposs);
cell2csv('Nuclear Relative Coordinates All.csv',nucrelposs);

cprintf('Comments','Done\n')
