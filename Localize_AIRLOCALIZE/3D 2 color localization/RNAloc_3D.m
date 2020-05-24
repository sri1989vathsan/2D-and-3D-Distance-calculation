%%% The script analyzes "2 color smFISH" for 3D data within subfolders and
%%% saves the output within those subfolders

%%% Each subfolder should contain a list of files required for analysis
%%% within the subfolder - Cy5.loc3, Cy3.loc3, corresponding to signals from
%%% two regions of the mRNA (eg 5' and 3') and Cymask.tif, Nucmask.tif
%%% which represent the cytoplasmic and nuclear masks respectively. By
%%% default Cy5 is assumed as the 5' spot and Cy3 the 3' spot and Cy5
%%% signal is used as refernce to identify nearby Cy3 spots.

%%% The output is saved within subfolders - 'Distances.csv'
%%% contains distance information
%%% All saved ~Distances.csv files have 10 columns
%%% Column 1 -> index
%%% Column 2,3 -> intensities of localizes spots (spot1 and spot2)
%%% Column 4 -> Distance
%%% Column 5, 6 and 8 -> Coordinates for spot1
%%% Column 8, 9 and 10 -> Coordinates for spot2

%%% The combined data is saved as 'Values.csv'
%%% This contains 7 columns - 1,2,3 coordinates for spot1, 4,5,6
%%% coordinates for spot2 and 7 - distance

%%% Open 'Example Files/2 color 3D loc' and run this file within that folder as an
%%% example

clc;% Clear the command window
clear;
workspace;  % Make sure the workspace panel is showing.
format long;
pixelsize = 39.682539; %% X-Y Pixel Size
zpixelsize = 180; %% Z Stack depth
radius = 400; %radius of inclusion (for two channels)
dist = 100; %radius of exclusion (for the same channel)
mask1 = 'Cymask.tif'; %cytoplasmidc mask file name
mask2 = 'Nucmask.tif'; % use '' in case there is only one mask
mrna5file = 'Cy5.loc3'; %Cy5 max projection file name
mrna3file = 'Cy3.loc3'; %Cy3 max projection file name

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
listOfFolderNames = natsortfiles(listOfFolderNames);
if numberOfFolders == 1
    cprintf('err','error: No subfolders\n');
    return
end

%%% Initializing variables to store data from all subfolders
vals = [];

% Process all image files in those folders.
for k = 1 : numberOfFolders-1
    thisFolder = listOfFolderNames{k+1};
    cd(thisFolder)
    %% Analyze data within the subfolder    
    [val] = RNA_coloc2loc_3D(mask1, mask2, mrna5file, ...
        mrna3file, pixelsize, zpixelsize, radius, dist);
    vals = [vals;val];
    
    cd ..
end

%% Writing combined data from all fields
csvwrite('Values.csv',vals);

cprintf('Comments','Done\n')