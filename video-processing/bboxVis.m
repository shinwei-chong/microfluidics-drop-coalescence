% SUMMARY: Script to process a user-input video and output a new video to
% visualise the bounding boxes. 
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
% 2) Obtain bounding box info on individual drops 
% 3) Create new video from video frames overlaid with bounding boxes 
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

% Version 2.0. SWC, 19-Feb-2021.


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
    disp('Extracting individual frames from video...')
    
    frames_folder = ['FRAMES_', vid_name]; %name of folder to store extracted frames
    
    mkdir(frames_folder) %create sub-folder to store extracted frames
    addpath(frames_folder) 
    
    nframes = totframes; %number of frames to extract <---------- user-defined input!!
    
    idx = round(linspace(1,totframes, nframes)); %vector of index of frames to extract

    for j=1:numel(idx)
        frame = read(vid,idx(j));
        imwrite(frame,[frames_folder,'\',int2str(idx(j)),'.jpg']);
    end
    
    disp('Frames extraction complete.')
    
    %% ===== Detect drops in each frame + Write to new video =====
    disp('Start drop segmentation process...') 
    % allow access to individual frames for processing
    access_folder = dir([frames_folder,'\*.jpg']);
    len_acc_fold = numel(access_folder); 
    
    % => CREATE OBJECT VIDEO
    new_vid_name = ['Bbox_',vid_name]; %new video file name
    new_vid = VideoWriter(new_vid_name); 
    new_vid.FrameRate = vid.FrameRate; %set frame rate
    open(new_vid); %open video file for writing

    % => SET UP PROGRESS BAR
    pbar = waitbar(0,sprintf('Frame 1 of %d', len_acc_fold),'Name','Creating video');  
    
    % loop through each frame in subfolder of extracted frames
    for k = 1:len_acc_fold
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
        
        
%% COMMENTED OUT: 20-Feb-2021. May lead to inaccurate estimation in some cases.     
%         % estimate point of entrance to main channel - only have to do this
%         % once.
%         if k == 1
%             roi(roi.Area < 800, :) = []; %remove small objects
%             % first entry in ROI table is the drop nearest to left frame border
%             leadEdge = roi.Centroid(1,1) + 1.4*(roi.BoundingBox(1,3) /2); 
%         end 
%%

        % remove data for any points out of main channel
        leadEdge = 100;
        roi(roi.Centroid(:,1) < leadEdge, :) =[]; 
        %remove small objects
        roi(roi.Area < 80, :) = [];
        
        % => DRAW CENTROID + BOUNDING BOX ON FRAME
        f = figure('visible', 'off'); % don't want to display plot when run code

        imshow(filename); 
        
        hold on 

        plot(roi.Centroid(:,1), roi.Centroid(:,2), 'b+'); %draw centroids
        
        for i=1:height(roi) %draw bounding boxes
            rectangle('Position',roi.BoundingBox(i,:),'EdgeColor','b')
        end
        
        hold off
        
        F = getframe(gcf); 
        writeVideo(new_vid, F); %write the newly generated frame to video
        
        close(f);
        
        % => UPDATE PROGRESS BAR
        waitbar(k/len_acc_fold,pbar,sprintf('Frame %d of %d', [k len_acc_fold]));
        
    end
    
    close(pbar); %close progress bar
    
    close(new_vid); %close video 

    toc % stop timer
    
    disp(['Processing for ', vid_name, ' complete.']);
    disp('---------------------------------------');
    
end

