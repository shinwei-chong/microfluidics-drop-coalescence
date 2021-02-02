function extractVidFrames(filename,num_frames,filepath)
%Function to extract user-defined number of frames from input video 
%and save the individual frames as .jpg in the defined path directory.
%   filename: 'video file name' <char>
%   num_frames: number of frames to extract <int> 
%   filepath: 'path directory to save images in' <char>

vid = VideoReader(filename);
%check total num of frames in video
nTot = vid.NumFrames;

idx = round(linspace(1,nTot, num_frames)); %vector of index of frames to extract

for i=1:numel(idx) 
    frame = read(vid,idx(i)); 
    imwrite(frame,[filepath,int2str(idx(i)),'.jpg']); 
end

end

