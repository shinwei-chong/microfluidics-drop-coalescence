% SUMMARY: Script to automatically crop drop images suitable for machine learning
% classification model. 

% USER NOTES: 
% 1)Script file should be stored in the folder along with all the videos (.avi
% format) intended to be processed.
% 2)Just run script file and it should automatically do the job.
% 3)Each video processed will output 2 new folders: 
%   i) folder containing individual extracted frames
%   ii) folder containing drop images (naming convention: frame#_drop#)

% WORKFLOW: 
% 1) Extract individual frames from video (function:extractVidFrames)
% 2) Obtain bounding box info on individual drops (function: Process4Crop)
% 3) Crop images (function: imgCrop)
% Note that all functions are at the end of the script

% DEFAULT PARAMETERS: 
% 1) background image generation method: median pixel value across 200 frames
% 2) number of frames extracted from each video: ALL frames
% 3) treshold value for binarisation: 0.2
% 4) cropped image dimensions: 128x128 pixels
% 5) minimum area for region of interest (ROI) detection: 1800 pix^2 
%    (anything smaller will be treated as noise object
% 6) leading edge for ROI detection: x==140 (aims to only detect drops in main
% flow channel)

% Version 1.0. SWC, 29-Jan-2021.


%% read all videos in the filepath

vid_idx = dir('*.avi'); 

%% Start of process
for i = 1: numel(vid_idx) % loop through each video in directory
    tic % start timer
  
    %% ===== load video =====
    vid_name = vid_idx(i).name; % get file name of video
    vid = VideoReader(vid_name); % read video 
    totframes = vid.Numframes; %get total number of frames in video
    
    
    %% ===== background generation =====
    n = 200; % number of frames to use for background generation  <-------- user-defined input!!
    idx = round(linspace(1,totframes,n)); %vector of index of frame number to be extracted

    frameMat = []; 

    % for loop to create matrix of frames for generating background image
    for j=1:numel(idx)
        frame = read(vid,idx(j)); 
        frameMat = cat(3,frameMat,frame);
    end
    
    % compute median of each pixel across all frames in matrix
    med_pix = median(frameMat,3);%<-------- user-defined input!!
    
    
    %% ===== extract video frames & save in temporary folder =====
    frames_folder = sprintf('extractedFrames_%d', i); %name of folder to store extracted frames
    
    mkdir(frames_folder) %create sub-folder to store extracted frames
    addpath(frames_folder) 
    
    nframes = totframes; %number of frames to extract <---------- user-defined input!!
    
    % uses a custom function defined below..
    extractVidFrames(vid, totframes, nframes,frames_folder);
    % inputs: [video file, total number of frames in video, number of
    % frames to extract from video, folder to save extracted frames in]
    
    
    %% ===== crop images =====
    %create sub-folder to store cropped images
    crop_folder = sprintf('cropImg_%d', i); %name of folder to store cropped images
    mkdir(crop_folder) 
    addpath(crop_folder)
     
    % define custom function inputs 
    t = 0.2; %treshold value  <-------- user-defined input!!
    minArea = 1800; % <-------- user-defined input!!
        % noise removal: drops less than this area will be excluded 
    leadEdge = 140; % <-------- user-defined input!!
        % so any objects positioned at x<140 will not be cropped
    
    cropDim = [128 128]; %final image crop size <-------- user-defined input!!


    % access individual frames
    access_folder = dir([sprintf('extractedFrames_%d', i),'\*.jpg']); 
    
    for k = 1:numel(access_folder) %loop through each frame
        filename = fullfile(frames_folder,sprintf('%d.jpg',k));
        img = imread(filename); 
    
        %extract information on Bounding boxes
        roiBbox = Process4Crop(img, med_pix, t, minArea, leadEdge); 
        
        %use bounding box coordinates to crop image 
        imgCrop(img, k, roiBbox, cropDim, crop_folder);
    end
    
    toc % stop timer
end



%% 

function extractVidFrames(vid,nTot,nExtractframes,filepath)
%Function to extract user-defined number of frames from input video 
%and save the individual frames as .jpg in the defined path directory.
%   vid: video file that was read using VideoReader fucntion  <VideoReader>
%   nTot: total number of frames in the video <double>
%   nExtractframes: number of frames to extract <double> 
%   filepath: path directory to save images in <char>


idx = round(linspace(1,nTot, nExtractframes)); %vector of index of frames to extract

for i=1:numel(idx) 
    frame = read(vid,idx(i)); 
    imwrite(frame,[filepath,'\',int2str(idx(i)),'.jpg']); 
end

end


%%
function roiBbox = Process4Crop(readFrame, bg, t, minArea, leadEdge)
% Function to pre-process individual video frame to detect ROIs ready for cropping. 
% Output is a table containing the Bounding Box properties of all the ROIs detected in the user-defined image frame.
% Workflow: background subtraction; tresholding & binarisation;
% morphological close and fill; draw bounding box
%
%   readFrame: video frame that has been read using imread <VideoReader>
%   bg: background image file name <var>
%   t: treshold value (range: 0-1)<double>
%   minArea: minimum pixel area to keep <double>
%   leadEdge: x-coord of entrance point to main flow channel <double> 


%background subtraction (standard diff: background - video frame)
sub_img = bg - readFrame; 
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

%output - Bounding Box information 
roiBbox = roi.BoundingBox;

end


%%
function imgCrop(readFrame, frameNum, roiTable, cropSize, filePath)
% function to crop individual region of interest from an input image based on tabulated 
% poperties of the regions of interest (ROIs), obtained using regionprops function.
% cropped image will resized to a user-defined dimension.

%   readFrame: video frame that has been read using imread <VideoReader>
%   frameNum: frame number <double>
%   roiTable: property tables of ROIs, must have 'Bounding Box' column <table>
%   cropSize: [width height] <double>
%   filePath: folder to save cropped images in <char>


for i = 1: height(roiTable)
    
    dim = max([roiTable(i,3:4)]); % find the larger value between width and height of bounding box
    
    % x-coord of centroid of cropping region
    cx = roiTable(i,1) + roiTable(i,3)/2; 
    % y-coord of centroid of cropping region
    cy = roiTable(i,2) + roiTable(i,4)/2; 
    
    % coordinates of bottom-left vertex of intended crop region 
    xmin = cx - dim/2;
    ymin = cy - dim/2; 
    
    % crop region defined as [x-coord of bottom left vertex, y-coord of
    % bottom left vertex, width, height]
    Img = imcrop(readFrame, [xmin, ymin, dim, dim]);
    
    % resize cropped image
    Img = imresize(Img, cropSize);
    
    % save image
    imwrite(Img, [filePath,'\',int2str(frameNum),'_',int2str(i),'.jpg']);   
    
end

end
