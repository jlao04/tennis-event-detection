temp = matfile('trainingDataNORW.mat');
rawData = temp.allShots;
serve = rawData(16,:);
fh = rawData(14,:);
for i=1:7
    mult = rand(1,280);
    mult = mult +0.5;
    rowtoAdd = serve.*mult;
    rawData = [rawData;rowtoAdd];
end

for i = 1:4
 mult = rand(1,280);
    mult = mult +0.5;
    rowtoAdd = fh.*mult;
    rawData = [rawData;rowtoAdd];
end

save('trainingData.mat','rawData')