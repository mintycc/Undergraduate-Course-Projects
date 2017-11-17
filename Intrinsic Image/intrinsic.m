function intrinsic(name)

% get the intrinsic image of a image sequence with the same reflectance

uint16_images = readImages(name);
images = double(uint16_images);
images = mean(images, 4);

input_dir = ['./data/', name, '/mask.png'];
mask = imread(input_dir);
input_dir = ['./data/', name, '/diffuse.png'];
uint16_image = imread(input_dir);

image = double(uint16_image);
diffuse = image;
image = mean(image, 3);

output_dir = ['./output/', name, '_diffuse.png'];
imwrite(uint16(diffuse), output_dir, 'png');

images(images < 3) = 3;
images(images > Inf) = Inf;
log_images = log(images);

[i_x_all, i_y_all] = get_gradients(log_images);
r_x = median(i_x_all, 3);
r_y = median(i_y_all, 3);

log_ref = solve(r_x, r_y, mask);

[list_x, list_y] = find(mask);
ref = zeros(size(image));
shad = zeros(size(image));
rgb_ref = zeros(size(diffuse));
for i = 1 : size(list_x)
	ref(list_x(i), list_y(i)) = exp(log_ref(list_x(i), list_y(i)));
	shad(list_x(i), list_y(i)) = 2 * image(list_x(i), list_y(i)) / ref(list_x(i), list_y(i)) ;
	rgb_ref(list_x(i), list_y(i), :) = diffuse(list_x(i), list_y(i), :) / shad(list_x(i), list_y(i));
end

output_dir = ['./output/', name, '_shading.png'];
imwrite(uint16(shad), output_dir, 'png');
output_dir = ['./output/', name, '_reflectance.png'];
imwrite(rgb_ref, output_dir, 'png');