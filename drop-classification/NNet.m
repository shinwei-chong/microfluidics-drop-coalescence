clear all;
clc;

imds = imageDatastore('TrainingImages');
imds.ReadSize = numpartitions(imds); 
imds.ReadFcn = @(loc)imresize(imread(loc), [28,28]);

clear labels;

labels = xlsread('TrainingLabels');

imds.Labels = categorical(labels);
labelCount = countEachLabel(imds);
img = readimage(imds,1);
size(img)
[imdsTrain, imdsValidation] = splitEachLabel(imds,0.8,'randomize');




layers = [
    imageInputLayer([28 28 1])
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
% 
%     dropoutLayer
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)

%     dropoutLayer
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
      maxPooling2dLayer(2,'Stride',2)
%     dropoutLayer

    convolution2dLayer(3,64,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(3)
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ...
    'MaxEpochs',10, ...
    'ValidationData',imdsValidation, ...
    'Verbose', false, ...
    'Plots', 'training-progress');

% net = trainNetwork(imdsTrain, layers, options);
% 
% YPred = classify(net, imdsValidation);
% YValidation = imdsValidation.Labels;
% 
% accuracy = sum(YPred == YValidation)/numel(YValidation)
    
    
    