clc
clear all
close all

t=cputime; 
A=VideoReader('data2.avi');
get(A)
% display video
% A=read(A);
% implay(A);

%  V= [H, W, B, F]
F = A.NumberOfFrames; % number of frames in the video
H = A.Height; % height of a one frame
W = A.Width;   % width of a one frame
hsv_frame (1:F) = struct('frame',zeros(H,W,3,'uint8'),'colormap',[]); % rgb2hsv hsv comp. (3 dim.)
s_frame_g (1:F) = struct('frame',zeros(H,W,1,'uint8'),'colormap',[]); % s comp.
masked_frame (1:F) = struct('frame',zeros(H,W,1,'uint8'),'colormap',[]); % masked frame
logic_frame (1:F) = struct('frame',zeros(H,W,1,'uint8'),'colormap',[]); % logic frame
% read all frames and to convert rgb2hsv
se1=strel('square',2);
se2=strel('disk',4);
for k=1:1:F
    hsv_frame(k).frame = rgb2hsv(read(A,k));
    s_frame_g(k).frame = hsv_frame(k).frame(:,:,2) > 0.52;
    mask = cast(s_frame_g(k).frame, class(read(A,k)));
    masked_frame(k).frame=bsxfun(@times,read(A,k),mask);
    logic_frame(k).frame=imdilate(imerode(rgb2gray(masked_frame(k).frame) > 180,se1),se2);
end

for k=1:F
    imshow(read(A,k))
    %find connected components in binary image
    connectedComponents = bwconncomp(logic_frame(k).frame); 

    stats=regionprops(connectedComponents,'EquivDiameter','Centroid');
%     loop for look connected components and get into the circle
    for blobNum=1:length(stats)
        r=stats.EquivDiameter / 2;
        center=stats.Centroid;
        x=center(1);
        y=center(2);
        hold on
        th = 0:pi/50:2*pi;
        xunit = r * cos(th) + x;
        yunit = r * sin(th) + y;
        h = plot(xunit, yunit,'LineWidth',2);
        hold off    
    end
    title(strcat('frame',num2str(k)))
    pause(0.000000001) %pause(x) x second
end
cputime-t % gives elapsed time
