
clc;


access_folder = dir([sprintf('cropImg_16'),'\*.jpg']);

imagename = zeros(numel(access_folder));

for i = 1:numel(access_folder)
    [pathstr, name, ext] = fileparts(access_folder(i).name);
    newname = strrep(name, '_', '.');
    imgname(i) = str2double(newname);
end

name = imgname.';

labelIdx = predict(classifier,imageDatastore('cropImg_16'));

% for i = 1:numel(access_folder)
%      frame = imread(access_folder(i).name);
%      labelIdx(i) = predict(classifier, frame);
%      labelIdx(i) = classify(net, frame);
% end

labels = labelIdx.';

%frames = imageDatastore('cropImg_1');



%[labelIdx, score] = predict(classifier, frames);

