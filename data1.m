clc
clear all
close all
t=cputime; 
% how to extract frames from any video
A=VideoReader('data1.avi');
get(A) % get the information about video like settings

% display video
% A=read(A);
% implay(A);

%  V= [H, W, B, F]
F = A.NumberOfFrames; % number of frames in the video
H = A.Height; % height of a one frame
W = A.Width;   % width of a one frame

gray_frame (1:F) =struct('frame',zeros(H,W,1,'uint8'),'colormap',[]); % rgb2gray
% to create zero frames for gray frames 
diff_frame (1:F) =struct('frame',zeros(H,W,1,'double'),'colormap',[]); % for frame diff 
% to create zero frames for "frame diff" frames
morph_frame (1:F) =struct('frame',zeros(H,W,1,'double'),'colormap',[]); % morphologic operation
filtered_frame (1:F) =struct('frame',zeros(H,W,1,'double'),'colormap',[]); % morp*gray

% Frame extraction from video and rgb2gray transform and median filter all
% frames
for k=1:F;
    gray_frame(k).frame =medfilt2(rgb2gray(read(A,k)));   
    % otsu for thresholding
    thres=graythresh(gray_frame(k).frame);
    gray_frame(k).frame = im2bw(gray_frame(k).frame,thres);
end

se_ero = strel('disk',3); % Create morphological structuring element (‘shape’,size)
se_dil = strel('disk',10);
for k=1:F-1;
    diff_frame(k).frame =abs(double(gray_frame(k+1).frame)-double(gray_frame(k).frame));   
    % applying morphology
    % firstly erosion and after that diation using different structure elements
    filtered_frame(k).frame=imdilate(imerode(bsxfun(@times,diff_frame(k).frame,gray_frame(k).frame),se_ero),se_dil);
end

for k=1:F-1
    imshow(read(A,k))
    %find connected components in binary image
    connectedComponents = bwconncomp(filtered_frame(k).frame); 
    stats=regionprops(connectedComponents,'EquivDiameter','Centroid');
%     loop for look connected components and get into the rectangle
    for blobNum=1:length(stats)
        r=stats.EquivDiameter / 2;
        center=stats.Centroid;
        x=center(1);
        y=center(2);
        hold on
        th = 0:pi/50:2*pi;
        xunit = r * cos(th) + x;
        yunit = r * sin(th) + y;
        h = plot(xunit, yunit,'LineWidth',1);
        hold off    
    end
    title(strcat('frame',num2str(k)))
    pause(0.00000000001) %pause(x) x second
end

cputime-t % gives elapsed time

