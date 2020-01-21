cd Temp2
directory = dir(fullfile(pwd, '*.txt'));
files = struct2cell(directory);

pixelxy = 39.6;
pixelz = 180;
for i=1:length(files)
    data = importdata(string(files(1,i)),'\t',19);
    values = data.data;
    values2 = [values(:,2)/pixelxy,values(:,1)/pixelxy,values(:,26),values(:,31)];
    values3 = [values(:,1)/pixelxy,values(:,2)/pixelxy,values(:,3)/pixelz,values(:,26),values(:,31)];
    aname= split(string(files(1,i)),'.');
    
    loc2 = strcat(aname(1),'.loc');
    loc3 = strcat(aname(1),'.loc3');
    
    dlmwrite(loc2,values2);
    dlmwrite(loc3,values3,'\t');
    

end
directory1 = dir(fullfile(pwd, '*.loc'));
directory2 = dir(fullfile(pwd, '*.loc3'));
files1 = struct2cell(directory1);
files2 = struct2cell(directory2);

for j=1:length(files1)
    aname1 = split(string(files1(1,j)),'_');
    aname21 = split(string(files2(1,j)),'_');
    aname2 = split(string(files1(1,j)),'_');
    aname22 = split(string(files2(1,j)),'_');
    cd ..
    cd(char(aname1(2)))
    name1 = strcat('../Temp2/',string((files1(1,j))));
    name21 = strcat('../Temp2/',string((files2(1,j))));
    
    name2 = strcat(aname1(1),'.loc');
    name22 = strcat(aname2(1),'.loc3');
    
    copyfile(char(name1),char(name2));
    copyfile(char(name21),char(name22));
   

end

cd .. 
 if exist('Temp', 'dir')
    movefile Temp '../Temp'
 end
 
if exist('Temp2', 'dir')
    movefile Temp2 '../Temp2'
 end
 