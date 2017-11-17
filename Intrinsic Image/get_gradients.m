function [image_hor, image_ver] = get_gradients(images)

% apply a row and a column derivative filter on an input image
% a.k.a get the horizontal and vertical gradient of the image

    image_ver = zeros(size(images));
    image_hor = zeros(size(images));

    % vertical gradient
    for i = 2 : size(images, 1)
        image_ver(i, :, :) = images(i, :, :) - images(i - 1, :, :);
    end
    
    % horizontal gradient
    for i = 2 : size(images, 2)
        image_hor(:, i, :) = images(:, i, :) - images(:, i - 1, :);
    end

end