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
vid1 = VideoWriter('mocap2_Chang1', 'MPEG-4'); 
vid1.FrameRate = 30;
open(vid1)

scale = 20; % vector scaling factor

% Video Cropping
vidFile = 'basketballVid.mov'; % with extension
vid = VideoReader(vidFile); 
frameStart = 200; 
frameStop = 468; 
vidL = frameStop - frameStart; 

cropRange = [275 65 1088 1150]; 
axes = [0, 810, -1150, 0]; 
aspRatio = [813 1150 1]; 

%% Thresholding Video
r = zeros(length(vidL)); 
c = zeros(length(vidL)); 

for k = 1:vidL
    frameSlice = read(vid, k + frameStart);
    
    ImCrop = imcrop(frameSlice, cropRange);
    
    ImThreshW = ImCrop(:, :, 1) > 245 & ImCrop(:, :, 2) > 245 ...
    & ImCrop(:, :, 3) > 245; 
    ImThreshG = ImCrop(:, :, 1) < 50 & ImCrop(:, :, 2) > 200 ...
    & ImCrop(:, :, 3) > 75 & ImCrop(:, :, 3) < 200; 
    ImThreshB = ImCrop(:, :, 1) < 50 & ImCrop(:, :, 2) < 50 ...
    & ImCrop(:, :, 3) > 200; 
    ImThreshR = ImCrop(:, :, 1) > 200 & ImCrop(:, :, 2) < 100 ...
    & ImCrop(:, :, 3) < 100; 

    ImThresh = ImThreshR | ImThreshB | ImThreshG | ImThreshW; 
    
    [r(k, 1), c(k, 1)] = Centroid(ImThreshW);
    [r(k, 2), c(k, 2)] = Centroid(ImThreshG);
    [r(k, 3), c(k, 3)] = Centroid(ImThreshB);
    [r(k, 4), c(k, 4)] = Centroid(ImThreshR);

    figure(1)
    subplot(3, 3, [1 4 7])
    imshow(ImCrop)
    title('Color Cropped Image')
    subplot(3, 3, [2 5 8])
    imshow(ImThresh)
    title('Threshold Image')
    subplot(3, 3, [3 6 9])
    plot(c(:, 1), -r(:, 1), 'k', c(k, 1), -r(k, 1), 'kx', c(:, 2), -r(:, 2), ...
        'g', c(k, 2), -r(k, 2), 'gx', c(:, 3), -r(:, 3), 'b', c(k, 3), ...
        -r(k, 3), 'bx', c(:, 4), -r(:, 4), 'r', c(k, 4), -r(k, 4), 'rx', ...
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


wVx = gradient(c(:, 1)); 
wVy = gradient(r(:, 1));

gVx = gradient(c(:, 2)); 
gVy = gradient(r(:, 2)); 

bVx = gradient(c(:, 3));
bVy = gradient(r(:, 3));

rVx = gradient(c(:, 4));
rVy = gradient(r(:, 4));

r = zeros(length(vidL)); 
c = zeros(length(vidL));

vid2 = VideoWriter('mocap2_Chang2', 'MPEG-4'); 
vid2.FrameRate = 30; 
open(vid2)

for k = 1:vidL
    frameSlice = read(vid, k + frameStart);
    
    ImCrop = imcrop(frameSlice, cropRange);
    
    ImThreshW = ImCrop(:, :, 1) > 245 & ImCrop(:, :, 2) > 245 ...
    & ImCrop(:, :, 3) > 245; 
    ImThreshG = ImCrop(:, :, 1) < 50 & ImCrop(:, :, 2) > 200 ...
    & ImCrop(:, :, 3) > 75 & ImCrop(:, :, 3) < 200; 
    ImThreshB = ImCrop(:, :, 1) < 50 & ImCrop(:, :, 2) < 50 ...
    & ImCrop(:, :, 3) > 200; 
    ImThreshR = ImCrop(:, :, 1) > 200 & ImCrop(:, :, 2) < 100 ...
    & ImCrop(:, :, 3) < 100; 

    ImThresh = ImThreshR | ImThreshB | ImThreshG | ImThreshW; 
    
    [r(k, 1), c(k, 1)] = Centroid(ImThreshW);
    [r(k, 2), c(k, 2)] = Centroid(ImThreshG);
    [r(k, 3), c(k, 3)] = Centroid(ImThreshB);
    [r(k, 4), c(k, 4)] = Centroid(ImThreshR);

    figure(2)
    subplot(2, 2, [1, 3])
    imshow(ImCrop)
    title('Color Cropped Image')
    subplot(2, 2, [2, 4])
    plot(c(:, 1), -r(:, 1), 'k--', c(k, 1), -r(k, 1), 'ko', 'MarkerSize', ...
        7, 'MarkerFaceColor', 'k')
    hold on
    plot(c(:, 2), -r(:, 2), 'g--', c(k, 2), -r(k, 2), 'go', 'MarkerSize', ...
        7, 'MarkerFaceColor', 'g')
    plot(c(:, 3), -r(:, 3), 'b--', c(k, 3), -r(k, 3), 'bo', 'MarkerSize', ...
        7, 'MarkerFaceColor', 'b')
    plot(c(:, 4), -r(:, 4), 'r--', c(k, 4), -r(k, 4), 'ro', 'MarkerSize', ...
        7, 'MarkerFaceColor', 'r')
    plot([c(k, 1) c(k, 2)], [-r(k, 1) -r(k, 2)], 'k', ...
        [c(k, 2) c(k, 3)], [-r(k, 2) -r(k, 3)], 'g', 'LineWidth', 1.5)
    quiver(c(k, 1), -r(k, 1), scale*wVx(k), -scale*wVy(k), 'Color', 'k', ...
        'LineWidth', 2, 'MaxHeadSize', 1)
    quiver(c(k, 2), -r(k, 2), scale*gVx(k), -scale*gVy(k), 'Color', 'g', ...
        'LineWidth', 2, 'MaxHeadSize', 1)
    quiver(c(k, 3), -r(k, 3), scale*bVx(k), -scale*bVy(k), 'Color', 'b', ...
        'LineWidth', 2, 'MaxHeadSize', 1)
    quiver(c(k, 4), -r(k, 4), scale*rVx(k), -scale*rVy(k), 'Color', 'r', ...
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