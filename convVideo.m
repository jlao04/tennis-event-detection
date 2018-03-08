videoData = VideoReader('ShaneFrances.mp4');
workingDir = 'C:\Users\jlao1\Documents\Y4\FinalProj\Proj\ShaneFrances\';

ii = 1;
endFrame = 5480;

while hasFrame(videoData)
   if (ii>endFrame) 
       break;
   end
   img = readFrame(videoData);
   filename = [sprintf('%03d',ii) '.jpg'];
   fullname = fullfile(workingDir,'Frames',filename);
   imwrite(img,fullname)    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)
   ii = ii+1;
   if (mod(ii,100) == 0)
      disp(['Frame ',num2str(ii),' processed.']);
   end
end