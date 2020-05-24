function [val] = RNA_coloc2loc_3D(mask1, mask2, mrna5file, ...
    mrna3file, pixelsize, zpixelsize, radius, dist)

%%% RNA_coloc2loc_3D - for analyzing 2 color images - Cy5 and Cy3 spots
%%% inputs are as follows
%%% mask1 - mask for Cytoplasm (e.g. Cymask.tif)
%%% mask2 - mask for Nucleus (e.g. Nucmask.tif)
%%% mrna5file - Localization file for Cy5 signal (Cy5.loc3)
%%% mrna3file - Localization file for Cy3 signal (Cy3.loc3)
%%% pixelsize - size of pixel
%%% zpixelsize - step size z stack (default: 180nm)
%%% radius - radius of inclusion (default: 300nm)
%%% dist - radius of exclusion (default: 100nm)
%%% nucval - output containing quantified nuclear data from the field
%%% cytval - output containing quantified cytoplasmic data from the field

%%% set minimum and maximum number of input arguments
narginchk(4,8);
threshold=-1;
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
inten_dist1=int64(unique(sort(img1(img1>0)))); %almost useless
indexing=floor(1:4);

% Temporary variable
xxx=[];

%%% Subsetting mrna3 spots that lie within the nuclear and cytoplasmic
%%% masks - the cytoplasmic data is subsetted to mrna3cyt and the nuclear
%%% data is subsetted to mrna3nuc - subsetting is done using the X and Y
%%% coordinates only

if(~isempty(mrna3file))
    mrna3=load(mrna3file);
    mrna3=mrna3((mrna3(:,4)>=threshold),indexing);
    mrna33 = mrna3;
    mrna3(:,1) = mrna33(:,2);
    mrna3(:,2) = mrna33(:,1);
    for i = 1:length(mrna3)
        D = zeros(size(mrna3,1),1);
        D(i+1:end) = double(((mrna3(i+1:end,1)-mrna3(i,1)).^2)*(pixelsize^2) + ((mrna3(i+1:end,2)-mrna3(i,2)).^2)*(pixelsize^2)+ ((mrna3(i+1:end,3)-mrna3(i,3)).^2)*(zpixelsize^2));
        D = sqrt(D);
%         D = D*pixelsize;
        out =find(D(i+1:end)<dist);
        if ~isempty(out)
            xxx = [xxx;i;out+i];
       end
    end
    xxx = unique(xxx);
    mrna3(xxx,:) = [];
    
    mrna3val=nucleus(mrna3, img1, inten_dist1);
    mrna3val=mrna3val(mrna3val(:,5)>=1,1:4);

end

xxx=[];

%%% Subsetting mrna5 spots that lie within the nuclear and cytoplasmic
%%% masks - the cytoplasmic data is subsetted to mrna5cyt and the nuclear
%%% data is subsetted to mrna5nuc - subsetting is done using the X and Y
%%% coordinates only

if(~isempty(mrna5file))
    mrna5=load(mrna5file);
    mrna5=mrna5((mrna5(:,4)>=threshold),indexing);
   
    mrna55 = mrna5;
    mrna5(:,1) = mrna55(:,2);
    mrna5(:,2) = mrna55(:,1);

    
       for i = 1:length(mrna5)
        D = zeros(size(mrna5,1),1);
      	D(i+1:end) = double(((mrna5(i+1:end,1)-mrna5(i,1)).^2)*(pixelsize^2) + ((mrna5(i+1:end,2)-mrna5(i,2)).^2)*(pixelsize^2)+ ((mrna5(i+1:end,3)-mrna5(i,3)).^2)*(zpixelsize^2));
        D = sqrt(D);
        D = D*pixelsize;
        out =find(D(i+1:end)<dist);
        if ~isempty(out)
            xxx = [xxx;i;out+i];
        end
       end
    xxx = unique(xxx);
    mrna5(xxx,:) = [];

    mrna5val=nucleus(mrna5, img1, inten_dist1);
    mrna5val=mrna5val(mrna5val(:,5)>=1,1:4);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%   Processing data   %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (~isempty(mrna5file) &&  ~isempty(mrna3file))
    [mrna5_coloc_mrna3, mrna5_mrna3_coloc_val] = ...
        colocalize2loc_3d(mrna5val, mrna3val, pixelsize, zpixelsize, radius);
    
    twospotInput(mrna5val, mrna3val, mrna5_coloc_mrna3,...
        mrna5_mrna3_coloc_val);      
end

val = [mrna5val(mrna5_coloc_mrna3(:,1),1:3) ...
    mrna3val(mrna5_coloc_mrna3(:,4),1:3) ...
    mrna5_coloc_mrna3(:,3)];

disp('Done')

end

%%% Function to save distance values for as  Distances.csv and 

%%% All saved ~Distances.csv files have 10 columns
%%% Column 1 -> index
%%% Column 2,3 -> intensities of localizes spots (spot1 and spot2)
%%% Column 4 -> Distance
%%% Column 5, 6 and 8 -> Coordinates for spot1
%%% Column 8, 9 and 10 -> Coordinates for spot2

%%% Pixel shift.csv saves relative coordinates of spot2 wrt spot 1 for the
%%% nearest localized spots- It has 3 columns - 
%%% Column 1 -> index
%%% Column 2, 3 and 4 -> Relative coordinates

function twospotInput(spot1val, spot2val, spot1_coloc_spot2,...
    spot1_spot2_coloc_val)

mrnaData1= zeros(size(spot1_coloc_spot2,1),10);
a=size(spot1_coloc_spot2,1);
if(a>0)
    mrnaData1(:,1) = 1:1:size(spot1_coloc_spot2,1);
    mrnaData1(:,2) = spot1val(spot1_coloc_spot2(:,1),4);
    mrnaData1(:,3) = spot2val(spot1_coloc_spot2(:,4),4);
    mrnaData1(:,4) = spot1_coloc_spot2(:,3);
    mrnaData1(:,5:7) = spot1val(spot1_coloc_spot2(:,1),1:3);
    mrnaData1(:,8:10) = spot2val(spot1_coloc_spot2(:,4),1:3);
end

csvwrite('Distances.csv',mrnaData1);

pixel_shift = spot1_spot2_coloc_val(:,3:5);

pixshiftval= zeros(size(spot1_spot2_coloc_val,1),4);
pixshiftval(:,1) = 1:1:size(spot1_spot2_coloc_val,1);
pixshiftval(:,2:4) = pixel_shift;

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
    if(round(coor(i,2))>1 && round(coor(i,1))>1)
        proche_nuc= label_img(round(coor(i,2))-1:round(coor(i,2))+1,round(coor(i,1))-1:round(coor(i,1))+1);
    end
    if(i_nuc>0)
        coor(i,end)= find(nuc_int==i_nuc);
    elseif sum(proche_nuc(:))>0
        coor(i, end)= find(nuc_int==proche_nuc(find(proche_nuc~=0,1)));
    end
end
end