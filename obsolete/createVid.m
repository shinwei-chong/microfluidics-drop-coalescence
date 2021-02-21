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
