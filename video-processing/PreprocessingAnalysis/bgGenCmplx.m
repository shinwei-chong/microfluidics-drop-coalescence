function R = bgGenCmplx(vid_file,n)
% Extract background image of an input video. Background image will be
% generated using a modified statistical approach, and based on a user-defined
% number of randomly selected frames. 
%
%   ----- Input -----
%   vid_file: video file name <char>
%   n: number of frames used for background generation <double>
%
%   ----- Output -----
%   cmplx_bg: background generated using algorithm adapted from ADM concept
%   (Chong et al., 2016)


% read video 
vid = VideoReader(vid_file); 

% create index of frames to be used for background generation operation
idx = randperm(vid.NumFrames, n); % randomly select n unique frames 

% first, find median pixel value across n randomly selected frames
frameMat = uint8(zeros(vid.Height,vid.Width,n)); %initialise empty matrix 

disp(['Processed video: ', vid_file])

tic;

for i = 1:n
    frame = read(vid, idx(i)); %read frame 
    frameMat(:,:,i) = frame; %add frame to matrix 
end 

bg = median(frameMat,3); %median
Imin = double(min(bg,[],'all')); %get min pixel value
Imax = double(max(bg,[],'all')); %get max pixel value

% then, iteratively reduce background noise
f = randperm(vid.NumFrames,n); % randomly select another n unique frames

Al2 = (245*(double(bg)-Imin))/(Imax-Imin) + 10;
R = bg;

for nf = 1:length(f)
    F = read(vid, f(nf));
    Fl2 = (245*(double(F)-Imin))/(Imax-Imin) + 10;
    
    D = 255.* Fl2 ./ Al2;
    D(Al2 <= 0 | Fl2 > Al2) = 255;
    D(Fl2 < 0) = 0;
%     D = mat2gray(D);
    D = rescale(D);
    
    B1 = imbinarize(D);
    B2 = imcomplement(B1);
    
    B2_fill = bwconvhull(B2,'object');
%     B2_fill = bwareaopen(B2_fill,800);
    A2 = regionprops('table',B2_fill,'BoundingBox');
%     se = strel('disk', round(0.3*min(A2.BoundingBox(:,3))));
    B2_dilate = imdilate(B2_fill,strel('disk',8));
    M2 = uint8(double(R).*double(B2_dilate));
    
    B1_dilate = imcomplement(B2_dilate);
    M1 = uint8(double(B1_dilate).*double(F));
    
    R = M1+M2;
end

toc;


end

