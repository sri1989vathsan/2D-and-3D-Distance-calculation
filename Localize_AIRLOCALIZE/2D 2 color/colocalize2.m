function [out,min_coloc]=colocalize2(mrna1, mrna2, pixelsize,radiuss)

%%% Function to colocalize spots between different channels (in this case
%%% two channels) and return distances and coordinates of spots that
%%% colocalize
%%% colocalize2 outputs two variables
%%% 1. out - the first column contains the index
%%% number of spot from first .loc input(default mrna5nuc),
%%% second column indicates number of spots that colocalized
%%% from mrna3nuc, third column contains distances between the
%%% spots that colocalized (in pixels) and the fourth column
%%% contains the index of the colocalized spot (mrna3nuc)
%%% 2. min_coloc - contains 4 columns - the first column contains the index
%%% number of spot from first .loc input(default mrna5nuc),
%%% second column indicates number of spots that colocalized, the third and
%%% fourth columns conatain the relative x and y coordinates of the
%%% colocalized spots (used for calculating radius of gyration or measuring
%%% accuracy of imaging)   
    
global res
global min_coloc_dif

rna1 = mrna1;
rna2 = mrna2;
radius=radiuss/pixelsize;
n= numel(rna1(:,1));
res=zeros(n,4);
min_coloc_dif=zeros(n,4);

doColoc(rna1, rna2,radius);
out=res;
min_coloc=min_coloc_dif;

%%% Check if multiple spots from rna1 have same closest spot from rna2
u=unique(out(find(~isnan(out(:,4))>0),4));
n=histc(out(:,4),u);
d = u(n > 1);
vals = find(ismember(out(:,4),d));

%%% remove spots from rna1 that colocalize with the same spot from rna2
out(vals,:) = [];
min_coloc(vals,:) = [];

temp = out;
%%% remove spots from rna1 that colocalized with multiple spots from rna2
out(find(out(:,2)~=1),:) = [];
min_coloc(find(temp(:,2)~=1),:) = [];
end

%%% function to colocalize spots from rna1 and rna2 within a radius of
%%% radius (in pixels)
function doColoc(rna1, rna2,radius)
global res
global min_coloc_dif

%%% cycle through all spots from rna1
for i=1:length(res(:,1))
    %%% calculate all distances between ith spot in rna1 and all spots in 
    %%% rna2
    dst= double((rna2(:,1)-rna1(i,1)).^2 + (rna2(:,2)-rna1(i,2)).^2);
    coloc= dst<=(radius.^2); % filter spots
    summ = sum(coloc); % check if there is more than one spot that colocalizes
    [min_val,min_index] = min(dst); % find minimum distance and its position
    res(i,1:4)=double([i, sum(coloc), sqrt(min_val), min_index]);
    min_coloc_dif(i,1:4)=double([i, summ,rna2(min_index,1)-rna1(i,1),...
        rna2(min_index,2)-rna1(i,2)]);
end
end