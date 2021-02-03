function roiBbox = Process4Crop(readFrame, bg, t, minArea, leadEdge)
% Function to pre-process individual video frame to detect ROIs ready for cropping. 
% Output is a table containing the Bounding Box properties of all the ROIs detected in the user-defined image frame.
% Workflow: background subtraction; tresholding & binarisation;
% morphological close and fill; draw bounding box
%
%   readFrame: video frame that has been read using imread <uint8>
%   bg: background image file name <var>
%   t: treshold value (range: 0-1)<double>
%   minArea: minimum pixel area to keep <double>
%   leadEdge: x-coord of vertical edge of which drops to the right of the edge will be processed <double> 


%background subtraction (standard diff: background - video frame)
sub_img = bg - readFrame; 
% figure; imshow(sub_img)

%tresholding & binarisation
bin_img = imbinarize(sub_img, t); 
% figure; imshow(bin_img)

%morphological fill 
fill_img = bwconvhull(cbin_img,'objects'); 
% figure; imshow(fill_img)

%remove noise objects
cfill_img = bwareaopen(fill_img, minArea);

%detect region of interest 
roi = regionprops('table',cfill_img);
roi(roi.Centroid(:,1) < leadEdge, :) =[]; %remove data for any points out of main channel

%output - Bounding Box information 
roiBbox = roi.BoundingBox;

end