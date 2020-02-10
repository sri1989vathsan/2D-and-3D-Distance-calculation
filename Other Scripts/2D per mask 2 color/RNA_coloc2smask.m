function RNA_coloc2smask(mask1, mrnafile)


narginchk(2,10);
threshold=-1;

img1=imread(mask1); % read the image tif file - can be the mask
img1=bwlabel(im2bw(mat2gray(img1),0),4); %labeling different regions
t1mm = [];
t2mm = [];
masks = [];
img3 = img1;

mrnas = [];

for mask=1:max(max(img3))
    img1 = img3;
    t1 = find(any(img1==mask,1));
    t2 = find(any(img1==mask,2));
    t1m = median(t1);
    t2m = median(t2);
    t1mm = [t1mm;t1m];
    t2mm = [t2mm;t2m];
    masks = [masks;sprintf(num2str(mask))];
    
    img1(img1~=mask) =0;
    inten_dist1=int64(unique(sort(img1(img1>0)))); %almost useless
    indexing=floor(1:3);
    
    if(~isempty(mrnafile))
        mrna=load(mrnafile);
        mrna=mrna((mrna(:,3)>=threshold),indexing);
        mrnamask=nucleus(mrna, img1, inten_dist1);
        mrnamask=mrnamask(mrnamask(:,4)>=1,1:3);
        mrnas = [mrnas; mrnamask transpose(repelem(mask,size(mrnamask,1)))];
    end
end

close all
figure(1)
imshow(img3)
text(t1mm,t2mm,masks,'Color','red','FontSize',20);
% saveas(figure(1),'Masks.tif')
export_fig 'Masks.tif' -native
close all

p=colormap;
csvwrite('RNAs in cells.csv',mrnas);

end

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
