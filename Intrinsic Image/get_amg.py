import numpy as np
import pyamg
import pickle
import scipy.sparse

def solve():
	fp = open('K.txt','r')
	K = int(fp.readline())
	fp.close()

	fp = open('data.txt','r')
	n = int(fp.readline())
	data = np.zeros(n)
	for i in range(n):
		data[i] = int(fp.readline())
	fp.close()

	fp = open('row.txt','r')
	n = int(fp.readline())
	row = np.zeros(n)
	for i in range(n):
		row[i] = int(fp.readline())
	fp.close()

	fp = open('col.txt','r')
	n = int(fp.readline())
	col = np.zeros(n)
	for i in range(n):
		col[i] = int(fp.readline())
	fp.close()

	fp = open('b.txt','r')
	n = int(fp.readline())
	b = np.zeros(n)
	for i in range(n):
		b[i] = float(fp.readline())
	fp.close()

	A = scipy.sparse.coo_matrix((data, (row, col)), shape=(K, K))
	solver = pyamg.ruge_stuben_solver(A)
	x = solver.solve(b)

	fp = open('x.txt','w')
	for i in range(K):
		fp.write(str(x[i]))
		fp.write('\n')
	fp.close()

if __name__ == '__main__':
	solve()