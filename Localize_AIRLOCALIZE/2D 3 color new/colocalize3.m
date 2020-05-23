function [out,min_coloc]=colocalize3(rna1, rna2, rna3, pixelsize,radiuss)

%%% Function to colocalize spots between different channels (in this case
%%% three channels) and return distances and coordinates of spots that
%%% colocalize
%%% colocalize3 outputs three variables
%%% 1. out - has 6 columns in total
%%% the first column contains the index of rna1 signal, columns 2 to 3
%%% represent calculations between rna1 and rna2, columns 4 to 5 represent
%%% calculations between rna1 and rna3 - the two columns for each
%%% calculation represents the minimum distance (in pixels) and the index
%%% number of the spot from rna2/rna3 with the least distance
%%% column 6 is the distance between rna2 and rna3 spots
%%% 2. min_coloc - contains 5 columns - the first is the index of rna1
%%% signal, columns 2 and 3 represent the relative coordinates of rna2 wrt
%%% rna1, columns 4 and 5 represent the relative coordinates of rna3 wrt
%%% rna1

global res
global min_coloc_dif

radius=radiuss/pixelsize;
n= numel(rna1(:,1));
res=zeros(n,9);
min_coloc_dif=zeros(n,9);

doColoc(rna1, rna2, rna3,radius);
out=res;
min_coloc=min_coloc_dif;
%%% removing spots that colocalized with multiple spots (rna1 and rna2 
%%% channels) from the other respective channel (rna2 or rna1) 
out(:,9) = out(:,2)+out(:,5);
out(find(out(:,9)<2),:) = [];

min_coloc(:,9) = min_coloc(:,2)+min_coloc(:,5);
min_coloc(find(min_coloc(:,9)<2),:) = [];

temp=out;
%%% only select RNAs with distance between rna2 and rna3 <= radius
out(find(temp(:,8)>radius),:) = [];
min_coloc(find(temp(:,8)>radius),:) = [];

%%% Removing spots in rna1 that colocalized with multiple spots in rna2
u=unique(out(find(~isnan(out(:,4))>0),4));
n=histc(out(:,4),u);
d = u(n > 1);
vals = find(ismember(out(:,4),d));
out(vals,:) = [];
min_coloc(vals,:) = [];

%%% Removing spots in rna1 that colocalized with multiple spots in rna3
u=unique(out(find(~isnan(out(:,7))>0),7));
n=histc(out(:,7),u);
d = u(n > 1);
vals = find(ismember(out(:,7),d));
out(vals,:) = [];
out(:,[2,5,9]) = [];
min_coloc(vals,:) = [];
min_coloc(:,[2,5,8,9]) = [];
end

%%% function to colocalize spots from rna1, rna2 and rna3 within a radius 
%%% of radius (in pixels)
function doColoc(rna1, rna2, rna3,radius)
global res
global min_coloc_dif

for i=1:length(res(:,1))
    % Calculating distance between rna1 and rna2 and selecting for
    % distances less than radius
    dst1= double((rna2(:,1)-rna1(i,1)).^2 + (rna2(:,2)-rna1(i,2)).^2);
    coloc1= dst1<=(radius.^2);
    % Calculating distance between rna1 and rna3 and selecting for
    % distances less than radius
    dst2= double((rna3(:,1)-rna1(i,1)).^2 + (rna3(:,2)-rna1(i,2)).^2);
    coloc2= dst2<=(radius.^2);
    
    % finding minimum distance value and the index corresponding to it 
    [min_val1,min_index1] = min(dst1);
    [min_val2,min_index2] = min(dst2);
    
    % caculating distances between nearest neighbors of rna1 (in rna2 and 
    % rna3) - no filter applied here for minimum distance
    dst3 = double((rna3(min_index2,1)-rna2(min_index1,1)).^2 + ...
        (rna3(min_index2,2)-rna2(min_index1,2)).^2);
    
    res(i,1:4)=double([i, logical(nnz(coloc1)), sqrt(min_val1), ...
        min_index1]);
    res(i,5:8)=double([logical(nnz(coloc2)), sqrt(min_val2), ...
        min_index2 sqrt(dst3)]);

    min_coloc_dif(i,1:4)=double([i, logical(nnz(coloc1)),...
        rna2(min_index1,1)-rna1(i,1),rna2(min_index1,2)-rna1(i,2)]);
    min_coloc_dif(i,5:7)=double([logical(nnz(coloc2)),...
        rna3(min_index2,1)-rna1(i,1),rna3(min_index2,2)-rna1(i,2)]);
end
end