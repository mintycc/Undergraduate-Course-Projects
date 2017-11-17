function [log_ref] = solve(t_x, t_y, mask)

% get reflectance from estimated x and y
    
    t_x_weights = ones(size(t_x));
    t_y_weights = ones(size(t_y));

    [M, N] = size(mask);

    numbers = get_numbers(mask);
    log_ref = zeros(size(t_x));

    disp('computing A');
    A = getA(mask, t_x_weights, t_y_weights);
	disp('computing b');
    b = getb(t_x, t_y, mask, t_x_weights, t_y_weights);
    disp('computing x');

    [status, cmdout] = system('python get_amg.py')
        
    fid = fopen('x.txt', 'r');
    x = fscanf(fid, '%f', size(b));
    fclose(fid);

    log_ref(:, :) = x(numbers(:, :) + 1);
end