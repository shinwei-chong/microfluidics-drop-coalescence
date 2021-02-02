function vid = createVid(vidname, fps, frameNum)
% function to create video (.avi) from a folder contraining image frames
% vidname: output video file name <char>
% fps: frames per second <double>
% frameNum: total number of frames <double>

vid = VideoWriter(vidname); %create video object
vid.FrameRate = fps; % set frame rate

open(vid); %open the video file for writing 

for i = 1:frameNum
    file_name = sprintf('%d.jpg', i);
    I = imread(file_name); %read image 
    writeVideo(vid, I); %write image to file
end

close(vid); %close file
