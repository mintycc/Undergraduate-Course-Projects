function [b] = getb(t_x, t_y, mask, t_x_weights, t_y_weights)

% prepare argument A for amg()

	[M, N] = size(mask);
	numbers = get_numbers(mask);

	K = max(max(numbers, [], 1), [], 2) + 1;
	b = zeros(K, 1);

	t_x(:, 1) = [];
	t_y(1, :) = [];
	t_x_weights(:, 1) = [];
	t_y_weights(1, :) = [];

	% horizontal derivatives
	for i = 1 : M
	for j = 1 : N - 1
		if mask(i, j) && mask(i, j + 1)

			n1 = numbers(i, j) + 1;
            n2 = numbers(i, j + 1) + 1;

			% row (i, j): -x_{i, j + 1} + x_{i, j} + t
			b(n1) = b(n1) - t_x(i, j) * t_x_weights(i, j);
			
			% row (i, j + 1): x_{i, j + 1} - x_{i,j} - t
			b(n2) = b(n2) + t_x(i, j) * t_x_weights(i, j);
		end
	end
	end

	% vertical derivatives
	for i = 1 : M - 1
	for j = 1 : N
		if mask(i, j) && mask(i + 1, j)

			n1 = numbers(i, j) + 1;
            n2 = numbers(i + 1, j) + 1;

            % row (i, j): -x_{i + 1, j} + x_{i, j} + t
            b(n1) = b(n1) - t_y(i, j) * t_y_weights(i, j);

			% row (i, j + 1): x_{i + 1, j} - x_{i, j} - t
            b(n2) = b(n2) + t_y(i, j) * t_y_weights(i, j);
		end
	end
	end
	
	fid = fopen('b.txt', 'w');
	fprintf(fid, '%d\n', size(b, 1));
	for i = 1 : size(b, 1)
		fprintf(fid, '%f\n', b(i, 1));
	end
	fclose(fid);

	%size(b)

end