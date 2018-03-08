vidObj = VideoReader('ShaneFrances.mp4');
labelFolder = 'C:\Users\jlao1\Documents\Y4\FinalProj\Proj\ShaneFrances\OpenPoseData\';
d = dir([labelFolder, '*.json']);
shotFrameNos = csvread('shotFrames.csv');
allShots = {};


frameRate = vidObj.FrameRate;
shotFrames = shotFrameNos./frameRate;
% k = 1;

for j = 1:1%length(shotFrames)
    shotPoints = 0;
    vidObj.currentTime = shotFrames(j,1);
% while hasFrame(vidObj)    
    while vidObj.currentTime <shotFrames(j,2) %Get frames defined by csv

        % RGB
        cla;
        imshow(readFrame(vidObj));

        % json
        full_path_json = [labelFolder, d(floor(vidObj.currentTime*frameRate)).name];
        %full_path_json = [labelFolder, d(k).name];
        jsonData = loadjson(full_path_json);
        pointSelected = 0;
        for m = 1:length(jsonData.people)
            
            % Point description in https://github.com/CMU-Perceptual-Computing-Lab/openpose/blob/master/doc/output.md
            skelPoints = cell2mat(jsonData.people{m}.pose_keypoints);
            indPoints = zeros(18,3);
            count = 1;
            for i = 1:length(skelPoints)
                index = mod(i,3);
                if (index == 0)
                    index = 3;
                end
                indPoints(count,index) = skelPoints(i);
                if (index == 3)
                    count = count+1;
                end
            end
            if (shotPoints == 0)
                shotPoints = indPoints;
            elseif (abs(indPoints(2,1)-shotPoints(2,1,end))/shotPoints(2,1,end)<0.2 && abs(indPoints(2,2)-shotPoints(2,2,end))/shotPoints(2,2,end)<0.2 && pointSelected == 0)
                shotPoints = cat(3,shotPoints,indPoints); %create x y time array
                pointSelected = 1;
            end
            
            %Draw skeleton
            hold on; plot(skelPoints(1:3:end), skelPoints(2:3:end), '.r', 'MarkerSize', 10);
            if(skelPoints(4)&skelPoints(5)&skelPoints(7)&skelPoints(8))
                line([skelPoints(4) skelPoints(7)], [skelPoints(5) skelPoints(8)],'Color','green','LineWidth',2);
            end
            if(skelPoints(7)&skelPoints(8)&skelPoints(10)&skelPoints(11))
                line([skelPoints(7) skelPoints(10)], [skelPoints(8) skelPoints(11)],'Color','green','LineWidth',2);
            end
            if(skelPoints(13)&skelPoints(14)&skelPoints(10)&skelPoints(11))
                line([skelPoints(10) skelPoints(13)], [skelPoints(11) skelPoints(14)],'Color','green','LineWidth',2);
            end
            if(skelPoints(4)&skelPoints(5)&skelPoints(16)&skelPoints(17))
                line([skelPoints(4) skelPoints(16)], [skelPoints(5) skelPoints(17)],'Color','green','LineWidth',2);
            end
            if(skelPoints(19)&skelPoints(20)&skelPoints(16)&skelPoints(17))
                line([skelPoints(19) skelPoints(16)], [skelPoints(20) skelPoints(17)],'Color','green','LineWidth',2);
            end
            if(skelPoints(19)&skelPoints(20)&skelPoints(22)&skelPoints(23))
                line([skelPoints(19) skelPoints(22)], [skelPoints(20) skelPoints(23)],'Color','green','LineWidth',2);
            end
            if(skelPoints(4)&skelPoints(5)&skelPoints(25)&skelPoints(26))
                line([skelPoints(4) skelPoints(25)], [skelPoints(5) skelPoints(26)],'Color','green','LineWidth',2);
            end
            if(skelPoints(28)&skelPoints(29)&skelPoints(25)&skelPoints(26))
                line([skelPoints(28) skelPoints(25)], [skelPoints(29) skelPoints(26)],'Color','green','LineWidth',2);
            end
            if(skelPoints(28)&skelPoints(29)&skelPoints(31)&skelPoints(32))
                line([skelPoints(28) skelPoints(31)], [skelPoints(29) skelPoints(32)],'Color','green','LineWidth',2);
            end
            if(skelPoints(4)&skelPoints(5)&skelPoints(34)&skelPoints(35))
                line([skelPoints(4) skelPoints(34)], [skelPoints(5) skelPoints(35)],'Color','green','LineWidth',2);
            end
            if(skelPoints(37)&skelPoints(38)&skelPoints(34)&skelPoints(35))
                line([skelPoints(37) skelPoints(34)], [skelPoints(38) skelPoints(35)],'Color','green','LineWidth',2);
            end
            if(skelPoints(37)&skelPoints(38)&skelPoints(40)&skelPoints(41))
                line([skelPoints(37) skelPoints(40)], [skelPoints(38) skelPoints(41)],'Color','green','LineWidth',2);
            end
            
        end
        drawnow;
        pause(0.05);
%         k = k+1;
    end
   
    %interpolation
     
    interpShot = zeros(18,3,10);
    for n=1:18
        time_in = shotFrameNos(j,1):1:shotFrameNos(j,2);
        
        x_in = shotPoints(n,1,:);
        x_in = squeeze(x_in);
        xe = cumsum(ones(size(x_in))).*x_in*eps;
        xe = xe + cumsum(ones(size(x_in))).*(x_in==0)*eps;
        x_in = x_in + xe;

        y_in = shotPoints(n,2,:);
        y_in = squeeze(y_in);
        ye = cumsum(ones(size(y_in))).*y_in*eps;
        ye = ye + cumsum(ones(size(y_in))).*(y_in==0)*eps;
        y_in = y_in + ye;

        num_samples = 10;
        
        time_out = linspace(time_in(1), time_in(end), num_samples);
        x_out = spline(time_in, x_in, time_out);
        y_out = spline(time_in, y_in, time_out);
        
        for m=1:num_samples
            interpShot(n,1,m) = x_out(m);
            interpShot(n,2,m) = y_out(m);
            interpShot(n,3,m) = time_out(m);
        end
    end
    
    allShots{j} = interpShot;
end