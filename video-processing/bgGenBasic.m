function bg = bgGenBasic(n,method)
% Extract background image of a video (get from global var linked to main script). 
% Background image will be generated using a statistical approach, and 
% based on a user-defined number of frames. 
%
%   ----- Input -----
%   n: number of frames used for background generation <double>
%   method: 'median' / 'mean' / 'mode' / 'All' (to generate 3 different
%   backgrounds using median, mean and mode approach)
%
%   ----- Output -----
%   bg: background generated 

%   Written by: SWC. V1.0, 14-Feb-2021.


% % read video 
% vid = VideoReader(vid_file); 

global vid

% create index of frames to be used for background generation operation
% idx = randperm(vid.NumFrames, n); % randomly select n unique frames 
idx = round(linspace(1,vid.NumFrames,n)); % select n linearly spaced frames

% combine frames pixel values in a 3-D matrix
frameMat = uint8(zeros(vid.Height,vid.Width,n)); %initialise empty matrix 

tic; 
for i = 1:n
    frame = read(vid, idx(i)); %read frame 
    frameMat(:,:,i) = frame; %add frame to matrix 
end 
tEnd = toc; 

% disp(['Processed video: ', vid_file])

%background generation 
switch method 
    case 'median' 
        tic;
        bg = median(frameMat,3); %median
        tEnd1 = toc;
        disp(sprintf('Median; Elapsed time = %.2f', tEnd+tEnd1))
        
%         figure; imshow(bg); title('median')
        
    case 'mode' 
        tic;
        bg = mode(frameMat,3); %mode
        tEnd2 = toc;
        disp(sprintf('Mode; Elapsed time = %.2f', tEnd+tEnd2))
        
%         figure; imshow(bg); title('mode')
    
    case 'mean'
        tic;
        bg = mean(frameMat,3,'native'); % mean
        tEnd3 = toc;
        disp(sprintf('Mean; Elapsed time = %.2f', tEnd+tEnd3))
        
%         figure; imshow(bg); title('mean')
        
    case 'all'
        tic;
        med_bg = median(frameMat,3); %median
        tEnd1 = toc;
        disp(sprintf('Median; Elapsed time = %.2f', tEnd+tEnd1))
        
        tic;
        mod_bg = mode(frameMat,3); %mode
        tEnd2 = toc;
        disp(sprintf('Mode; Elapsed time = %.2f', tEnd+tEnd2))
        
        tic;
        avg_bg = mean(frameMat,3,'native'); % mean
        tEnd3 = toc;
        disp(sprintf('Mean; Elapsed time = %.2f', tEnd+tEnd3))
        
        bg = [med_bg mod_bg avg_bg];
        
%         if vid.Height < 0.5*vid.Width
%             montage({med_bg, mod_bg, avg_bg}, 'Size', [3,1]);
%         else
%             montage({med_bg, mod_bg, avg_bg}, 'Size', [1,3]);
%         end
end

end

