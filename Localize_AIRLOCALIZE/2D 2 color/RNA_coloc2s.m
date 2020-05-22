function [cytval,nucval] = RNA_coloc2s(mask1, mask2, mrna5file, mrna3file, pixelsize, radius, dist)

%%% RNA_coloc2s - for analyzing 2 color images - Cy5 and Cy3 spots
%%% inputs are as follows
%%% mask1 - mask for Cytoplasm (e.g. Cymask.tif)
%%% mask2 - mask for Nucleus (e.g. Nucmask.tif)
%%% mrna5file - Localization file for Cy5 signal (Cy5.loc)
%%% mrna3file - Localization file for Cy3 signal (Cy3.loc)
%%% pixelsize - size of pixel
%%% radius - radius of inclusion (default: 300nm)
%%% dist - radius of exclusion (default: 100nm)
%%% nucval - output containing quantified nuclear data from the field
%%% cytval - output containing quantified cytoplasmic data from the field

%%% set minimum and maximum number of input arguments
narginchk(4,7);
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
img1=imread(mask1); % read the cytoplasmic mask  tif file
img1=bwlabel(im2bw(mat2gray(img1),0),4); % labeling different regions

if ~isempty(mask2) % read teh nuclear mask tif file if it exists
    img2=imread(mask2);
    img2=bwlabel(im2bw(mat2gray(img2),0),4); %labeling different regions
else
    img2=[];
end

%%% Find number of seperate regions within a mask
inten_dist1=int64(unique(sort(img1(img1>0))));
inten_dist2=int64(unique(sort(img2(img2>0))));
indexing=floor(1:3);

% Temporary variable
xxx=[];

%%% Subsetting mrna3 spots that lie within the nuclear and cytoplasmic
%%% masks - the cytoplasmic data is subsetted to mrna3cyt and the nuclear
%%% data is subsetted to mrna3nuc

if(~isempty(mrna3file))
    mrna3=load(mrna3file);
    mrna3=mrna3((mrna3(:,3)>=threshold),indexing);
    
    for i = 1:length(mrna3)
        D = zeros(size(mrna3,1),1);
        % calculating distances between spots in the same channel
        D(i+1:end) = double((mrna3(i+1:end,1)-mrna3(i,1)).^2 + (mrna3(i+1:end,2)-mrna3(i,2)).^2);
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
    % selecting spots within the cytoplasmic mask
    mrna3cyt=nucleus(mrna3, img1, inten_dist1);
    mrna3cyt=mrna3cyt(mrna3cyt(:,4)>=1,1:3);
    % selecting spots within the nuclear masks if nuclear mask exists
    if ~isempty(img2)
        mrna3nuc=nucleus(mrna3, img2, inten_dist2);
        mrna3nuc=mrna3nuc(mrna3nuc(:,4)>=1,1:3);
    else
        mrna3nuc=[];
    end
end

% Temporary variable
xxx=[];

%%% Subsetting mrna5 spots that lie within the nuclear and cytoplasmic
%%% masks - the cytoplasmic data is subsetted to mrna5cyt and the nuclear
%%% data is subsetted to mrna5nuc

if(~isempty(mrna5file))
    mrna5=load(mrna5file);
    mrna5=mrna5((mrna5(:,3)>=threshold),indexing);
    
    for i = 1:length(mrna5)
        D = zeros(size(mrna5,1),1);
        % calculating distances between spots in the same channel
        D(i+1:end) = double((mrna5(i+1:end,1)-mrna5(i,1)).^2 + (mrna5(i+1:end,2)-mrna5(i,2)).^2);
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
    % selecting spots within the nuclear masks if nuclear mask exists
    if ~isempty(img2)
        mrna5nuc=nucleus(mrna5, img2, inten_dist2);
        mrna5nuc=mrna5nuc(mrna5nuc(:,4)>=1,1:3);
    else
        mrna5nuc =[];
    end
    % selecting spots within the cytoplasmic spots
    mrna5cyt=nucleus(mrna5, img1, inten_dist1);
    mrna5cyt=mrna5cyt(mrna5cyt(:,4)>=1,1:3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%   Processing data   %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Checking for .loc files
if (~isempty(mrna5file) &&  ~isempty(mrna3file))
    %%% Checking for nuclear mask and analyzing data only if it exists
    if ~isempty(img2)
        [mrna5_coloc_mrna3_nuc]= colocalize2(mrna5nuc, mrna3nuc,pixelsize,radius);
    else
        [mrna5_coloc_mrna3_nuc] = [];
    end
    %%% Analyzing cytoplasmic spots
    [mrna5_coloc_mrna3_cyt]= colocalize2(mrna5cyt, mrna3cyt,pixelsize,radius);
    %%% Saving output from data
    twospotInput(mrna5cyt, mrna3cyt, mrna5_coloc_mrna3_cyt, mrna5nuc, mrna3nuc, mrna5_coloc_mrna3_nuc, pixelsize,img2);
end


%%% Combining Values from all other fields - the data has 5 columns
%%% Column 1 & 2 -> coordinates for 5' spot, 3 & 4 -> coordinats for 3' spots
%%% Column 5 -> distance between spots
nucval = [mrna5nuc(mrna5_coloc_mrna3_nuc(:,1),1:2) mrna3nuc(mrna5_coloc_mrna3_nuc(:,4),1:2) mrna5_coloc_mrna3_nuc(:,3).*pixelsize];
cytval = [mrna5cyt(mrna5_coloc_mrna3_cyt(:,1),1:2) mrna3cyt(mrna5_coloc_mrna3_cyt(:,4),1:2) mrna5_coloc_mrna3_cyt(:,3).*pixelsize];

disp('Done')

end

%%% Function to save distance values for Different compartments as Nuclear Distances.csv
%%% and Cytoplasmic Distances.csv and in case of no nuclear mask -
%%% Distances.csv
%%% The output saved Distances file has 8 columns
%%% Column 1 -> index
%%% Column 2,3 -> intensities of localizes spots (spot1 and spot2)
%%% Column 4 -> Distance
%%% Column 5 and 6 -> Coordinates for spot1
%%% Column 7 and 8 -> Coordinates for spot2
function twospotInput(spot1cyt, spot2cyt, spot1_coloc_spot2_cyt,spot1nuc, spot2nuc, spot1_coloc_spot2_nuc, pixelsize,img2)

mrna5_3Data1= zeros(size(spot1_coloc_spot2_cyt,1),8);
a=size(spot1_coloc_spot2_cyt,1);
if(a>0)
    mrna5_3Data1(:,1) = 1:1:size(spot1_coloc_spot2_cyt,1);
    mrna5_3Data1(:,2) = spot1cyt(spot1_coloc_spot2_cyt(:,1),3);
    mrna5_3Data1(:,3) = spot2cyt(spot1_coloc_spot2_cyt(:,4),3);
    mrna5_3Data1(:,4) = spot1_coloc_spot2_cyt(:,3).*pixelsize;
    mrna5_3Data1(:,5:6) = spot1cyt(spot1_coloc_spot2_cyt(:,1),1:2);
    mrna5_3Data1(:,7:8) = spot2cyt(spot1_coloc_spot2_cyt(:,4),1:2);
end

if ~isempty(img2)
    csvwrite('Cytoplasmic Distances.csv',mrna5_3Data1);
else
    csvwrite('Distances.csv',mrna5_3Data1);
end

if ~isempty(img2)
    mrna5_3Data2= zeros(size(spot1_coloc_spot2_nuc,1),8);
    a=size(spot1_coloc_spot2_nuc,1);
    if(a>0)
        mrna5_3Data2(:,1) = 1:1:size(spot1_coloc_spot2_nuc,1);
        mrna5_3Data2(:,2) = spot1nuc(spot1_coloc_spot2_nuc(:,1),3);
        mrna5_3Data2(:,3) = spot2nuc(spot1_coloc_spot2_nuc(:,4),3);
        mrna5_3Data2(:,4) = spot1_coloc_spot2_nuc(:,3).*pixelsize;
        mrna5_3Data2(:,5:6) = spot1nuc(spot1_coloc_spot2_nuc(:,1),1:2);
        mrna5_3Data2(:,7:8) = spot2nuc(spot1_coloc_spot2_nuc(:,4),1:2);
    end
    csvwrite('Nuclear Distances.csv',mrna5_3Data2);
    
else
    mrna5_3Data2 = [];
end

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