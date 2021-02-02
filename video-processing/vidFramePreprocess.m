function vidFramePreprocess(filename, bg, t, foldername)
% Function to pre-process individual video frame and draw bounding boxes
% over identified drops. Output is a lablled image and will be saved in a
% user-defined directory.
% Workflow: background subtraction; tresholding & binarisation;
% morphological close and fill; draw bounding box
%
%   filename: 'video frame file name' <char>
%   bg: background image file name <var>
%   t: treshold value (range: 0-1)<double>

%read image 
img = imread(filename); 

%background subtraction (standard diff: background - video frame)
sub_img = bg - img; 
% figure; imshow(sub_img)

%tresholding & binarisation
bin_img = imbinarize(sub_img, t); 
% figure; imshow(bin_img)

%morphological fill 
fill_img = bwconvhull(bin_img,'objects'); 
% figure; imshow(fill_img)

%detect region of interest 
roi = regionprops(fill_img,'centroid','BoundingBox'); 
centres = cat(1,roi.Centroid); 
box = cat(1,roi.BoundingBox); 

%label drops on original video frame and save file 
f = figure('visible', 'off'); % don't want to display plot when run code
imshow(filename); 

hold on 

plot(centres(:,1), centres(:,2), 'b+'); %draw centroids

for i=1:length(box) %draw bounding boxes
    rectangle('Position',box(i,:),'EdgeColor','b')
end

hold off 

% overwrite original video frame with labelled frame
print(fullfile(foldername, filename), '-djpeg')
% saveas(f, fullfile(foldername,filename), 'jpeg'); 

close(f)

end