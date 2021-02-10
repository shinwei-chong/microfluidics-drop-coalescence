function vidFramePreprocess(filename, bg, t, minArea, leadEdge, foldername,k)
% Function to pre-process individual video frame and draw bounding boxes
% over identified drops. Output is a lablled image which will be saved in a
% user-defined directory.
%
% Workflow: background subtraction -> tresholding & binarisation ->
% morphological fill -> noise object removal -> draw bounding box
%
%   filename: 'video frame file name' <char>
%   bg: background image file name <var>
%   t: treshold value (range: 0-1)<double>
%   minArea: minimum pixel area to keep <double>
%   leadEdge: x-coordinate of point of entrance to main flow <double> 
%   foldername: name of folder to save new video frames in 

%read image 
img = imread(filename); 

%background subtraction (standard diff: background - video frame)
sub_img = rescale(abs(double(img) - double(bg))); 
% figure; imshow(sub_img)

%tresholding & binarisation
bin_img = imbinarize(sub_img, t); 
% figure; imshow(bin_img)

%morphological fill 
fill_img = bwconvhull(bin_img,'objects'); 
% figure; imshow(fill_img)

%remove noise objects
cfill_img = bwareaopen(fill_img, minArea);

%detect region of interest 
roi = regionprops('table',cfill_img);
roi(roi.Centroid(:,1) < leadEdge, :) =[]; %remove data for any points out of main channel

% roi = regionprops(cfill_img,'centroid','BoundingBox'); 
% centres = cat(1,roi.Centroid); 
% box = cat(1,roi.BoundingBox); 

%label drops on original video frame and save file 
f = figure('visible', 'off'); % don't want to display plot when run code
imshow(filename); 

hold on 

plot(roi.Centroid(:,1), roi.Centroid(:,2), 'b+'); %draw centroids

for i=1:height(roi) %draw bounding boxes
    rectangle('Position',roi.BoundingBox(i,:),'EdgeColor','b')
end

hold off 

% overwrite original video frame with labelled frame
print(fullfile(foldername, sprintf('%d.jpg',k)), '-djpeg')
% saveas(f, fullfile(foldername,filename), 'jpeg'); 

close(f)

end