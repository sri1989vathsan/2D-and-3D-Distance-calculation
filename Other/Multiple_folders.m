% Start with a folder and get a list of all subfolders.
% Finds and prints names of all PNG, JPG, and TIF images in 
% that folder and all of its subfolders.
clc;% Clear the command window
clear; 
workspace;  % Make sure the workspace panel is showing.
format longg;
format compact;
pixelsize = 39.682539;
radius = 300;
dist = 300;
alchk = 1; % 1 if you want to check alignment, 0 if you don't
  mask1 = 'Cymask.tif';
    mask2 = '';
    mrna5file = 'Cy5.loc';
    mrna3file = 'Cy3.loc';

% Define a starting folder.
% start_path = fullfile(matlabroot, '\toolbox\images\imdemos');
% Ask user to confirm or change.
% topLevelFolder = uigetdir(start_path);
% if topLevelFolder == 0
% 	return;
% end
% Get list of all subfolders.
topLevelFolder = pwd;
allSubFolders = genpath(topLevelFolder);
% Parse into a cell array.
remain = allSubFolders;
listOfFolderNames = {};
while true
	[singleSubFolder, remain] = strtok(remain, ';');
	if isempty(singleSubFolder)
		break;
	end
	listOfFolderNames = [listOfFolderNames singleSubFolder];
end
numberOfFolders = length(listOfFolderNames);
baseFileNames = [];
% Process all image files in those folders.
for k = 1 : numberOfFolders-1
	% Get this folder and print it out.
	thisFolder = listOfFolderNames{k+1};
% 	fprintf('Processing folder %s\n', thisFolder);
	cd(thisFolder)
    
   RNA_coloc2s(mask1, mask2, mrna5file, mrna3file, pixelsize, radius, dist, alchk);
    
    cd ..
% 	% Get PNG files.
% 	filePattern = sprintf('%s/*.png', thisFolder);
% 	baseFileNames = dir(filePattern);
% 	% Add on TIF files.
% 	filePattern = sprintf('%s/*.tif', thisFolder);
% 	baseFileNames = [baseFileNames; dir(filePattern)];
% 	% Add on JPG files.
% 	filePattern = sprintf('%s/*.jpg', thisFolder);
% 	baseFileNames = [baseFileNames; dir(filePattern)];
% 	numberOfImageFiles = length(baseFileNames);
% 	% Now we have a list of all files in this folder.
% 	
% 	if numberOfImageFiles >= 1
% 		% Go through all those image files.
% 		for f = 1 : numberOfImageFiles
% 			fullFileName = fullfile(thisFolder, baseFileNames(f).name);
% 			fprintf('     Processing image file %s\n', fullFileName);
% 		end
% 	else
% 		fprintf('     Folder %s has no image files in it.\n', thisFolder);
% 	end
end

disp('Done')

% for i=1:length(listOfFolderNames-1
%     cd 'listofFolderNames{1}'
