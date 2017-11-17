function [A] = getA(mask, t_x_weights, t_y_weights)

% prepare argument A for amg()

	[M, N] = size(mask);
	numbers = get_numbers(mask);
	K = max(max(numbers, [], 1), [], 2) + 1;

   	fid = fopen('K.txt', 'w');
	fprintf(fid, '%d\n', K);
	fclose(fid);

	t_x_weights(:, 1) = [];
	t_y_weights(1, :) = [];


   	% horizontal derivatives
	count = 0;
	for i = 1 : M
	for j = 1 : N - 1
		if mask(i, j) && mask(i, j + 1)
			count = count + 1;
		end
	end
	end
	data = zeros(count * 4, 1);
	row = zeros(count * 4, 1);
	col = zeros(count * 4, 1);
	count = 0;
	for i = 1 : M
	for j = 1 : N - 1
		if mask(i, j) && mask(i, j + 1)

			n1 = numbers(i, j);
            n2 = numbers(i, j + 1);

			% row (i, j): -x_{i, j + 1} + x_{i, j} + t
			row(4 * count + 1) = n1;
			col(4 * count + 1) = n2;
			data(4 * count + 1) = -t_x_weights(i, j);

			row(4 * count + 2) = n1;
			col(4 * count + 2) = n1;
			data(4 * count + 2) = t_x_weights(i, j);
			
			% row (i, j + 1): x_{i, j + 1} - x_{i,j} - t
			row(4 * count + 3) = n2;
			col(4 * count + 3) = n2;
			data(4 * count + 3) = t_x_weights(i, j);

			row(4 * count + 4) = n2;
			col(4 * count + 4) = n1;
			data(4 * count + 4) = -t_x_weights(i, j);

			count = count + 1;
		end
	end
	end
	data1 = data;
    row1 = row;
   	col1 = col;

	% vertical derivatives
	count = 0;
	for i = 1 : M - 1
	for j = 1 : N
		if mask(i, j) && mask(i + 1, j)
			count = count + 1;			
		end
	end
	end
	data = zeros(count * 4, 1);
	row = zeros(count * 4, 1);
	col = zeros(count * 4, 1);
	count = 0;
	for i = 1 : M - 1
	for j = 1 : N
		if mask(i, j) && mask(i + 1, j)

			n1 = numbers(i, j);
            n2 = numbers(i + 1, j);

            % row (i, j): -x_{i + 1, j} + x_{i, j} + t
			row(4 * count + 1) = n1;
			col(4 * count + 1) = n2;
			data(4 * count + 1) = -t_y_weights(i, j);

			row(4 * count + 2) = n1;
			col(4 * count + 2) = n1;
			data(4 * count + 2) = t_y_weights(i, j);

			% row (i, j + 1): x_{i + 1, j} - x_{i, j} - t
			row(4 * count + 3) = n2;
			col(4 * count + 3) = n2;
			data(4 * count + 3) = t_y_weights(i, j);

			row(4 * count + 4) = n2;
			col(4 * count + 4) = n1;
			data(4 * count + 4) = -t_y_weights(i, j);

			count = count + 1;
		end
	end
	end
	data2 = data;
    row2 = row;
   	col2 = col;

   	data = [data1; data2];
   	row = [row1; row2];
   	col = [col1; col2];

   	fid = fopen('data.txt', 'w');
	fprintf(fid, '%d\n', size(data, 1));
	for i = 1 : size(data, 1)
		fprintf(fid, '%d\n', data(i, 1));
	end
	fclose(fid);

   	fid = fopen('row.txt', 'w');
	fprintf(fid, '%d\n', size(row, 1));
	for i = 1 : size(row, 1)
		fprintf(fid, '%d\n', row(i, 1));
	end
	fclose(fid);

   	fid = fopen('col.txt', 'w');
	fprintf(fid, '%d\n', size(col, 1));
	for i = 1 : size(col, 1)
		fprintf(fid, '%d\n', col(i, 1));
	end
	fclose(fid);

	%{
   	A = sparse(K, K);

   	for i = 1 : size(data, 1)
   		A(row(i), col(i)) = data(i);
   	end
   	%}
   	A = zeros(1);
end