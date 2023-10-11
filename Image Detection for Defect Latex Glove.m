% DIRTY GLOVES
% Read the image
image = imread('gloves_dirty.jpg');

% Convert the image to grayscale
grayImage = rgb2gray(image);

% Apply color thresholding to detect dirty color
yellowThreshold = 70; %Adjustable(to detect the accuracy of yellow>dirty color)
yellowMask = grayImage > yellowThreshold;

% Apply edge detection to enhance the dirty edges
edgeImage = edge(yellowMask, 'Canny');

% Remove noise from the image
edgeImage = bwareaopen(edgeImage, 50); %Adjust to the parameter to increase the accuracy

% Perform morphological operations
se = strel('disk', 5);
morphedImage = imclose(edgeImage, se);
morphedImage = imfill(morphedImage, 'holes');

% Find connected components in the images
cc = bwconncomp(morphedImage);
numObjects = cc.NumObjects;

% Display the results
imshow(image);
hold on;

% Draw bounding boxes around the detected dirty glove
props = regionprops(cc, 'BoundingBox');
for i = 1:numObjects
    rectangle('Position', props(i).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
end

hold off;

clc
clear all
close all


% STAIN GLOVES
% Read the image of yellow gloves with stain
image = imread('gloves_stain.jpg');

% Convert the image to grayscale
grayImage = rgb2gray(image);

% Apply color thresholding to detect stain color
yellowThreshold = 80; %Adjustable(to detect the accuracy of yellow>stain color)
yellowMask = grayImage > yellowThreshold;

% Apply edge detection
edgeImage = edge(yellowMask, 'Canny');

% Remove noise from the image
edgeImage = bwareaopen(edgeImage, 40); %Adjust to the parameter to increase the accuracy

% Perform morphological operations
se = strel('disk', 5);
morphedImage = imclose(edgeImage, se);
morphedImage = imfill(morphedImage, 'holes');

% Find connected components in the images
cc = bwconncomp(morphedImage);
numObjects = cc.NumObjects;

% Display the results
imshow(image);
hold on;

% Draw bounding boxes around the detected stain glove
props = regionprops(cc, 'BoundingBox');
for i = 1:numObjects
    rectangle('Position', props(i).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
end

hold off;

clc
clear all
close all

% TORN GLOVES
% Read the image of yellow gloves with tears
image = imread('gloves_torn.jpg');

% Convert the image to grayscale
grayImage = rgb2gray(image);

% Apply edge detection
edgeImage = edge(grayImage, 'Canny');

% Remove small objects (noise) from the edge image
edgeImage = bwareaopen(edgeImage, 500); %Adjust to the parameter to increase the accuracy

% Perform morphological operations to enhance the tear objects
se = strel('disk', 1);
morphedImage = imclose(edgeImage, se);
morphedImage = imfill(morphedImage, 'holes');

% Find connected components in the image
cc = bwconncomp(morphedImage);
numObjects = cc.NumObjects;

% Display the results
imshow(image);
hold on;

% Draw bounding boxes around the detected tears
props = regionprops(cc, 'BoundingBox');
for i = 1:numObjects
    rectangle('Position', props(i).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
end

hold off;

