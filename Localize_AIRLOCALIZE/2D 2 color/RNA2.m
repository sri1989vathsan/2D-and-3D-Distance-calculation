%%% The script analyzes "2 color smFISH" data within subfolders and saves 
%%% the output within those subfolders

%%% Each subfolder should contain a list of files required for analysis
%%% within the subfolder - Cy5.loc, Cy3.loc, corresponding to signals from
%%% two regions of the mRNA (eg 5' and 3') and Cymask.tif, Nucmask.tif
%%% which represent the cytoplasmic and nuclear masks respectively. By
%%% default Cy5 is assumed as the 5' spot and Cy3 the 3' spot and Cy5
%%% signal is used as refernce to identify nearby Cy3 spots.

%%% The output is saved within subfolders - 'Cytoplasmic Distances.csv' and
%%% 'Nuclear Distances.csv' contain distance information

%%% The combined data is saved as 'Nuclear Values.csv', 'Cytoplasmic
%%% Values.csv'

%%% Open Example Files/2 color and run this file within that folder as an
%%% example

clc; % Clear the command window
clear; % Clears the workspace
workspace;  % Make sure the workspace panel is showing.
format long; % Increase decimal places for your variables
pixelsize = 39.682539; %Size of pixel for your dataset
radius = 300; % Radius of inclusion (for two channels)
dist = 100; % Radius of exclusion (for the same channel) - to exclude other
            % signals within the radius from the same channel
mask1 = 'Cymask.tif'; % cytoplasmic mask file name
mask2 = 'Nucmask.tif'; % use '' in case there is only one mask
mrna5file = 'Cy5.loc'; % Cy5 max projection file name
mrna3file = 'Cy3.loc'; % Cy3 max projection file name

topLevelFolder = pwd; % current working directory
allSubFolders = genpath(topLevelFolder);

%%% Parse into a cell array.
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
nucvals = [];
cytvals = [];

%%% Process all image files in those folders.
for k = 1 : numberOfFolders-1
    % Get this folder and print it out.
    thisFolder = listOfFolderNames{k+1};
    cd(thisFolder)
    %% Analyze data within the subfolder
    [cytval,nucval] = RNA_coloc2s(mask1, mask2, mrna5file, mrna3file, ...
        pixelsize, radius, dist,nucval,cytval);
    nucvals = [nucvals;nucval];
    cytvals = [cytvals;cytval];
    cd ..
end

%% Writing combined data from all fields
csvwrite('Cytoplasmic Values.csv',cytvals);
csvwrite('Nuclear Values.csv',nucvals);

cprintf('Comments','Done\n')