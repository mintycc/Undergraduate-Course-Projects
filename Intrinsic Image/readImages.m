function [images] = readImages(name)

    for i = 1 : 9
        input_dir = ['./data/', name, '/light0', num2str(i), '.png'];
        images(:, :, i, :) = imread(input_dir);
    end
    input_dir = ['./data/', name, '/light10.png'];
    images(:, :, 10, :) = imread(input_dir);
end