imagepath = 'C:\Users\callu\Desktop\MATLAB Working Folder\Learning Dataset 2 - Copy\Singlet';

images = dir(fullfile(imagepath, '*jpg'));

for k = 1:length(images);
    oldFilename = images(k).name;
    newFilename = sprintf('%1d.jpg',k); %for doublet and coalescence photos add number of files already converted
    movefile(fullfile(imagepath, oldFilename), fullfile(imagepath, newFilename));
end


    




