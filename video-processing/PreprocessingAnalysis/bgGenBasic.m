function [med_bg mod_bg avg_bg] = bgGenBasic(vid_file,n)
% Extract background image of an input video. Background image will be
% generated using a statistical approach, and based on a user-defined
% number of randomly selected frames. 
%
%   ----- Input -----
%   vid_file: video file name <char>
%   n: number of frames used for background generation <double>
%
%   ----- Output -----
%   med_bg: background generated using median pixel value
%   mod_bg: background generated using mode pixel value
%   avg_bg: background generated using mean pixel value
%
%   Written by: SWC. V1.0, 14-Feb-2021.


% read video 
vid = VideoReader(vid_file); 

% create index of frames to be used for background generation operation
idx = randperm(vid.NumFrames, n); % randomly select n unique frames 

% combine frames pixel values in a 3-D matrix
frameMat = uint8(zeros(vid.Height,vid.Width,n)); %initialise empty matrix 

tic; 
for i = 1:n
    frame = read(vid, idx(i)); %read frame 
    frameMat(:,:,i) = frame; %add frame to matrix 
end 
tEnd = toc; 

disp(['Processed video: ', vid_file])

%background generation 
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

% display images
% figure; imshow(med_bg); title('median')
% figure; imshow(mod_bg); title('mode')
% figure; imshow(avg_bg); title('mean')
figure; 
if vid.Height < 0.5*vid.Width
    montage({med_bg, mod_bg, avg_bg}, 'Size', [3,1]);
else
    montage({med_bg, mod_bg, avg_bg}, 'Size', [1,3]);
end

end

