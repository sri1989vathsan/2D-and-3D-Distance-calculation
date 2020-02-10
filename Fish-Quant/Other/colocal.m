function [out,each_coloc,min_coloc]=colocal(rna1, rna2, pixelsize,radiuss)
%%Return the number of colocalize arn from rna1 and rna2
global res
global coloc_ind
global min_coloc_dif
radius=radiuss/pixelsize;
coloc_ind={};
n= numel(rna1(:,1));
res=zeros(n,4);
% min_coloc_dif=zeros(n,4);
% slmin=0;
% slmax=100;
% figure('name',title),
% imshow(disp_img);
% hold on;
% h= plot(rna1(:,1),rna1(:,2),'o','Color',[.88 .48 0],'MarkerSize',1);
% hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,'SliderStep',[0.1 1]./(slmax-slmin),'Value',1,...
%     'Position',[20 20 200 20], 'Tag', 'gslider');
% 
% htext= uicontrol('Style', 'text', 'Position', [230 20 100 20], 'String', [num2str(pixelsize*1), 'nm'], 'Tag', 'text');
% set(hsl,'Callback',{@updateVal});

% hbut=uicontrol('Style', 'pushbutton', 'String', 'Ok',...
%     'Position', [340 20 50 20],...
%     'Callback', {@
doColoc(rna1, rna2, pixelsize,radius);
% waitfor(hbut, 'UserData')
out=res;
each_coloc=coloc_ind;
min_coloc=min_coloc_dif;

    function updateVal(~, ~)
        pix=get(hsl, 'Value');
        set(h,'MarkerSize', pix)
        set(htext, 'String', [num2str(pix*100*pixelsize/100), 'nm']);
    end

end

function doColoc(rna1, rna2, pixelsize,radius)
global res
global coloc_ind
global min_coloc_dif
% slider=findobj(0,'Tag','gslider');
% radius=get(slider, 'Value');
disp(['Radius : ', num2str(radius*pixelsize),'nm']);
for i=1:length(res(:,1))
    dst= double((rna2(:,1)-rna1(i,1)).^2 + (rna2(:,2)-rna1(i,2)).^2);
    coloc= dst<=(radius.^2);
    summ = sum(coloc);
    [min_val,min_index] = min(dst);
    res(i,1:4)=double([logical(nnz(coloc)), sum(coloc), sqrt(min_val), min_index]);
    coloc_ind{i}=find(coloc);
    min_coloc_dif(i) = min_index;
%      rna2(min_index,1)-rna1(i,1)
%      rna2(min_index,2)-rna1(i,2)
    min_coloc_dif(i,1:4)=double([logical(nnz(coloc)), sum(coloc),rna2(min_index,1)-rna1(i,1),rna2(min_index,2)-rna1(i,2)]);
end
% close gcf
end