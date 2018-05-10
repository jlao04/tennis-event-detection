%Take raw training data and perform PCA
% temp = matfile('trainingDataALLupd.mat');
temp = matfile('trainingData.mat');
rawData = temp.rawData;
no_dims = 5;
markerSize = 40;
labels = readtable('shotLabels.csv');
[mappedData, mapping] = compute_mapping(rawData,'PCA',no_dims);

[unique_groups, ~, group_idx] = unique(labels);
num_groups = size(unique_groups);
x = mappedData(:,1);
y = mappedData(:,2);
z = mappedData(:,3);
figure
scatter3(x(group_idx==1),y(group_idx==1),z(group_idx==1),markerSize,[0.8500, 0.3250, 0.0980],'filled');
hold on;
scatter3(x(group_idx==2),y(group_idx==2),z(group_idx==2),markerSize, [0.4660, 0.6740, 0.1880],'filled');
scatter3(x(group_idx==3),y(group_idx==3),z(group_idx==3),markerSize,[0, 0.4470, 0.7410],'filled');
scatter3(x(group_idx==4),y(group_idx==4),z(group_idx==4),markerSize,'black','filled');

xlabel('PC1');
ylabel('PC2');
zlabel('PC3');
legend('2H Backhand','1H Backhand','Forehand','Serve');
% legend('Backhand','Forehand','Serve');
rotate3d on;
varNames = {'PC1';'PC2';'PC3';'PC4';'PC5'};
figure
gplotmatrix(mappedData,[],group_idx,['r' 'g' 'b' 'y'],[],[],true);
text([.08 .24 .43 .66 .83], repmat(-.1,1,5), varNames, 'FontSize',8);
text(repmat(-.12,1,5), [.86 .62 .41 .25 .02], varNames, 'FontSize',8, 'Rotation',90);
legend;
h = findobj('Tag','legend');
% set(h, 'String', {'Backhand', 'Forehand', '1h backhand','Overhead'})
% set(h, 'String', {'Backhand', 'Forehand', 'Overhead'})

pause;
close all;