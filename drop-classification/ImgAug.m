imagepath = 'C:\Users\callu\Desktop\MATLAB Working Folder\Learning Dataset 2 - Copy\Singlet';

image_folder = dir(fullfile(imagepath, '*jpg'));

imageAugmenter = imageDataAugmenter( ...
    'RandRotation', [-360,360], ...
    'RandXReflection', [1],...
    'RandYReflection', [1]);



for i = 1:numel(image_folder)
    
filename = fullfile(imagepath,sprintf('%d.jpg',i));
img = imread(filename); 

noisedensity = randi(100)/5000;

saltimg = imnoise(img,'salt & pepper',noisedensity);
gausimage = imnoise(img,'gaussian',noisedensity);

gausfold = 'C:\Users\callu\Desktop\MATLAB Working Folder\GausImages';
spfold = 'C:\Users\callu\Desktop\MATLAB Working Folder\SPImages';


gausstr = [i,"g",".jpg"];
gausname = join(gausstr,"");

imwrite(gausimage, gausname);

spstr = [i,"g",".jpg"];
spname = join(gausstr,"");

imwrite(saltimg, spname);

end

%FOR SINGLE FILE
% filename = fullfile(imagepath,sprintf('%d.jpg',1));
% img = imread(filename); 
% 
% noisedensity = randi(100)/5000;
% 
% saltimg = imnoise(img,'salt & pepper',noisedensity);
% gausimage = imnoise(img,'gaussian',noisedensity);
% 
% gausfold = 'C:\Users\callu\Desktop\MATLAB Working Folder\GausImages';
% spfold = 'C:\Users\callu\Desktop\MATLAB Working Folder\SPImages';
% 
% 
% str = ["1","g",".jpg"];
% gausname = join(str,"");
% 
% imwrite(gausimage, gausname);




       