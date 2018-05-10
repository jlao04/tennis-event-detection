function playerTrack

workingDir = 'C:\Users\jlao1\Documents\Y4\FinalProj\Proj\testdir';

jj = 1;

% showDetections();

  param = getDefaultParameters();
  utilities = createUtilities(param);
  trackedLocation = [];


% showTrajectory();

frame            = [];  % A video frame
detectedLocation = [];  % The detected location
trackedLocation  = [];  % The tracked location
label            = '';  % Label for the ball
utilities        = [];  % Utilities used to process the video


function trackSingleObject(param)

  utilities = createUtilities(param);

  isTrackInitialized = false;
  while ~isDone(utilities.videoReader)
    frame = readFrame();


    [detectedLocation, isObjectDetected] = detectObject(frame);

    if ~isTrackInitialized
      if isObjectDetected

        initialLocation = computeInitialLocation(param, detectedLocation);
        kalmanFilter = configureKalmanFilter(param.motionModel, ...
          initialLocation, param.initialEstimateError, ...
          param.motionNoise, param.measurementNoise);

        isTrackInitialized = true;
        trackedLocation = correct(kalmanFilter, detectedLocation);
        label = 'Initial';
      else
        trackedLocation = [];
        label = '';
      end

    else
      % Use the Kalman filter to track the ball.
      if isObjectDetected 

        predict(kalmanFilter);
        trackedLocation = correct(kalmanFilter, detectedLocation);
        label = 'Corrected';
      else
 
        trackedLocation = predict(kalmanFilter);
        label = 'Predicted';
      end
    end

    annotateTrackedObject();
  end 
  
  %showTrajectory();
%   imageNames = dir(fullfile(workingDir,'frames','*.jpg'));
%   imageNames = {imageNames.name}';
%   outputVideo = VideoWriter(fullfile(workingDir,'shuttle_out.mp4'));
%   outputVideo.FrameRate = 30;
%   open(outputVideo)
%   for ii = 1:length(imageNames)
%    img = imread(fullfile(workingDir,'frames',imageNames{ii}));
%    writeVideo(outputVideo,img)
%   end
end


param = getDefaultParameters();  % get Kalman configuration that works well
                                 % for this example
                                 
trackSingleObject(param);  % visualize the results


function param = getDefaultParameters
  param.motionModel           = 'ConstantAcceleration';
  param.initialLocation       = 'Same as first detection';
  param.initialEstimateError  = 1E5 * ones(1, 3);
  param.motionNoise           = [25, 10, 1];
  param.measurementNoise      = 25;
  param.segmentationThreshold = 0.05;
end

%%
% Read the next video frame from the video file.
function frame = readFrame()
  frame = step(utilities.videoReader);
end

%%
% Detect and annotate the ball in the video.
function showDetections()
  param = getDefaultParameters();
  utilities = createUtilities(param);
  trackedLocation = [];

  idx = 0;
  while ~isDone(utilities.videoReader)
    frame = readFrame();
    detectedLocation = detectObject(frame);
    % Show the detection result for the current video frame.
    annotateTrackedObject();

    % To highlight the effects of the measurement noise, show the detection
    % results for the 40th frame in a separate figure.
    idx = idx + 1;
    if idx == 40
      combinedImage = max(repmat(utilities.foregroundMask, [1,1,3]), frame);
      figure, imshow(combinedImage);
    end
  end % while
  
  % Close the window which was used to show individual video frame.
  uiscopes.close('All'); 
end

%%
% Detect the ball in the current video frame.
function [detection, isObjectDetected] = detectObject(frame)
  grayImage = rgb2gray(frame);
  utilities.foregroundMask = step(utilities.foregroundDetector, grayImage);
  detections = step(utilities.blobAnalyzer, utilities.foregroundMask);
  detected = 0;
  if isempty(detections)
    isObjectDetected = false;
    detection = detections;
  else
    % To simplify the tracking process, only use the first detected object.
    [m,n] = size(detections);
    for i=1:size(detections,1)
        if(detections(i,2)<200)
         detection = detections(i, :);
         detected = 1;
        end
    end
    if (detected == 0)
        isObjectDetected = false;
        detection = detections;
    end
    ii=1;
    while(ii<m)
        temp = detections(ii, :);
        if temp(:,2) < detection (:,2)
            detection = temp;        
        end
        ii = ii+1;
    end
    isObjectDetected = true;
  end
end

%%
% Show the current detection and tracking results.
function annotateTrackedObject()
  accumulateResults();
  % Combine the foreground mask with the current video frame in order to
  % show the detection result.
  combinedImage = max(repmat(utilities.foregroundMask, [1,1,3]), frame);

  if ~isempty(trackedLocation)
    shape = 'Circle';
    region = trackedLocation;
    region(:, 3) = 20;
%     combinedImage = insertObjectAnnotation(combinedImage, shape, ...
%       region, {label}, 'Color', 'red');
    combinedImage = insertShape(combinedImage,shape,region, 'Color','red','Linewidth',5);
  end
  filename = [sprintf('%03d',jj) '.jpg'];
  fullname = fullfile(workingDir,'frames',filename);
%   imwrite(combinedImage,fullname)    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)
  jj = jj+1;
  
  step(utilities.videoPlayer, combinedImage);
end

%%
% Show trajectory of the ball by overlaying all video frames on top of 
% each other.
function showTrajectory
  % Close the window which was used to show individual video frame.
  uiscopes.close('All'); 
  
  % Create a figure to show the processing results for all video frames.
  figure; imshow(utilities.accumulatedImage/2+0.5); hold on;
  plot(utilities.accumulatedDetections(:,1), ...
    utilities.accumulatedDetections(:,2), 'k+');
  
  if ~isempty(utilities.accumulatedTrackings)
    plot(utilities.accumulatedTrackings(:,1), ...
      utilities.accumulatedTrackings(:,2), 'r-o');
    legend('Detection', 'Tracking');
  end
end

%%
% Accumulate video frames, detected locations, and tracked locations to
% show the trajectory of the ball.
function accumulateResults()
  utilities.accumulatedImage      = max(utilities.accumulatedImage, frame);
  utilities.accumulatedDetections ...
    = [utilities.accumulatedDetections; detectedLocation];
  utilities.accumulatedTrackings  ...
    = [utilities.accumulatedTrackings; trackedLocation];
end

%%
% For illustration purposes, select the initial location used by the Kalman
% filter.
function loc = computeInitialLocation(param, detectedLocation)
  if strcmp(param.initialLocation, 'Same as first detection')
    loc = detectedLocation;
  else
    loc = param.initialLocation;
  end
end

%%
% Create utilities for reading video, detecting moving objects, and
% displaying the results.
function utilities = createUtilities(param)
  % Create System objects for reading video, displaying video, extracting
  % foreground, and analyzing connected components.
  utilities.videoReader = vision.VideoFileReader('FedKryTrim.mp4');
  utilities.videoPlayer = vision.VideoPlayer('Position', [100,100,1280,720]);
  utilities.foregroundDetector = vision.ForegroundDetector(...
    'NumTrainingFrames', 10, 'InitialVariance', param.segmentationThreshold);
  utilities.blobAnalyzer = vision.BlobAnalysis('AreaOutputPort', false, ...
    'MinimumBlobArea', 100, 'CentroidOutputPort', true); %, 'MaximumBlobArea', 60);

  utilities.accumulatedImage      = 0;
  utilities.accumulatedDetections = zeros(0, 2);
  utilities.accumulatedTrackings  = zeros(0, 2);
end



end
