% SUMMARY: Script to crop drop images suitable for machine learning
% classification model. 
%
% USER NOTES: 
% 1)Script file should be stored in the folder along with all the videos 
%   (.avi format) intended to be processed.
% 2)Each video processed will output:
%    - folder containing original extracted frames 
%    - video file with bounding boxes visualised
%
% HIGH-LEVEL WORKFLOW: 
% 1) Extract individual frames from video 
% 2) Obtain bounding box info of individual drops 
% 3) Crop and save drop images 
%
% DEFAULT PARAMETERS: 
% 1) background image generation method: Complex method - original version,
%    based on 40 randomly selected frames. 
%    Other options: Basic statistical approach (median/ mean / mode);
%                   Complex method - modified version (for C12Tab videos)
%
% 2) number of frames extracted from each video: ALL frames
%
% 3) background subtraction method: standard difference + inversion.
%    Other option: absolute difference (use for C12Tab videos)
%
% 4) treshold value for binarisation: determine using Otsu's method
%    Note: for C12 Tab videos, need to also apply standard filter and
%    scale-down factor of threshold value determine from Otsu's method.
%    Change this in segDrop.m function file.
%
% 5) leading edge for ROI detection: x=100 (any drops with x-coord <100 will be removed; 
%    aims to only detect drops in main flow channel).
%    Note: for vertical flows, change this to 0! Otherwise, all drops would
%    be removed. 
%   
% 6) Crop size: 64x64 pix

% Version 2.0. SWC, 21-Feb-2021.


%% read all videos in the filepath

vid_idx = dir('*.avi'); 

%% Start of process
for i = 1: numel(vid_idx) % loop through each video in directory
    tic % start timer
  
    %% ===== load video =====
    vid_name = vid_idx(i).name; % get file name of video
    disp(['Processed video: ', vid_name])
    
    global vid totframes leadEdge
    vid = VideoReader(vid_name); % read video 
    totframes = vid.Numframes; %get total number of frames in video
    
    
    %% ===== background generation =====
    disp('Generating background image...');
    
    % ----- using basic statistical approach -----
%     n = 150; % number of frames to use for background generation  <-------- user-defined input!!
%     method = 'median'; % 'median' / 'mean' / 'mode' / 'all' <-------- user-defined input!!
%     bg = bgGenBasic(n,method); %custom function
    
    % ----- using modified statistical approach -----
    n = 40; % number of frames to use for background generation  <-------- user-defined input!!
    method = 'original'; % <-------- user-defined input!!
    % 'original': WAT, DYE, TRI, SDS, 
    % 'modified': C12Tab, TRI, SDS
    bg = bgGenCmplx(n,method); %custom function

    disp('Background image generation complete.')
    
    %% ===== extract video frames & save in temporary folder =====
    disp('Extracting individual frames from video...');
    
    frames_folder = ['FRAMES_', vid_name(1:end-4)]; %name of folder to store extracted frames
    
    mkdir(frames_folder) %create sub-folder to store extracted frames
    addpath(frames_folder)  
    
    nframes = totframes; %number of frames to extract <---------- user-defined input!!idx = round(linspace(1,totframes, nframes)); %vector of index of frames to extract

    idx = round(linspace(1,totframes, nframes)); %vector of index of frames to extract
    
    for j=1:numel(idx)
        frame = read(vid,idx(j));
        imwrite(frame,[frames_folder,'\',int2str(idx(j)),'.jpg']);
    end
    
    disp('Frames extraction complete.')
    
    %% ===== PRE-PROCESSING/ DROP SEGMENTATION =====
    % => create sub-folder to store cropped images
    crop_folder = ['CROPS_', vid_name(1:end-4)]; %name of folder to store cropped images
    mkdir(crop_folder) 
    addpath(crop_folder)


    % => access individual frames
    access_folder = dir([frames_folder,'\*.jpg']);
    len_acc_fold = numel(access_folder); 
    
    % => SET UP PROGRESS BAR
    pbar = waitbar(0,sprintf('Frame 1 of %d', len_acc_fold),'Name','Cropping drop images');
    
    for k = 1:len_acc_fold %loop through each frame
        filename = fullfile(frames_folder,sprintf('%d.jpg',k)); %get file name
        img = imread(filename); %read image
    
        % => BACKGROUND SUBTRACTION
        % ----- standard difference + inversion -----
        % SUITABLE FOR: WAT, SDS, TRI, DYE
        sub_img = rescale(1-(double(img) - double(bg)));
        
        % ----- absolute difference -----
        % USE FOR: C12Tab
%         sub_img = rescale(abs(double(img) - double(bg))); 

        %figure; imshow(sub_img)
        
        % => SEGMENT DROPS
        mask = segDrop(sub_img); %custom function
%         figure; imshow(mask)

        % => DETECT REGION OF INTEREST
        roi = regionprops('table',mask);
        
        % remove data for any points out of main flow channel
        leadEdge = 100; % <----- user-defined input!!
        roi(roi.Centroid(:,1) < leadEdge, :) =[]; 
        %remove small objects
        roi(roi.Area < 80, :) = [];
  
        %% ===== CROP IMAGES =====
        roiTable = roi.BoundingBox; % just want information on bounding boxes
        cropDim = [64 64]; %final image crop size <-------- user-defined input!!
        
        for z = 1: height(roiTable)
            dim = 1.4*max([roiTable(z,3:4)]); % this will be the width/ height of square cropped area
            
            % x-coord of centroid of cropping region
            cx = roiTable(z,1) + roiTable(z,3)/2;
            % y-coord of centroid of cropping region
            cy = roiTable(z,2) + roiTable(z,4)/2;
            
            % coordinates of bottom-left vertex of intended crop region
            xmin = cx - dim/2 ;
            ymin = cy - dim/2 ;
            
            % crop region defined as [x-coord of bottom left point, y-coord of
            % bottom left point, width, height]
            cropImg = imcrop(img, [xmin, ymin, dim, dim]);
            
            % resize cropped image
            cropImg = imresize(cropImg, cropDim);
            
            % save image
            imwrite(cropImg, [crop_folder,'\',int2str(k),'_',int2str(z),'.jpg']);
            
            % => UPDATE PROGRESS BAR
            waitbar(k/len_acc_fold,pbar,sprintf('Frame %d of %d', [k len_acc_fold]));
        end
        
    end
    
    toc % stop timer
    
end
