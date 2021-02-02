% 06-Nov-2020: first attempt to code for background subtraction and convert
% frames to binary

clear all
close all 
clc 

% 1) load video
vid = VideoReader('SO5_17umL-13Wat_umL-10kfps x4mag_sh50_C001H001S0016.avi');
num_frames = vid.NumFrames %check total num of frames in video
frame_width = vid.Width;
frame_height = vid.Height;

% 2) background generation 
%----------- MEAN -----------
% OPTION 1: use MATLAB mean function, but computationally expensive
% n = 1000; %number of frames used to generate background
% vid_frames = read(vid,[1 n]);
% 
% mean_pix = mean(vid_frames,3); 

% OPTION 2: hardcoded suing for loop
sum_pix = zeros(frame_height, frame_width); %create blank matrix 
n = 250; % number of frames used to generate background
for i=1:n %read in frames used to generate background
    frame = read(vid,i); 
    sum_pix = sum_pix + double(frame); 
end

mean_pix = sum_pix/n; 

subplot(1,3,1)
imshow(uint8(mean_pix))
title('Mean')

% ------------- MIN -----------------
% n = 250; %number of frames used to generate background
vid_frames = read(vid,[1 n]);
% size(vid_frames) %check dimensions 
vid_frames = squeeze(vid_frames); % remove dimensions of length 1
% size(vid_frames) %check dimensions 
min_pix = min(vid_frames,[],3);

subplot(1,3,2)
imshow(uint8(min_pix))
title('Min')

% ------------- MODE -----------------
% n = 250; %number of frames used to generate background
% vid_frames = read(vid,[1 n]);
% size(vid_frames) %check dimensions 
% vid_frames = squeeze(vid_frames); % remove dimensions of length 1
% size(vid_frames) %check dimensions 
mode_pix = mode(vid_frames,3); %computationnally expesive; insufficient memory to compute >500 frames

subplot(1,3,3)
imshow(uint8(mode_pix))
title('Mode')