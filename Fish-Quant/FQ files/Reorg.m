topLevelFolder = pwd; %current working directory
% genpath: Generate path includes myfolder and all folders below it.
allSubFolders = genpath(topLevelFolder);
% Parse into a cell array.
remain = allSubFolders;
listOfFolderNames = {};
while true
    [singleSubFolder, remain] = strtok(remain, ':');
    if isempty(singleSubFolder)
        break;
    end
    listOfFolderNames = [listOfFolderNames singleSubFolder];
end
numberOfFolders = length(listOfFolderNames);

% if numberOfFolders == 1
%     cprintf('err','error: No subfolders\n');
%     return
% end

nucval = [];
cytval = [];
% baseFileNames = [];
% Process all image files in those folders.
mkdir Temp
for k = 1 : numberOfFolders-1
    % Get this folder and print it out.
    thisFolder = listOfFolderNames{k+1};
    % 	fprintf('Processing folder %s\n', thisFolder);
    cd(thisFolder)
    
    namecy5 = strcat('../Temp/Cy5_',num2str(k),'.tif');
    namecy3 = strcat('../Temp/Cy3_',num2str(k),'.tif');
    
    copyfile('Cy5.tif',namecy5)
    copyfile('Cy3.tif',namecy3)
    
    pwd
    cd ..
end
