% percolation image generation
clear all; clc;
% Define the grid size
L = 100;
% Define the probability range
prob_range = 0.0:0.001:1;
max_cluster_array = zeros(1,length(prob_range));
% Define the probability of each grid cell being occupied
for p = prob_range
    for iteration = 1:10
        occupancyGrid = rand(L) < p;
        % using Hoshen–Kopelman algorithm to find the largest cluster
        labeled_matrix = hoshen_kopelman(occupancyGrid);
        [rows, cols] = size(labeled_matrix);
        labels = [];
        labels_ind = 1;
        % putting all the labels into a matrix and and sort them to find
        % the size of the largest cluster
        for i = 1:rows
            for j = 1:cols
                if labeled_matrix(i, j) ~= 0
                    labels(labels_ind) = labeled_matrix(i, j);
                    labels_ind = labels_ind + 1;
                end
            end
        end
        most_frequent_label = mode(labels);
        max_cluster = 0;
        for i = 1:length(labels)
            if labels(i) == most_frequent_label
                max_cluster = max_cluster + 1;
            end
        end
        

        % saving the images with corresponding percolation probability
        % and max_cluster
        max_cluster_array(round((p+0.001)*1000)) = max_cluster;
        % saving the images
        % make a folder on Desktop
        filePath = '/Users/chengxinye/Desktop/perco_img_bw';
        image_name = [num2str(p), '_', num2str(max_cluster)];
        fullFilePath = fullfile(filePath, [image_name, '.png']);
        imwrite(occupancyGrid, fullFilePath, "png");
        
    end
    disp([num2str(p*100), '% finished']);
end

max_cluster_array = log(max_cluster_array);
plot((0.0:0.001:1.0), max_cluster_array, 'LineWidth',3)
xlabel('probability')
ylabel('logged maximum cluster size')
title('Probability vs. maximum cluster size')




% Hoshen Kopelman Algorithm: label each cluster with a different label
function neighbors = get_neighbors(matrix, i, j)
    neighbors = [];

    if i > 1 && matrix(i - 1, j) ~= 0
        neighbors = [neighbors, matrix(i - 1, j)];
    end

    if j > 1 && matrix(i, j - 1) ~= 0
        neighbors = [neighbors, matrix(i, j - 1)];
    end
end

function labeled_matrix = hoshen_kopelman(matrix)
    [rows, cols] = size(matrix);
    labeled_matrix = zeros(rows, cols);
    label_counter = 0;
    labels = containers.Map('KeyType', 'double', 'ValueType', 'double');

    for i = 1:rows
        for j = 1:cols
            if matrix(i, j) == 1
                neighbors = get_neighbors(labeled_matrix, i, j);
                
                if isempty(neighbors)
                    label_counter = label_counter + 1;
                    labeled_matrix(i, j) = label_counter;
                    labels(label_counter) = label_counter;
                else
                    neighbor_labels = unique(nonzeros(neighbors));
                    min_label = min(neighbor_labels);
                    labeled_matrix(i, j) = min_label;

                    for k = 1:length(neighbor_labels)
                        if neighbor_labels(k) ~= min_label
                            labels(neighbor_labels(k)) = min_label;
                        end
                    end
                end
            end
        end
    end

    for i = 1:rows
        for j = 1:cols
            if labeled_matrix(i, j) ~= 0
                labeled_matrix(i, j) = labels(labeled_matrix(i, j));
            end
        end
    end
end


