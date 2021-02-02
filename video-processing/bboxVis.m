% SUMMARY: Script to process a user-input video and output a new video to
% visualise the bounding boxes. 

% USER NOTES: 
% 1)Script file should be stored in the folder along with all the videos 
%   (.avi format) intended to be processed.
% 2)Just run script file and it should automatically do the job.
% 3)Each video processed will output:
%    - folder containing original extracted frames* 
%    - folder containing extracted frames with bounding boxes visualised*
%    - video file with bounding boxes visualised
% * explicitly exported images as folders for now for debugging/ validation
% purposes; but if considered unnecessary, can update code to remove this,
% which should also make processing time much quicker.

% WORKFLOW: 
% 1) Extract individual frames from video (function:extractVidFrames)
% 2) Obtain bounding box info on individual drops (function: vidFramePreprocess)
% 3) Create new video from video frames overlaid with bounding boxes (function: createVid)
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

% Version 1.0. SWC, 02-Feb-2021.


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
    
    %% ===== Overlay video frames with bounding boxes =====
    % create sub-folder to store labelled images 
    framesBbox_folder = sprintf('framesBbox_%d', i); %name of folder to store extracted frames with bounding boxes visualised
    mkdir(framesBbox_folder)
    addpath(framesBbox_folder)
    
    % define custom function inputs 
    t = 0.2; %treshold value  <-------- user-defined input!!
    minArea = 1800; % <-------- user-defined input!!
        % noise removal: drops less than this area will be excluded 
    leadEdge = 140; % <-------- user-defined input!!
        % so any objects positioned at x<140 will not be cropped
    
    % access individual frames
    access_folder = dir([sprintf('extractedFrames_%d', i),'\*.jpg']);
    
    %loop through each frame in subfolder
    for k = 1:numel(access_folder)
        filename = fullfile(frames_folder,sprintf('%d.jpg',k));
%         img = imread(filename); 
    
        vidFramePreprocess(filename, med_pix, t, minArea, leadEdge, framesBbox_folder, k);
    end
    
    %% ===== Create new video =====
    vidBbox_name = ['Bbox',vid_name]; %new video file name
    labelled_vid = createVid(vidBbox_name, vid.FrameRate, framesBbox_folder, nframes);% <-------- user-defined input!!
    % inputs: (name the file to be saved as, frame rate, name of folder 
    % contaning frames to make new video, total number of frames in the folder)
    
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
function vidFramePreprocess(filename, bg, t, minArea, leadEdge, foldername, k)
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
sub_img = bg - img; 
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

% save this as a new image
print(fullfile(foldername, sprintf('%d.jpg',k)), '-djpeg')
% saveas(f, fullfile(foldername,filename), 'jpeg'); 

close(f)

end

%%
function vid = createVid(vidname, fps, framesFolder, frameNum)
% function to create video (.avi) from a folder containing image frames
%
%   vidname: output video file name <char>
%   fps: frames per second <double>
%   framesFolder: name of folder containing the extracted frames overlaid
%   with bounding boxes <char>
%   frameNum: total number of frames <double>

vid = VideoWriter(vidname); %create video object
vid.FrameRate = fps; % set frame rate

open(vid); %open the video file for writing 

for i = 1:frameNum
    file_name = fullfile(framesFolder,sprintf('%d.jpg', i));
    I = imread(file_name); %read image 
    writeVideo(vid, I); %write image to file
end

close(vid); %close file

end