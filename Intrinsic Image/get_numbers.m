function [numbers] = get_numbers(mask)

	[M, N] = size(mask);
	numbers = zeros(M, N);

	count = 0;
	for i = 1 : M
	for j = 1 : N
		if mask(i, j)
			numbers(i, j) = count;
			count = count + 1;
		end
	end
	end

end