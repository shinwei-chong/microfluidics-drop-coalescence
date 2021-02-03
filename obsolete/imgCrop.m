function imgCrop(readFrame, roiTable, cropSize, filePath, frameNum)
% function to crop individual region of interest from an input image based on tabulated 
% poperties of the regions of interest (ROIs), obtained using regionprops function.
% cropped image will resized to a user-defined dimension.

% readFrame: video frame that has been read using imread <uint8>
% roiTable: property tables of ROIs, must have 'Bounding Box' column <table>
% cropSize: [width height] <double>
% filePath: folder to save cropped images in <char>
% frameNum: frame number <double>


for i = 1: height(roiTable)
    dim = max([roiTable(i,3:4)]); % this will be the 
    % x-coord of centroid of cropping region
    cx = roiTable(i,1) + roiTable(i,3)/2; 
    % y-coord of centroid of cropping region
    cy = roiTable(i,2) + roiTable(i,4)/2; 
    
    % coordinates of bottom-left vertex of intended crop region 
    xmin = cx - dim/2;
    ymin = cy - dim/2; 
    
    % crop region defined as [x-coord of bottom left point, y-coord of
    % bottom left point, width, height]
    Img = imcrop(readFrame, [xmin, ymin, dim, dim]);
    
    % resize cropped image
    Img = imresize(Img, cropSize);
    
    % save image
    imwrite(Img, [filePath,int2str(frameNum),'_',int2str(i),'.jpg']);   
    
end