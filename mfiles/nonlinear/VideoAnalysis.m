% Nonlinear Analysis Code

% Load up a movie
vid = mmreader('MVI_Driven1.avi');

nFrames = vid.NumberOfFrames;
frameRate = vid.FrameRate;
% Get the pivot point from the user
frame = read(vid,1);
figure; imagesc(frame);
[x,y] = ginput(1);
pivx = round(x); pivy = round(y);
hold on;
plot(pivx,pivy,'b.','Markersize',10,'MarkerFaceColor','b')

% Have the user define the region of interest for the red dot
[roix,roiy] = ginput(2);
xmin = floor(min(roix));
xmax = ceil(max(roix));
ymin = floor(min(roiy));
ymax = ceil(max(roiy));
plot([xmin,xmax,xmax,xmin,xmin],[ymin,ymin,ymax,ymax,ymin],'r-','LineWidth',2);

% Have the user define the region of interest for the green dot
[roigx,roigy] = ginput(2);
gxmin = floor(min(roigx));
gxmax = ceil(max(roigx));
gymin = floor(min(roigy));
gymax = ceil(max(roigy));
plot([gxmin,gxmax,gxmax,gxmin,gxmin],[gymin,gymin,gymax,gymax,gymin],'g-','LineWidth',2);

% Initalize our time and angle vectors
time = zeros(1,nFrames);
angle = zeros(1,nFrames);
angleDrive = zeros(1,nFrames);

% Read one frame at a time, analyzing our images for the locations of our
% dots.
for k = 1 : nFrames
%k = 5;
    updatemsg = sprintf('Analyzing Frame (%d/%d)',k,nFrames);
    disp(updatemsg)
    time(k) = k/frameRate;
    frame = read(vid, k);
    % Take the cut-out ROI of our image, threshold it, and find where the
    % bright red spot is, and record the angle.
    roi_pend = frame(ymin:ymax,xmin:xmax,2);
    roi_pendAdj = imadjust(roi_pend);
    bw = im2bw(roi_pendAdj,.99);
    [~,col] = max(sum(bw,1));
    [~,row] = max(sum(bw,2));
    angle(k) = atan2(xmin+col-pivx,ymin+row-pivy);
    plot(xmin+col,ymin+row,'r.','Markersize',10,'MarkerFaceColor','b')
    % Take the green ROI, threshold it, find where the spot is and record
    % the angle
    roi_drive = frame(gymin:gymax,gxmin:gxmax,2);
    roi_driveAdj = imadjust(roi_drive);
    bw = im2bw(roi_driveAdj,.99);
    [~,gcol] = max(sum(bw,1));
    [~,grow] = max(sum(bw,2));
    angleDrive(k) = atan2(gxmin+gcol-pivx,gymin+grow-pivy);
    plot(gxmin+gcol,gymin+grow,'g.','Markersize',10,'MarkerFaceColor','b')
    
end

figure;
plot(time,angle);
title('Angular Position of Oscillator');
xlabel('Time (s)');
ylabel('\theta');

figure;
plot(time,angleDrive);
title('Angular Position of Drive');
xlabel('Time (s)');
ylabel('\theta');

% Subtract off any offset to the angle
angle = angle - mean(angle);
angleDrive = angleDrive - mean(angleDrive);
% Save the output to something that MMA can read:
csvwrite('driven1_response.txt',[time',angle']);
csvwrite('driven1_drive.txt',[time',angleDrive']);

% For plotting a frame, and the channels
% figure;
% subplot(2,2,1); imagesc(frame); title('RBG image');
% subplot(2,2,2); imagesc(frame(:,:,1)); title('Red channel');
% subplot(2,2,3); imagesc(frame(:,:,2)); title('Green channel');
% subplot(2,2,4); imagesc(frame(:,:,3)); title('Blue channel');
