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
    method = 'modified'; % <-------- user-defined input!!
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
    
    %% ===== Detect drops in each frame =====
    disp('Start drop segmentation process...') 
    % allow access to individual frames for processing
    access_folder = dir([frames_folder,'\*.jpg']);
    len_acc_fold = numel(access_folder); 
    
    % preallocate array to store movie frames
%     F(len_acc_fold) = struct('cdata',[],'colormap',[]);
    new_vid_name = ['Bbox_',vid_name]; %new video file name
    new_vid = VideoWriter(new_vid_name); %create video object
    new_vid.FrameRate = vid.FrameRate; %set frame rate
    
    open(new_vid); %open video file for writing

    
    % set up progress bar
    pbar = waitbar(0,sprintf('Frame 1 of %d', len_acc_fold),'Name','Segmenting drops');  
    
    %loop through each frame in subfolder of extracted frames
    for k = 1:len_acc_fold
        filename = fullfile(frames_folder,sprintf('%d.jpg',k));
        img = imread(filename); %read image
        
        %background subtraction 
%         sub_img = rescale(1-(double(img) - double(bg))); %std diff + inversion.
        sub_img = rescale(abs(double(img) - double(bg))); %abs diff (for C12Tab videos)
%         figure; imshow(sub_img)
        
        %segment drops
        mask = segDrop(sub_img); %custom function
%         figure; imshow(mask)

        %detect region of interest
        roi = regionprops('table',mask);
         % COMMENTED OUT: 20-Feb-2021. May lead to inaccurate estimation in some cases.     
%         % estimate point of entrance to main channel - only have to do this
%         % once.
%         if k == 1
%             roi(roi.Area < 800, :) = []; %remove small objects
%             % first entry in ROI table is the drop nearest to left frame border
%             leadEdge = roi.Centroid(1,1) + 1.4*(roi.BoundingBox(1,3) /2); 
%         end 

        
        %remove data for any points out of main channel
        leadEdge = 0;
        roi(roi.Centroid(:,1) < leadEdge, :) =[]; 
        %remove small objects
        roi(roi.Area < 80, :) = [];
        
        %draw centroid and bounding box on frame
        f = figure('visible', 'off'); % don't want to display plot when run code
%         figure; 
        imshow(filename); 
        
        hold on 

        plot(roi.Centroid(:,1), roi.Centroid(:,2), 'b+'); %draw centroids
        
        for i=1:height(roi) %draw bounding boxes
            rectangle('Position',roi.BoundingBox(i,:),'EdgeColor','b')
        end
        
        hold off
        
        F = getframe(gcf); 
        writeVideo(new_vid, F);
        
%         drawnow 
        close(f);
        
        % update progress bar
        waitbar(k/len_acc_fold,pbar,sprintf('Frame %d of %d', [k len_acc_fold]));
    end
    
    disp('Drop segmentation process complete');
    close(pbar)
    
    %% ===== write frames to create a new movie =====
%     disp('Creating new movie...')
    
%     new_vid_name = ['Bbox_',vid_name]; %new video file name
%     new_vid = VideoWriter(new_vid_name); %create video object
%     new_vid.FrameRate = vid.FrameRate; %set frame rate
    
%     open(new_vid); %open video file for writing
    
    % loop to convert image to frame
%     for h = 1:length(F)
%         new_vid_frame = F(h); 
%         writeVideo(new_vid, new_vid_frame); 
%     end
    
    close(new_vid);

    
    toc % stop timer
    
    disp(['Processing for ', vid_name, ' complete.']);
    disp('---------------------------------------');
    
end
 


