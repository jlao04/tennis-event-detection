vidObj = VideoReader('ShaneFrances.mp4');
labelFolder = 'C:\Users\jlao1\Documents\Y4\FinalProj\Proj\ShaneFrances\OpenPoseData\';
d = dir([labelFolder, '*.json']);

%1:32 to 1:41
%29.97 fps
%2757 to 3026

k = 1;
while hasFrame(vidObj)
    
    % RGB
    cla;
    imshow(readFrame(vidObj));
    
    % json
    full_path_json = [labelFolder, d(k).name];
    jsonData = loadjson(full_path_json);
    
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
% //     {1,  "Nose"},
% //     {2,  "Neck"},
% //     {3,  "RShoulder"},
% //     {4,  "RElbow"},
% //     {5,  "RWrist"},
% //     {6,  "LShoulder"},
% //     {7,  "LElbow"},
% //     {8,  "LWrist"},
% //     {9,  "RHip"},
% //     {10,  "RKnee"},
% //     {11, "RAnkle"},
% //     {12, "LHip"},
% //     {13, "LKnee"},
% //     {14, "LAnkle"},
% //     {15, "REye"},
% //     {16, "LEye"},
% //     {17, "REar"},
% //     {18, "LEar"},
    drawnow;
%     pause(0.05);
    k = k+1;
end