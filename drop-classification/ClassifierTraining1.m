clear; 
clc;

%Load images

path = fullfile('c:\','Users','callu','Desktop','MATLAB Working Folder','Learning Dataset 2 - Copy');

imds = imageDatastore(path, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
imds.ReadSize = numpartitions(imds);
imds.ReadFcn = @(loc)imresize(imread(loc), [128, 128]); %Is this still needed for our images?

tbl_count = countEachLabel (imds)

%Data validation
[train_set, validation_set] = splitEachLabel(imds, 0.7, 'randomized');

%Create Visual Vocabulary - feature extraction

bag = bagOfFeatures(train_set,'VocabularySize',1000);

%load some images to check histogram

%for i = 1:length(tbl_count.Label)
    %subplot(length(tbl_count.Label),1,i);
    %featureVector = encode(bag, sample.readimage(i));
    %bar(featureVector); title(char(tbl_count.Label(i)));
%end

%Train classification model: multiclass linear SVM classifier (using all
%default values)

classifier = trainImageCategoryClassifier(train_set, bag);

%then test with validation set)

confMatrix_valid = evaluate(classifier, validation_set)

%compute average accuracy
fprintf('Average accuracy = %.2f%%', mean(diag(confMatrix_valid))*100)




