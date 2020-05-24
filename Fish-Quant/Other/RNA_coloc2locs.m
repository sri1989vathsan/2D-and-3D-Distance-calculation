function [val] = RNA_coloc2locs(mask1, mrna5file, mrna3file, pixelsize, radius, dist)

%%% RNA_coloc2locs - for analyzing 2 color images - Cy5 and Cy3 spots
%%% inputs are as follows
%%% mask1 - mask for Cytoplasm (e.g. Cymask.tif)
%%% mask2 - mask for Nucleus (e.g. Nucmask.tif)
%%% mrna5file - Localization file for Cy5 signal (Cy5.loc)
%%% mrna3file - Localization file for Cy3 signal (Cy3.loc)
%%% pixelsize - size of pixel
%%% radius - radius of inclusion (default: 300nm)
%%% dist - radius of exclusion (default: 100nm)
%%% vals - output containing quantified data from the field

%%% set minimum and maximum number of input arguments
narginchk(4,6);
threshold=-1;

%%% Check if input exists for radius and pixelsize if not assigning default
%%% values
if ~exist('radius', 'var') || isempty(radius)
    radius=300;
end

if ~exist('pixelsize', 'var') || isempty(pixelsize)
    pixelsize=39.682539;
end

%%% Read input files
img1=imread(mask1); % read the image tif file - can be the mask
img1=bwlabel(im2bw(mat2gray(img1),0),4); %labeling different regions

%%% Find number of seperate regions within a mask
inten_dist1=int64(unique(sort(img1(img1>0))));
indexing=floor(1:3);

%%% Subsetting mrna3 spots that lie within the mask - the spots within the
%%% mask is subsetted to mrna3cyt

% Temporary variable
xxx=[];

if(~isempty(mrna3file))
    mrna3=load(mrna3file);
    mrna3=mrna3((mrna3(:,3)>=threshold),indexing);
    for i = 1:length(mrna3)
        D = zeros(size(mrna3,1),1);
        % calculating distances between spots in the same channel
        D(i+1:end) = double((mrna3(i+1:end,1)-mrna3(i,1)).^2 + ...
            (mrna3(i+1:end,2)-mrna3(i,2)).^2);
        D = sqrt(D);
        D = D*pixelsize;
        % excluding spots within the radius of exclusion
        out =find(D(i+1:end)<dist);
        if ~isempty(out)
            xxx = [xxx;i;out+i];
        end
    end
    xxx = unique(xxx);
    mrna3(xxx,:) = [];
    % selecting spots within the mask
    mrna3=nucleus(mrna3, img1, inten_dist1);
    mrna3=mrna3(mrna3(:,4)>=1,1:3);
end

xxx=[];

if(~isempty(mrna5file))
    mrna5=load(mrna5file);
    mrna5=mrna5((mrna5(:,3)>=threshold),indexing);
    
    for i = 1:length(mrna5)
        D = zeros(size(mrna5,1),1);
        % calculating distances between spots in the same channel
        D(i+1:end) = double((mrna5(i+1:end,1)-mrna5(i,1)).^2 + ...
            (mrna5(i+1:end,2)-mrna5(i,2)).^2);
        D = sqrt(D);
        D = D*pixelsize;
        % excluding spots within the radius of exclusion
        out =find(D(i+1:end)<dist);
        if ~isempty(out)
            xxx = [xxx;i;out+i];
        end
    end
    xxx = unique(xxx);
    mrna5(xxx,:) = [];
    % selecting spots within the mask
    mrna5=nucleus(mrna5, img1, inten_dist1);
    mrna5=mrna5(mrna5(:,4)>=1,1:3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%   Processing data   %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (~isempty(mrna5file) &&  ~isempty(mrna3file))
    [mrna5_coloc_mrna3,mrna5_mrna3_coloc_val]= ...
        colocalize2loc(mrna5, mrna3,pixelsize,radius);
    
    mrna5_mrna3_coloc_val = ...
    mrna5_mrna3_coloc_val(mrna5_mrna3_coloc_val(:,2)==1,:);
    
    mrna5_mrna3_coloc_val_fin(:,3:4) =  ...
        mrna5_mrna3_coloc_val(:,3:4).*pixelsize;
    
    twospotInput(mrna5, mrna3, mrna5_coloc_mrna3, ...
        pixelsize, mrna5_mrna3_coloc_val_fin);
    
end

val = mrna5_coloc_mrna3;

disp('Done')

end

%%% Function to save distance values for Different compartments as
%%% Distances.csv
%%% The saved Distances.csv files have 8 columns
%%% Column 1 -> index
%%% Column 2,3 -> intensities of localizes spots (spot1 and spot2)
%%% Column 4 -> Distance
%%% Column 5 and 6 -> Coordinates for spot1
%%% Column 7 and 8 -> Coordinates for spot2

%%% Pixel shift.csv saves relative coordinates of spot2 wrt spot 1 for the
%%% nearest localized spots- It has 3 columns - 
%%% Column 1 -> index
%%% Column 2 and 3 -> Relative coordinates

function twospotInput(spot1, spot2, spot1_coloc_spot2, pixelsize,spot1_spot2_coloc_val)

mrnaData1= zeros(size(spot1_coloc_spot2,1),8);
a=size(spot1_coloc_spot2,1);
if(a>0)
    mrnaData1(:,1) = 1:1:size(spot1_coloc_spot2,1);
    mrnaData1(:,2) = spot1(spot1_coloc_spot2(:,1),3);
    mrnaData1(:,3) = spot2(spot1_coloc_spot2(:,4),3);
    mrnaData1(:,4) = spot1_coloc_spot2(:,3).*pixelsize;
    mrnaData1(:,5:6) = spot1(spot1_coloc_spot2(:,1),1:2);
    mrnaData1(:,7:8) = spot2(spot1_coloc_spot2(:,4),1:2);
end

csvwrite('Distances.csv',mrnaData1);

pixel_shift = spot1_spot2_coloc_val(:,3:4);

pixshiftval= zeros(size(spot1_spot2_coloc_val,1),3);
pixshiftval(:,1) = 1:1:size(spot1_spot2_coloc_val,1);
pixshiftval(:,2:3) = pixel_shift;

csvwrite('Pixel shift.csv',pixshiftval);
end

%%% Function to select spots within the mask
%%% Inputs:
%%% coor -> coordinate file for the channel that has to be subsetted
%%% label_img -> mask file
%%% nuc_int -> number of regions within a mask
%%% outputs coordinate file with a fourth column containg value >0 if the
%%% spots is within the mask

function coor=nucleus(coor, label_img, nuc_int)
coor(:,end+1)= zeros(size(coor(:,end)));
for i=1:length(coor(:,1))
    i_nuc=label_img(round(coor(i,2)),round(coor(i,1)));
    proche_nuc=zeros(2,2);
    if(coor(i,2)>1 && coor(i,1)>1)
        proche_nuc= label_img(round(coor(i,2))-1:round(coor(i,2))+1,round(coor(i,1))-1:round(coor(i,1))+1);
    end
    if(i_nuc>0)
        coor(i,end)= find(nuc_int==i_nuc);
    elseif sum(proche_nuc(:))>0
        coor(i, end)= find(nuc_int==proche_nuc(find(proche_nuc~=0,1)));
    end
end
end