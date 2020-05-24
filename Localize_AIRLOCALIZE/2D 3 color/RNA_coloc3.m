function [nucdist,cytdist,nucpos,cytpos,nucrelpos,cytrelpos] = ...
    RNA_coloc3(mask1, mask2, mrnafile, pixelsize, radius, dist,reference)
%%% RNA_coloc3 - for analyzing 3 color images - 5p, 3p and mid spots
%%% inputs are as follows
%%% mask1 - mask for Cytoplasm (e.g. Cymask.tif)
%%% mask2 - mask for Nucleus (e.g. Nucmask.tif)
%%% mrnafile - Names of localization files for the three regions of an mRNA
%%% by default it is '5p', '3p' and 'mid'
%%% pixelsize - size of pixel
%%% radius - radius of inclusion (default: 300nm)
%%% dist - radius of exclusion (default: 100nm)
%%% nucval - output containing quantified nuclear data from the field
%%% cytval - output containing quantified cytoplasmic data from the field
%%% reference - channel that is used as reference to identify nearby spots
%%% from the other two channels

%%% assigning individual filenames
mrna5file = mrnafile(1);
mrnamidfile = mrnafile(2);
mrna3file = mrnafile(3);

%%% set minimum and maximum number of input arguments
narginchk(4,10);
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

if ~isempty(mask2)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Identifying spots within masks %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Subsetting mrna3 spots that lie within the nuclear and cytoplasmic
%%% masks - the cytoplasmic data is subsetted to mrna3cyt and the nuclear
%%% data is subsetted to mrna3nuc

if(~isempty(mrna3file))
    mrna3=load(mrna3file);
    mrna3=mrna3((mrna3(:,3)>=threshold),indexing);
    
    for i = 1:length(mrna3)
        D = zeros(size(mrna3,1),1);
        D(i+1:end) = double((mrna3(i+1:end,1)-mrna3(i,1)).^2 + ...
            (mrna3(i+1:end,2)-mrna3(i,2)).^2);
        D = sqrt(D);
        D = D*pixelsize;
        out =find(D(i+1:end)<dist);
        if ~isempty(out)
            xxx = [xxx;i;out+i];
        end
    end
    xxx = unique(xxx);
    mrna3(xxx,:) = [];
    mrna3cyt=nucleus(mrna3, img1, inten_dist1);
    mrna3cyt=mrna3cyt(mrna3cyt(:,4)>=1,1:3);
    if ~isempty(img2)
        mrna3nuc=nucleus(mrna3, img2, inten_dist2);
        mrna3nuc=mrna3nuc(mrna3nuc(:,4)>=1,1:3);
    else
        mrna3nuc=[];
    end
end

xxx=[];

%%% Subsetting mrnamid spots that lie within the nuclear and cytoplasmic
%%% masks - the cytoplasmic data is subsetted to mrnamidcyt and the nuclear
%%% data is subsetted to mrnamidnuc

if(~isempty(mrnamidfile))
    mrnamid=load(mrnamidfile);
    mrnamid=mrnamid((mrnamid(:,3)>=threshold),indexing);
    
    for i = 1:length(mrnamid)
        D = zeros(size(mrnamid,1),1);
        D(i+1:end) = double((mrnamid(i+1:end,1)-mrnamid(i,1)).^2 + ...
            (mrnamid(i+1:end,2)-mrnamid(i,2)).^2);
        D = sqrt(D);
        D = D*pixelsize;
        out =find(D(i+1:end)<dist);
        if ~isempty(out)
            xxx = [xxx;i;out+i];
        end
    end
    xxx = unique(xxx);
    mrnamid(xxx,:) = [];
    mrnamidcyt=nucleus(mrnamid, img1, inten_dist1);
    mrnamidcyt=mrnamidcyt(mrnamidcyt(:,4)>=1,1:3);
    if ~isempty(img2)
        mrnamidnuc=nucleus(mrnamid, img2, inten_dist2);
        mrnamidnuc=mrnamidnuc(mrnamidnuc(:,4)>=1,1:3);
    else
        mrnamidnuc=[];
    end
end

xxx=[];
%%% Subsetting mrna5 spots that lie within the nuclear and cytoplasmic
%%% masks - the cytoplasmic data is subsetted to mrna5cyt and the nuclear
%%% data is subsetted to mrna5nuc
if(~isempty(mrna5file))
    mrna5=load(mrna5file);
    mrna5=mrna5((mrna5(:,3)>=threshold),indexing);
    
    for i = 1:length(mrna5)
        D = zeros(size(mrna5,1),1);
        D(i+1:end) = double((mrna5(i+1:end,1)-mrna5(i,1)).^2 + ...
            (mrna5(i+1:end,2)-mrna5(i,2)).^2);
        D = sqrt(D);
        D = D*pixelsize;
        out =find(D(i+1:end)<dist);
        if ~isempty(out)
            xxx = [xxx;i;out+i];
        end
    end
    xxx = unique(xxx);
    mrna5(xxx,:) = [];
    if ~isempty(img2)
        mrna5nuc=nucleus(mrna5, img2, inten_dist2);
        mrna5nuc=mrna5nuc(mrna5nuc(:,4)>=1,1:3);
    else
        mrna5nuc =[];
    end
    
    mrna5cyt=nucleus(mrna5, img1, inten_dist1);
    mrna5cyt=mrna5cyt(mrna5cyt(:,4)>=1,1:3);
end

%%%% Setting reference and adjusting the variables accordingly

if(reference == "mid")
    rna1cyt = mrnamidcyt;
    rna2cyt = mrna5cyt;
    rna3cyt = mrna3cyt;
    rna1nuc = mrnamidnuc;
    rna2nuc = mrna5nuc;
    rna3nuc = mrna3nuc;
    
elseif(reference == "5p")
    rna1cyt = mrna5cyt;
    rna2cyt = mrnamidcyt;
    rna3cyt = mrna3cyt;
    rna1nuc = mrna5nuc;
    rna2nuc = mrnamidnuc;
    rna3nuc = mrna3nuc;
elseif(reference == "3p")
    rna1cyt = mrna3cyt;
    rna2cyt = mrna5cyt;
    rna3cyt = mrnamidcyt;
    rna1nuc = mrna3nuc;
    rna2nuc = mrna5nuc;
    rna3nuc = mrnamidnuc;
else
    cprintf('err','Set reference');
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%   Processing data   %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Nuclear Distance calculation
if (~isempty(mrna5file) &&  ~isempty(mrna3file) && ~isempty(mrnamidfile))
    if ~isempty(img2)
        [coloc_mrna5mid3_nuc,coloc_mrna5mid3coor_nuc]= ...
            colocalize3(rna1nuc, rna2nuc,rna3nuc,pixelsize,radius);
    else
        [coloc_mrna5mid3_nuc,coloc_mrna5mid3coor_nuc] = [];
    end
    %%% Cytoplasmic Distance calculation
    [coloc_mrna5mid3_cyt,coloc_mrna5mid3coor_cyt]= ...
        colocalize3(rna1cyt, rna2cyt,rna3cyt, pixelsize,radius);
    
    rna1cyts = rna1cyt(coloc_mrna5mid3_cyt(:,1),:);
    rna2cyts = rna2cyt(coloc_mrna5mid3_cyt(:,3),:);
    rna3cyts = rna3cyt(coloc_mrna5mid3_cyt(:,5),:);
    
    rna1nucs = rna1nuc(coloc_mrna5mid3_nuc(:,1),:);
    rna2nucs = rna2nuc(coloc_mrna5mid3_nuc(:,3),:);
    rna3nucs = rna3nuc(coloc_mrna5mid3_nuc(:,5),:);
    
    [nucdist,cytdist,nucpos,cytpos,nucrelpos,cytrelpos] = ...
        threespotInput(rna1cyts, rna2cyts, rna3cyts,...
        coloc_mrna5mid3_cyt, coloc_mrna5mid3coor_cyt, ...
        rna1nucs, rna2nucs, rna3nucs, ...
        coloc_mrna5mid3_nuc, coloc_mrna5mid3coor_nuc, ...
        pixelsize,img2,reference);
end

disp('Done')
end

%%% Function to save distance values for Different compartments as Nuclear Distances.csv
%%% and Cytoplasmic Distances.csv and in case of no nuclear mask -
%%% Distances.csv, 'Cytoplasmic Absolute Coordinates.csv' and 'Nuclear
%%% Absolute Coordinates.csv' representing the coordinates of spots that
%%% colocalized wrt to the original image and 'Cytoplasmic Relative 
%%% Coordinates.csv' and 'Nuclear Relative Coordinates.csv' representing
%%% the coordinates of the colocalized spots wrt to the reference (spot1)

%%% The saved Distances.csv files have 8 columns
%%% Column 1 -> index
%%% Column 2,3,4 -> intensities of localizes spots (spot1, spot2 and spot3)
%%% Column 4-7 -> Distances (spot1-spot2), spot1-spot3 and spot2-spot3
%%% for eg if reference is set as mid, then spot1-spot2 is mid-5',
%%% spot1-spot3 is mid-3' and spot2-spot3 is 5'-3'
%%% Column 8 -> Reference (eg 5p, mid, 3p)

%%% The Absolute Coordinates.csv files have 8 columns
%%% Column 1 -> index
%%% Column 2,3 -> coordinates of spot1
%%% Column 4,5 -> coordinates of spot2
%%% Column 6,7 -> coordinates of spot3
%%% Column 8 -> Reference

%%% The Relative Coordinates.csv files have 6 columns
%%% Column 1 -> index
%%% Column 2,3 -> coordinates of spot2 wrt spot1 (in nm)
%%% Column 4,5 -> coordinates of spot3 wrt spot1 (in nm)
%%% Column 8 -> Reference

function [nucdist,cytdist,nucpos,cytpos,nucrelpos,cytrelpos] = threespotInput ...
    (spot1cyt, spot2cyt, spot3cyt, ...
    spot1_spot2_spot3_cyt, spot1_spot2_spot3_pos_cyt, spot1nuc, spot2nuc, spot3nuc, ...
    spot1_spot2_spot3_nuc, spot1_spot2_spot3_pos_nuc, pixelsize, img2, reference)


mrnaData1= zeros(size(spot1cyt,1),7);
mrna_spots_cyt= zeros(size(spot1cyt,1),7);
mrna_spots_rel_cyt= zeros(size(spot1cyt,1),5);
a=size(spot1cyt,1);
if(a>0)
    mrnaData1(:,1) = 1:1:size(spot1cyt,1);
    mrnaData1(:,2) = spot1cyt(:,3);
    mrnaData1(:,3) = spot2cyt(:,3);
    mrnaData1(:,4) = spot3cyt(:,3);
    mrnaData1(:,5:7) = spot1_spot2_spot3_cyt(:,[2,4,6]).*pixelsize;
   
    mrna_spots_cyt(:,1) = 1:1:size(spot1cyt,1);
    mrna_spots_cyt(:,2:3) = spot1cyt(:,1:2);
    mrna_spots_cyt(:,4:5) = spot2cyt(:,1:2);
    mrna_spots_cyt(:,6:7) = spot3cyt(:,1:2);
    
    mrna_spots_rel_cyt(:,1) = 1:1:size(spot1cyt,1);
    mrna_spots_rel_cyt(:,2:5) = spot1_spot2_spot3_pos_cyt(:,2:5).*pixelsize;
    
    mrnaval = num2cell(mrnaData1);
    mrnaspotscyt = num2cell(mrna_spots_cyt);
    mrnaspotsrelcyt = num2cell(mrna_spots_rel_cyt);
    
    C = cell(length(mrnaval), 1);
    if(reference == "mid")
        C(:) = {'mid'};
    elseif(reference == "5p")
        C(:) = {'5p'};
    elseif(reference == "3p")
        C(:) = {'3p'};
    end
    mrnaval(:,8) = C;
    mrnaspotscyt(:,8) = C;
    mrnaspotsrelcyt(:,6) = C;
end

cytdist = mrnaval;
cytpos = mrnaspotscyt;
cytrelpos = mrnaspotsrelcyt;

if ~isempty(img2)
    cell2csv('Cytoplasmic Distances.csv',mrnaval,',');
    cell2csv('Cytoplasmic Absolute Coordinates.csv',mrnaspotscyt);
    cell2csv('Cytoplasmic Relative Coordinates.csv',mrnaspotsrelcyt);
else
    csvwrite('Distances.csv',mrnaData1);
end

if ~isempty(img2)
    mrnaData2= zeros(size(spot1nuc,1),6);
    mrna_spots_nuc= zeros(size(spot1nuc,1),7);
    mrna_spots_rel_nuc= zeros(size(spot1nuc,1),5);
    a=size(spot1nuc,1);
    if(a>0)
        mrnaData2(:,1) = 1:1:size(spot1nuc,1);
        mrnaData2(:,2) = spot1nuc(:,3);
        mrnaData2(:,3) = spot2nuc(:,3);
        mrnaData2(:,4) = spot3nuc(:,3);
        mrnaData2(:,5:7) = spot1_spot2_spot3_nuc(:,[2,4,6]).*pixelsize;
        
        mrna_spots_nuc(:,1) = 1:1:size(spot1nuc,1);
        mrna_spots_nuc(:,2:3) = spot1nuc(:,1:2);
        mrna_spots_nuc(:,4:5) = spot2nuc(:,1:2);
        mrna_spots_nuc(:,6:7) = spot3nuc(:,1:2);
        
        mrna_spots_rel_nuc(:,1) = 1:1:size(spot1nuc,1);
        mrna_spots_rel_nuc(:,2:5) = spot1_spot2_spot3_pos_nuc(:,2:5).*pixelsize;
        
        mrna532 = num2cell(mrnaData2);
        mrnaspotsnuc = num2cell(mrna_spots_nuc);
        mrnaspotsrelnuc = num2cell(mrna_spots_rel_nuc);
        
        C = cell(length(mrna532), 1);
        if(reference == "mid")
            C(:) = {'mid'};
        elseif(reference == "5p")
            C(:) = {'5p'};
        elseif(reference == "3p")
            C(:) = {'3p'};
        end
        
        mrna532(:,8) = C;
        mrnaspotsnuc(:,8) = C;
        mrnaspotsrelnuc(:,6) = C;

        cell2csv('Nuclear Distances.csv',mrna532,',');
        cell2csv('Nuclear Absolute Coordinates.csv',mrnaspotsnuc);
        cell2csv('Nuclear Relative Coordinates.csv',mrnaspotsrelnuc);
        
        nucdist = mrna532;
        nucpos = mrnaspotsnuc;
        nucrelpos = mrnaspotsrelnuc;

    else
        mrnaData2 = [];
        nucdist = [];
        nucpos = [];
        nucrelpos = [];
    end
    
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