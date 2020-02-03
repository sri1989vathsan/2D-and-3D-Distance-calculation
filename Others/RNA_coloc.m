function RNA_coloc(imgfile, mrna3file, mrnamidfile, mrna5file, threshold, convert, prefix)
%ARN_coloc, took 4 to 6 , Use:
%**ARN_coloc(imgfile, mrna3file, mrnamidfile, mrna5file)
%**ARN_coloc(imgfile, mrna3file, mrnamidfile, mrna5file,k)
%**ARN_coloc(imgfile, mrna3file, mrnamidfile, mrna5file,k, threshold)
%  - imgfile = a string indicating the path to the nucleus mask file (tif or tiff)
%  - mrna3file= a string indicating the path to the sense erna loc file
%  - mrnamidfile= a string indicating the path to the anti-sense erna loc file
%  - mrna5file= a string indicating the path to the mrna5 loc file
%  - k, this is the intensity coefficient to use for transcription site
%  detection, not mandatory, default=1.5
%  - threshold, this is not mandatory,it's used to discard any spot with intensity
%below threshold, default value =-1
%
%3 files will be saved:
%  - 'final_label.png' : an image labelling nucleus and spot:
%        +red spot = mrna5
%        +blue spot = sense erna
%        +green spot = anti-sense erna
%  - 'trans_coloc_analysis.txt' : output with only transcription site mrna5
%  - 'spot_coloc_analysis.txt' : output with all spot analysis
%
% EXAMPLE:
% ARN_coloc('mask.tif', 'mrna3.loc', 'mrnamid.loc', 'mRNA.loc' )


narginchk(4,10);
if ~exist('threshold', 'var') || isempty(threshold)
    threshold=-1;
end
%if ~exist('k', 'var') || isempty(k)
    k=0.1;
%end

if ~exist('convert', 'var') || isempty(convert)
    convert=100;
end

if ~exist('intronsig', 'var') || isempty(intronsig)
    intronsig=false;
end

if ~exist('prefix', 'var') || isempty(prefix)
    prefix='';
end

if ~exist('number', 'var') || isempty(number)
    number=false;
end


img=imread(imgfile); % read the image tif file - can be the mask 
disp_img= imcomplement(ind2rgb(gray2ind(im2bw(mat2gray(img),0),255), gray(255))); %to ensure that the image is converted to a high contrast rgb file (why though?)
img=bwlabel(im2bw(mat2gray(img),0),4); %labeling different regions

%TRouver la nouvelle distribution en intensité des noyaux
inten_dist=int64(unique(sort(img(img>0)))); %almost useless
mrna3=[];
mrnamid=[];
mrna5=[];
indexing=floor(1:3);
im_xsize=size(disp_img,1);
im_ysize=size(disp_img,2);
%Lecture des fichier de coordonnées des arn
if(~isempty(mrnamidfile))
    mrnamid=load (mrnamidfile);
    mrnamid=mrnamid((mrnamid(:,3)>=threshold),indexing); % select first three columns
    
    %display mrnamid spots
    %Displaying spot on img
    for i=1:size(mrnamid,1)
        x_2=round(mrnamid(i,2)-2);
        y_2=round(mrnamid(i,1)-2);
        if(x_2>0 && x_2<=im_xsize && y_2>0 && y_2<=im_ysize)
            x_size=round(mrnamid(i,2)-2:mrnamid(i,2)+2);
            y_size=round(mrnamid(i,1)-2:mrnamid(i,1)+2);
            disp_img(x_size,y_size, indexing)=0;
            disp_img(x_size, y_size, 2)=1;
        else
            disp_img(findRound(mrnamid(i,2), im_xsize), findRound(mrnamid(i,1), im_ysize), indexing)=0;
            disp_img(findRound(mrnamid(i,2), im_xsize), findRound(mrnamid(i,1), im_ysize), 2)=1;
        end
    end
    
    %setting nucleus spots
    mrnamid=nucleus(mrnamid, img, inten_dist);
end

if(~isempty(mrna3file))
    mrna3=load (mrna3file);
    mrna3=mrna3((mrna3(:,3)>=threshold),indexing);
    % display mrna3 spot
    for i=1:size(mrna3,1)
        x_2=round(mrna3(i,2)-2);
        y_2=round(mrna3(i,1)-2);
        if(x_2>0 && x_2<=im_xsize && y_2>0 && y_2<=im_ysize)
            x_size=round(mrna3(i,2)-2:mrna3(i,2)+2);
            y_size=round(mrna3(i,1)-2:mrna3(i,1)+2);
            disp_img(x_size, y_size, indexing)=0;
            disp_img(x_size, y_size, 3)=1;
        else
            disp_img(findRound(mrna3(i,2), im_xsize), findRound(mrna3(i,1), im_ysize), indexing)=0;
            disp_img(findRound(mrna3(i,2), im_xsize), findRound(mrna3(i,1), im_ysize), 3)=1;
        end
        
    end
    mrna3=nucleus(mrna3, img, inten_dist);
end

if(~isempty(mrna5file))
    mrna5=load(mrna5file);
    mrna5=mrna5((mrna5(:,3)>=threshold),indexing);
    
    %display mrna5 spot
    for i=1:size(mrna5,1)
        x_2=round(mrna5(i,2)-2);
        y_2=round(mrna5(i,1)-2);
        if(x_2>0 && x_2<=im_xsize && y_2>0 && y_2<=im_ysize)
            x_size=round(mrna5(i,2)-2:mrna5(i,2)+2);
            y_size=round(mrna5(i,1)-2:mrna5(i,1)+2);
            disp_img(x_size, y_size, indexing)=0;
            disp_img(x_size, y_size, 1)=1;
        else
            disp_img(findRound(mrna5(i,2), im_xsize), findRound(mrna5(i,1), im_ysize), indexing)=0; %impossible to represent 0,0 coordinate so I shift it by 1 pixel
            disp_img(findRound(mrna5(i,2), im_xsize), findRound(mrna5(i,1), im_ysize), 1)=1;
        end
    end
    
    %Setting nucleus for each rna
    mrna5=nucleus(mrna5, img, inten_dist);
%     mrna5=transite(mrna5, 0,k, intronsig);
    
end

mrna3_coloc_mid=[];
mrna3_mid_coloc = {};
mrna5_coloc_mrna3=[];
mrna5_mrna3_coloc={};
mrna5_coloc_mid=[];
mrna5_mid_coloc={};
three_coloc=[];

input_type='';
if (~isempty(mrnamidfile) &&  ~isempty(mrna3file))
    disp('*Colocalization 3 end vs middle');
    input_type='as';
    [mrna3_coloc_mid, mrna3_mid_coloc]= colocalize(mrna3, mrnamid, disp_img, convert, [prefix,'Colocalization middle vs 3 end']);
end

if (~isempty(mrna5file) &&  ~isempty(mrna3file))
    disp('*Colocalization 5 end vs 3 end');
    input_type='ms';
    [mrna5_coloc_mrna3, mrna5_mrna3_coloc]= colocalize(mrna5, mrna3, disp_img, convert, [prefix,'Colocalization 5 end vs 3 end']);
end

if (~isempty(mrnamidfile) &&  ~isempty(mrna5file))
    disp('*Colocalization 5 end vs middle');
    input_type='ma';
    [mrna5_coloc_mid, mrna5_mid_coloc]= colocalize(mrna5, mrnamid, disp_img, convert,[prefix,'Colocalization 5 end vs middle']);
end

if (~isempty(mrnamidfile) &&  ~isempty(mrna5file) && ~isempty(mrna3file))
    three_coloc= all_coloc(mrna3_coloc_mid,mrna5_mrna3_coloc,mrna5_mid_coloc,mrna3_mid_coloc);
    input_type='mas';
end

if(strcmp(input_type, 'mas'))
    allInput(img,disp_img,inten_dist, mrna5, mrna3, mrnamid, mrna3_coloc_mid, mrna5_coloc_mid, three_coloc,mrna5_coloc_mrna3, prefix, convert, number);
elseif (strcmp(input_type, 'ms'))
    mrna_ernaInput(img,disp_img,inten_dist, mrna5, mrna3, mrna5_coloc_mrna3, 'mrna3', prefix, convert, number);
elseif (strcmp(input_type, 'ma'))
     mrna_ernaInput(img,disp_img,inten_dist, mrna5, mrnamid, mrna5_coloc_mid, 'mrnamid', prefix, convert, number);
else
    ernaInput(img, disp_img, inten_dist, mrna3, mrnamid, mrna3_coloc_mid, prefix, number);
end

end


%% Cas de colocalisation a 2 (standard spot1 vs spot2)
function ernaInput(img, disp_img, inten_dist, mrna3, mrnamid, mrna3_coloc_mid, prefix, number)

data=zeros(length(inten_dist),4);
data(:,1)=1:length(inten_dist);

%data: 'Nuc', 'mrna3-mrnamid', #mrna3	#mrnamid
for i=1:length(inten_dist)
    data(i,2)=sum(mrna3_coloc_mid(mrna3(:,end)==inten_dist(i)));
    data(i,3)=nnz(mrna3(:,4)==inten_dist(i));
    data(i,4)=nnz(mrnamid(:,4)==inten_dist(i));
end
write_On_image(disp_img, inten_dist, img, number);
header={'Nuc','mrna3-mrnamid','mrna3', 'mrnamid'};
writeToFile(data, strcat(prefix,'spot_coloc_analysis.txt'), header);

end


%% Cas de colocalisation a 2 (erna, mrna5)
function mrna_ernaInput(img,disp_img,inten_dist, mrna5, erna, mrna_coloc_erna, message, prefix, convert, number)

%data: 'Nuc', 'mrna3-mrna5', #mrna5	#mrna3
%trans_data: 'Nuc', 'mrna3-mrna5', trans_number, nascent_mrna, #mrna3, mRNAnascent_coloc_+message,	#mRNAnascent_noColoc_erna
mrnaDATA=double([(1:size(mrna5,1))' mrna5 mrna_coloc_erna(:,end-1:end)]);
trans_w_erna=mrnaDATA((mrna_coloc_erna(:,1)>0 & mrnaDATA(:,end-3)==1),:);
trans_wo_erna= mrnaDATA((mrna_coloc_erna(:,1)==0 & mrnaDATA(:,end-3)==1),1:end-2);

data=zeros(length(inten_dist),4);
data(:,1)=1:length(inten_dist);

trans_data=zeros(length(inten_dist),7);
trans_data(:,1)=1:length(inten_dist);

for i=1:length(inten_dist)
    
    %Remplir les tables d'outputs
    data(i,2)=sum(mrna_coloc_erna(mrna5(:,4)==inten_dist(i)));
    data(i,3)= nnz(mrna5(:,4)==inten_dist(i));
    data(i,4)=nnz(erna(:,4)==inten_dist(i));
    trans_data(i,2)=sum(mrna_coloc_erna(mrna5(:,4)==inten_dist(i) & mrna5(:,end-1)==1));
    trans_data(i,3)=sum(mrna5(mrna5(:,4)==inten_dist(i),end-1));
    trans_data(i,4)= sum(round(mrna5((mrna5(:,4)==inten_dist(i) & mrna5(:,end-1)==1),end)));
    trans_data(i,5)=nnz(erna(:,4)==inten_dist(i));
    trans_data(i,6)= sum(round(trans_w_erna(trans_w_erna(:,5)==inten_dist(i),end-2)));
    trans_data(i,7)= sum(round(trans_wo_erna(trans_wo_erna(:,5)==inten_dist(i),end)));
end

write_On_image(disp_img, inten_dist, img, mrna5(mrna5(:,end-1)~=0,1:end), number);
header={'Nuc',strcat('mrna5-',message),'no_mrna5', strcat('no_',message)};
writeToFile(data, strcat(prefix,'spot_coloc_analysis.txt'), header);
header={'Nuc',strcat('t_mrna-',message),'trans_number', 'nascent_mrna',strcat('no_',message), strcat('no_mRNAnascent_coloc_', message),'no_mRNAnascent_noColoc_erna'};
writeToFile(trans_data, strcat(prefix,'trans_coloc_analysis.txt'), header);

%writing trans with erna

header={'mRNA_Trans','nuc' ,'intensity', 'no_nascent', ['closest_' message,'_dist_nm'], 'no_erna', 'erna_intensity', 'erna_nascent'};
ernaData= zeros(size(trans_w_erna,1),8);
erna_m=single_mean(erna(:,3), 0, 'Single_erna_intensity');
trans_pos = find(mrna5(:,5) ~=0);
a=size(trans_w_erna,1);
if(a>0)
    ernaData(:,1) = arrayfun(@(x)find(trans_pos==x,1),trans_w_erna(:,1));
    ernaData(:,2)=trans_w_erna(:,5);
    ernaData(:,3:4)=[trans_w_erna(:,4) round(trans_w_erna(:,end-2))];
    ernaData(:,5)= trans_w_erna(:,end-1).*convert;
    ernaData(:,6)= trans_w_erna(:,end);
    ernaData(:,7)= erna(trans_w_erna(:,end),3);
    ernaData(:,8)= round(ernaData(:,7)./erna_m);

end
writeToFile(ernaData,[prefix, 'Trans_with_',message,'_.txt'], header);
csvwrite('Distances.csv',ernaData);
mrnaLocx= [trans_w_erna(:,2:4) ernaData(:,4) ernaData(:,2)];
ernaLocx = [erna(trans_w_erna(:,end), 1:3) round(ernaData(:,7)./erna_m)  ernaData(:,2)];
generate_locx_files(mrnaLocx, [prefix,'mrna5.locx']);
generate_locx_files(ernaLocx, [prefix,'erna.locx']);

%Writing trans without erna 
header={'mRNA_Trans', 'intensity', 'no_nascent'};
no_ernaData= zeros(size(trans_wo_erna,1),3);
a=size(trans_wo_erna,1);
if(a>0)
    no_ernaData(:,1)=1:size(trans_wo_erna,1);
    no_ernaData(:,2:3)=[trans_wo_erna(:,4) round(trans_wo_erna(:,end))];
end
writeToFile(no_ernaData,[prefix, 'Trans_without_',message,'_.txt'], header);

trans_header = {'mRNA_trans', 'x', 'y', 'intensity', 'nascent', 'nucleus', 'erna_coloc'};
transcript_data = [(1:numel(trans_pos))' mrna5(trans_pos, [1,2,3,6,4])];
transcript_data(:, end+1) = mrna_coloc_erna(trans_pos,1);
writeToFile(transcript_data, 'trans.locx', trans_header);

end


%% Cas de colocalisation a 3 (mrna3, mrnamid, mrna5)
function allInput(img,disp_img,inten_dist, mrna5, mrna3, mrnamid, mrna3_coloc_mid, mrna5_coloc_mid, three_coloc,mrna5_coloc_mrna3, prefix, convert, number)

mrnaDATA=double([(1:size(mrna5,1))' mrna5 mrna5_coloc_mrna3(:,end-1:end) mrna5_coloc_mid(:,end-1:end)]);
trans_w_s_erna=mrnaDATA((mrna5_coloc_mrna3(:,1)>0 & mrnaDATA(:,end-5)==1),1:end-2);
trans_w_as_erna=mrnaDATA((mrna5_coloc_mid(:,1)>0 & mrnaDATA(:,end-5)==1),setdiff(1:end,end-3:end-2));
trans_wo_erna= mrnaDATA((mrna5_coloc_mid(:,1)==0 & mrna5_coloc_mrna3(:,1)==0 & mrnaDATA(:,end-5)==1),1:end-4);

data=zeros(length(inten_dist),8);
data(:,1)=1:length(inten_dist);
trans_data=zeros(length(inten_dist),9);
trans_data(:,1)=1:length(inten_dist);

%data: 'Nuc','mrna3-mrnamid','mrna3-mrna5','mrnamid-mrna5','mrnamid-mrna3-mrna5'
for i=1:length(inten_dist)
    data(i,2)=sum(mrna3_coloc_mid(mrna3(:,end)==inten_dist(i)));
    data(i,3)=sum(mrna5_coloc_mrna3(mrna5(:,4)==inten_dist(i)));
    data(i,4)=sum(mrna5_coloc_mid(mrna5(:,4)==inten_dist(i)));
    data(i,5)=sum(three_coloc(mrna5(:,4)==inten_dist(i)));
    data(i,6)= nnz(mrna5(:,4)==inten_dist(i));
    data(i,7)=nnz(mrna3(:,4)==inten_dist(i));
    data(i,8)=nnz(mrnamid(:,4)==inten_dist(i));
    
    trans_data(i,2)=sum(mrna3_coloc_mid(mrna3(:,end)==inten_dist(i)));
    trans_data(i,3)=sum(mrna5_coloc_mrna3(mrna5(:,4)==inten_dist(i) & mrna5(:,end-1)==1));
    trans_data(i,4)=sum(mrna5_coloc_mid(mrna5(:,4)==inten_dist(i) & mrna5(:,end-1)==1));
    trans_data(i,5)=sum(three_coloc(mrna5(:,4)==inten_dist(i) & mrna5(:,end-1)==1));
    trans_data(i,6)=sum(mrna5(mrna5(:,4)==inten_dist(i),end-1));
    trans_data(i,7)= sum(round(mrna5((mrna5(:,4)==inten_dist(i) & mrna5(:,end-1)==1),end)));
    trans_data(i,8)=nnz(mrna3(:,4)==inten_dist(i));
    trans_data(i,9)=nnz(mrnamid(:,4)==inten_dist(i));
    trans_data(i,10)= sum(round(trans_w_s_erna(trans_w_s_erna(:,5)==inten_dist(i),end-2)));
    trans_data(i,11)= sum(round(trans_w_as_erna(trans_w_as_erna(:,5)==inten_dist(i),end-2)));
    trans_data(i,12)= sum(round(trans_wo_erna(trans_wo_erna(:,5)==inten_dist(i),end)));
    
end

write_On_image(disp_img, inten_dist, img, mrna5(mrna5(:,end-1)~=0,1:end), number);
header={'Nuc','mrna3-mrnamid','mrna3-mrna5','mrnamid-mrna5','mrnamid-mrna3-mrna5', 'no_mrna5', 'no_mrna3', 'no_mrnamid'};
writeToFile(data, [prefix,'spot_coloc_analysis.txt'], header);
header={'Nuc','mrna3-mrnamid','mrna3-t_mrna','mrnamid-t_mrna','mrnamid-mrna3-t_mrna','trans_number', 'nascent_mrna','no_mrna3', 'no_mrnamid', 'no_mRNAnascent_coloc_s_erna', 'no_mRNAnascent_coloc_as_erna', 'no_mRNAnascent_noColoc_erna'};
writeToFile(trans_data, [prefix,'trans_coloc_analysis.txt'], header);

header={'mRNA_Trans','nuc', 'intensity', 'no_nascent', 'is_also_Coloc with_as-erna', 'closest s-erna dist','no_mrna3', 'mrna3 intensity', 'mrna3 nascent'};
s_ernaData= zeros(size(trans_w_s_erna,1),9);
erna_m=single_mean(mrna3(:,3), 0, 'Single mrna3 intensity');

trans_pos = find(mrna5(:,5) ~=0);
a=size(trans_w_s_erna,1);

if(a>0)
    % with thos map index to global transcription site index
    s_ernaData(:,1) = arrayfun(@(x)find(trans_pos==x,1),trans_w_s_erna(:,1));
    s_ernaData(:,2)=trans_w_s_erna(:,5);
    s_ernaData(:,3:4)=[trans_w_s_erna(:,4) round(trans_w_s_erna(:,end-2))];
    s_ernaData(:,5)=three_coloc(trans_w_s_erna(:,1));
    s_ernaData(:,6)=trans_w_s_erna(:,end-1).*convert;
    s_ernaData(:,7)= trans_w_s_erna(:,end);
    s_ernaData(:,8)=mrna3(trans_w_s_erna(:,end),3);
    s_ernaData(:,9)=round(s_ernaData(:,8)./erna_m);
end

mrnaLocx= [trans_w_s_erna(:,2:4) s_ernaData(:,4) s_ernaData(:,2)];
ernaLocx = [mrna3(trans_w_s_erna(:,end), 1:3) round(s_ernaData(:,8)./erna_m)  s_ernaData(:,2)];
generate_locx_files(mrnaLocx, [prefix,'mrna5.locx']);
generate_locx_files(ernaLocx, [prefix,'erna.locx']);

writeToFile(s_ernaData,[prefix,'Trans_with_s_erna.txt'], header);

header={'mRNA_Trans', 'nuc', 'intensity', 'no_nascent', 'is_also_Coloc with_s-erna', 'closest as-erna dist','no_mrnamid', 'mrnamid intensity', 'mrnamid nascent'};
as_ernaData= zeros(size(trans_w_as_erna,1),9);
erna_m=single_mean(mrna3(:,3), 0, 'Single mrnamid intensity');
a=size(trans_w_as_erna,1);
if(a>0)
    as_ernaData(:,1) = arrayfun(@(x)find(trans_pos==x,1),trans_w_as_erna(:,1));
    as_ernaData(:,2)=trans_w_as_erna(:,5);
    as_ernaData(:,3:4)=[trans_w_as_erna(:,4) round(trans_w_as_erna(:,end-2))];
    as_ernaData(:,5)=three_coloc(trans_w_as_erna(:,1));
    as_ernaData(:,6)=trans_w_as_erna(:,end-1).*convert;
    as_ernaData(:,7)= trans_w_as_erna(:,end);
    as_ernaData(:,8)=mrnamid(trans_w_as_erna(:,end),3);
    as_ernaData(:,9)=round(as_ernaData(:,8)./erna_m);
    
end


mrnaLocx= [trans_w_as_erna(:,2:4) as_ernaData(:,4) as_ernaData(:,2)];
ernaLocx = [mrnamid(trans_w_as_erna(:,end), 1:3) round(as_ernaData(:,8)./erna_m)  as_ernaData(:,2)];
generate_locx_files(mrnaLocx, [prefix,'mrna5.locx']);
generate_locx_files(ernaLocx, [prefix,'erna.locx']);

writeToFile(as_ernaData,[prefix, 'Trans_with_as_erna.txt'], header);

header={'mRNA_Trans', 'intensity', 'no_nascent'};
no_ernaData= zeros(size(trans_wo_erna,1),3);
a=size(trans_wo_erna,1);
if(a>0)
    no_ernaData(:,1)=1:size(trans_wo_erna,1);
    no_ernaData(:,2:3)=[trans_wo_erna(:,4) round(trans_wo_erna(:,end))];
end
writeToFile(no_ernaData,[prefix,'Trans_without_erna.txt'], header);
trans_header = {'mRNA_trans', 'x', 'y', 'intensity', 'nascents', 'nucleus', 's_erna_coloc', 'as_erna_coloc'};
%writeToFile(transcript_data, 'trans.locx', transheader);

transcript_data = [(1:numel(trans_pos))' mrn5(trans_pos, [1,2,3,6,4])];
transcript_data(:, end+1:end+2) = [mrna5_coloc_mrna3(trans_pos,1) mrna5_coloc_mid(trans_pos, 1)];
writeToFile(transcript_data, 'trans.locx', trans_header);

end


% %% Determiner les sites de transcription
% function mrna5=transite(mrna5, background,k, intronsig)
% % mrna5:  x, y, intensity,, noyau, is_trans, number of mrna5 per spot
% mrna_int= mrna5(:,3);
% idx= kmeans(mrna_int, 2);
% [~, min_ind] =min(mrna_int);
% single_cat= idx(min_ind);
% if (intronsig==0)
%     mean_single = mean(mrna_int(mrna5(:,4)==background & idx==single_cat));
% else
%     mean_single = mean(mrna_int(mrna5(:,4)~=background & idx==single_cat));
% end
% 
% disp('mrna5 mean single intensity:')
% disp(mean_single)
% disp('mrna5 overall mean intensity:')
% disp(mean(mrna_int))
% dlmwrite('mrna_low_intensity.txt', mrna_int(idx==single_cat));
% dlmwrite('mrna_high_intensity.txt', mrna_int(idx~=single_cat));
% dlmwrite('mrna_single_intensity.txt', mrna_int(mrna5(:,4)==background & idx==single_cat));
% 
% 
% mrna5(:,end+1)=(double(mrna5(:,3)/mean_single)>k) & (mrna5(:,4)~=background);
% mrna5(:,end+1)=mrna5(:,3)/mean_single;
% 
% % I will be able to use the gui wrote for imaris here, Let's just assume
% % that user don't need to correct for the moment
% 
% end


%% Trouver le noyau d'appartenance de chaque spot s'il existe
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


%% Ecrire les ids des cellules sur l'image
function write_On_image(disp_im, towrite, nuc, trans, number)

%ecrire sur l'image
f = figure('color','white','units','normalized','position',[.1 .1 .8 .8]);
tmp_im = rgb2gray(disp_im);
tmp_im(tmp_im==0 | tmp_im==1) = 0;
tmp_im = im2bw(tmp_im, 0);
[im_D, ~] = bwdist(tmp_im);

imagesc(disp_im);
set(f,'units','pixels','position',[0 0 size(disp_im,1)  size(disp_im,2)],'visible','off')
%truesize; %this would be great but since it doesn't really work, fuck
%off

axis off
if(number)
    for a= 1:length(towrite)
        [i, j]=(find(nuc==towrite(a,1))); % pour retourner les coord x et  y
        idx = sub2ind(size(disp_im), i, j);
        im_idx = sort(im_D(idx), 'descend');
        moy = ceil((numel(im_idx)+1)/2);
        [i,j] = ind2sub(size(disp_im), idx(moy));
        text('position',[j i] , 'FontWeight','bold' ,'fontsize',10,'string',int2str(a), 'color', [0.5,0.5,0.5]) ;
    end
end

if nargin>3
    hold on;
    plot(trans(:,1),trans(:,2), '+', 'Color', [235, 197, 91]./255, 'MarkerSize', 3, 'LineWidth', 0.60);
end

% Capture the text image
print(f,'-depsc','-r150','final_label')

%saveas(f, 'final_label', 'png');

close(f);
end


%% Ecrire les données dans un fichier texte en utilisant header pour entête
function writeToFile(data, outfile, header)

fid = fopen(outfile,'w');
if fid == -1; error('Cannot open file: %s', outfile); end
fprintf(fid, '%s\t', header{:});
fprintf(fid, '\n');
fclose(fid);
dlmwrite(outfile, data,'delimiter', '\t', '-append');

end


function m=single_mean(intensity, method, message)
% This suppose that all the spot are currently in the  nucleus

[min_int, min_ind] =min(intensity);
[max_int, max_ind] =max(intensity);

m1=mean(intensity);

idx1= kmeans(intensity, 2);
m2=mean(intensity(idx1==idx1(min_ind)));

idx2=kmeans(intensity, 3);
m3= mean(intensity(idx2~=idx2(min_ind) & idx2~=idx2(max_ind)));
disp(message)
if(method==0)
    hf=figure,
    %hist(intensity);
    binranges = min_int:100:max_int+100;
    [bincounts] = histc(intensity,binranges);
    bar(binranges,bincounts,'histc');
    prompt = sprintf('Choose the %s calculation method between this 3 methods:\n -mean: %-0.5f\n -kmeans-2-center: %-0.5f\n -kmeans-3-center: %-0.5f\n',message, m1, m2, m3);
    answ=inputdlg(prompt,[message, ' calculation'],1);
    if isempty(answ)
        method=1;
    else
        method= str2double(answ{1});
    end
    close(hf);
end

if method==2
    m=m2;
    dlmwrite('k2_erna_low_intensity.txt', intensity(idx1==idx1(min_ind)));
    dlmwrite('k2_erna_high_intensity.txt', intensity(idx1==idx1(max_ind)));

elseif method==2
    m=m3;
    dlmwrite('k3_erna_low_intensity.txt', intensity(idx2==idx2(min_ind)));
    dlmwrite('k3_erna_high_intensity.txt', intensity(idx2==idx2(max_ind)));
    dlmwrite('k3_erna_middle_intensity.txt', intensity(idx2~=idx2(min_ind) & idx2~=idx2(max_ind)));

else
    m=m1;

end

end

function generate_locx_files(data, filename)
% the locx file is a extension of the loc file
% the format is the following: X Y INT NASC NUC
dlmwrite(filename, data,'delimiter', '\t', '-append');
end


function pos=findRound(x, maxX)
pos=round(x);
if(pos<1)
    pos=1;
elseif(pos>maxX)
    pos=maxX;
end

end

function coloc=all_coloc(srna_asrna, mrna_s, mrna_as, srna_asrna_coloc)

asrna_srna=[];
for i=1:numel(srna_asrna_coloc)
    asrna_srna=[asrna_srna;srna_asrna_coloc{i}(:)];
end

coloc=false(numel(mrna_s),1);
for i=1:numel(mrna_s)
    if(~isempty(mrna_s{i}) && ~isempty(mrna_as{i})) || (~isempty(mrna_s{i}) && nnz(srna_asrna(mrna_s{i},1))) || (~isempty(mrna_as{i}) && nnz(ismember(mrna_as{i},asrna_srna)))
        coloc(i)=true;
    end
end
end
