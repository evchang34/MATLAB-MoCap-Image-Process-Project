% Evan Chang
% evchang@unc.edu
% 4/22/2025
% mocap_Chang.m
%
% Records video of person walking with lights and plots position and
% vectors of leg joints

clc
clear
close all

%% Declarations

% Creating video, 'MPEG-4'
vid1 = VideoWriter('mocap1_Chang1', 'MPEG-4'); 
vid1.FrameRate = 30;
open(vid1)
% Thresholding Parameters

% Red light thresholding
rUp1 = 255; % Upper threshold red 
rLow1 = 210; % Lower threshold red 
rUp2 = 35; % Upper threshold green

% Green light thresholding
gUp1 = 255; % Upper threshold green
gLow1 = 230; % Lower threshold green
gUp2 = 125; % Upper threshold red
gUp3 = 200; % Upper threshold blue

% Cyan light thresholding
cUp1 = 50; % Upper threshold red
cUp2 = 245; % Upper threshold green
cLow1 = 200; % Lower threshold green
cLow2 = 240; % Lower threshold blue

% Yellow light thresholding
yUp1 = 240; % Upper threshold red
yUp2 = 95; % Upper threshold blue
yLow1 = 150; % Lower threshold red
yLow2 = 180; % Lower threshold green

% Video Cropping
vidFile = 'walkVid.mov'; % with extension
vid = VideoReader(vidFile); 
frameStart = 125; % starting frame
frameStop = 199; % ending frame
vidL = frameStop - frameStart; % video length (frames)

cropRange = [0 500 1920 500]; % crop range of video
axes = [0, 1920, -500, 0]; % axes dimensions
aspRatio = [1920 500 1]; % aspect ratio of video

%% Thresholding Video
r = zeros(length(vidL)); 
c = zeros(length(vidL)); 

for k = 1:vidL
    frameSlice = read(vid, k + frameStart);
    
    ImCrop = imcrop(frameSlice, cropRange);
       
    ImThreshR = (ImCrop(:, :, 1) > rLow1 & ImCrop(:, :, 1) < rUp1 & ...
        ImCrop(:, :, 2) < rUp2); 
    ImThreshG = (ImCrop(:, :, 2) > gLow1 & ImCrop(:, :, 2) < gUp1 & ...
        ImCrop(:, :, 1) < gUp2 & ImCrop(:, :, 3) < gUp3); 
    ImThreshC = (ImCrop(:, :, 1) < cUp1 & ImCrop(:, :, 2) > cLow1 & ...
        ImCrop(:, :, 2) < cUp2 & ImCrop(:, :, 3) > cLow2);
    ImThreshY = (ImCrop(:, :, 1) < yUp1 & ImCrop(:, :, 1) > yLow1 & ...
        ImCrop(:, :, 2) > yLow2 & ImCrop(:, :, 3) < yUp2);

    ImThresh = ImThreshY | ImThreshC | ImThreshG | ImThreshR; 

    [r(k, 1), c(k, 1)] = Centroid(ImThreshR);
    [r(k, 2), c(k, 2)] = Centroid(ImThreshG);
    [r(k, 3), c(k, 3)] = Centroid(ImThreshC);
    [r(k, 4), c(k, 4)] = Centroid(ImThreshY);

    figure(1)
    subplot(3, 3, [1 2 3])
    imshow(ImCrop)
    title('Color Cropped Image')
    subplot(3, 3, [4 5 6])
    imshow(ImThresh)
    title('Threshold Image')
    subplot(3, 3, [7 8 9])
    plot(c(:, 1), -r(:, 1), 'r', c(k, 1), -r(k, 1), 'rx', c(:, 2), -r(:, 2), ...
        'g', c(k, 2), -r(k, 2), 'gx', c(:, 3), -r(:, 3), 'c', c(k, 3), ...
        -r(k, 3), 'cx', c(:, 4), -r(:, 4), 'y', c(k, 4), -r(k, 4), 'yx', ...
        'LineWidth', 1.2)
    pbaspect(aspRatio)
    axis(axes)
    xticklabels([])
    yticklabels([])   
    title('Joint Centroids')
    drawnow
    
    frame = getframe(figure(1)); 
    writeVideo(vid1, frame); 
end

close(vid1)

rVx = gradient(c(:, 1)); 
rVy = gradient(r(:, 1));

gVx = gradient(c(:, 2)); 
gVy = gradient(r(:, 2)); 

cVx = gradient(c(:, 3));
cVy = gradient(r(:, 3));

yVx = gradient(c(:, 4));
yVy = gradient(r(:, 4));

r = zeros(length(vidL)); 
c = zeros(length(vidL));

vid2 = VideoWriter('mocap1_Chang2', 'MPEG-4'); 
vid2.FrameRate = 30; 
open(vid2)
for k = 1:vidL
    frameSlice = read(vid, k + frameStart);
    
    % Cropping 
    ImCrop = imcrop(frameSlice, cropRange);
    
    % Thresholding
   
    ImThreshR = (ImCrop(:, :, 1) > rLow1 & ImCrop(:, :, 1) < rUp1 & ...
        ImCrop(:, :, 2) < rUp2); 
    ImThreshG = (ImCrop(:, :, 2) > gLow1 & ImCrop(:, :, 2) < gUp1 & ...
        ImCrop(:, :, 1) < gUp2 & ImCrop(:, :, 3) < gUp3); 
    ImThreshC = (ImCrop(:, :, 1) < cUp1 & ImCrop(:, :, 2) > cLow1 & ...
        ImCrop(:, :, 2) < cUp2 & ImCrop(:, :, 3) > cLow2);
    ImThreshY = (ImCrop(:, :, 1) < yUp1 & ImCrop(:, :, 1) > yLow1 & ...
        ImCrop(:, :, 2) > yLow2 & ImCrop(:, :, 3) < yUp2);

    ImThresh = ImThreshY | ImThreshC | ImThreshG | ImThreshR; 
    
    % Calculating centroids
    [r(k, 1), c(k, 1)] = Centroid(ImThreshR);
    [r(k, 2), c(k, 2)] = Centroid(ImThreshG);
    [r(k, 3), c(k, 3)] = Centroid(ImThreshC);
    [r(k, 4), c(k, 4)] = Centroid(ImThreshY);
    
    figure(2)
    subplot(2, 2, [1, 2])
    imshow(ImCrop)
    title('Color Cropped Image')
    subplot(2, 2, [3, 4])
    plot(c(:, 1), -r(:, 1), 'r--', c(k, 1), -r(k, 1), 'ro', 'MarkerSize', ...
        7, 'MarkerFaceColor', 'r')
    hold on
    plot(c(:, 2), -r(:, 2), 'g--', c(k, 2), -r(k, 2), 'go', 'MarkerSize', ...
        7, 'MarkerFaceColor', 'g')
    plot(c(:, 3), -r(:, 3), 'c--', c(k, 3), -r(k, 3), 'co', 'MarkerSize', ...
        7, 'MarkerFaceColor', 'c')
    plot(c(:, 4), -r(:, 4), 'y--', c(k, 4), -r(k, 4), 'yo', 'MarkerSize', ...
        7, 'MarkerFaceColor', 'y')
    plot([c(k, 1) c(k, 2)], [-r(k, 1) -r(k, 2)], 'r', ...
        [c(k, 2) c(k, 3)], [-r(k, 2) -r(k, 3)], 'g', ...
        [c(k, 3) c(k, 4)], [-r(k, 3) -r(k, 4)], 'c', 'LineWidth', 1.5)
    quiver(c(k, 1), -r(k, 1), 4*rVx(k), 4*rVy(k), 'Color', 'r', ...
        'LineWidth', 2, 'MaxHeadSize', 1)
    quiver(c(k, 2), -r(k, 2), 4*gVx(k), 4*gVy(k), 'Color', 'g', ...
        'LineWidth', 2, 'MaxHeadSize', 1)
    quiver(c(k, 3), -r(k, 3), 2*cVx(k), 2*cVy(k), 'Color', 'c', ...
        'LineWidth', 2, 'MaxHeadSize', 1)
    quiver(c(k, 4), -r(k, 4), 2*yVx(k), 2*yVy(k), 'Color', 'y', ...
        'LineWidth', 2, 'MaxHeadSize', 1)
    hold off
    pbaspect(aspRatio)
    axis(axes)
    xticklabels([])
    yticklabels([]) 
    xticks([])
    yticks([])
    title('Stick Figure')
    drawnow

    frame = getframe(figure(2)); 
    writeVideo(vid2, frame); 
end

close(vid2)
