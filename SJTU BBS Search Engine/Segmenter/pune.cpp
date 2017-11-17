#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <algorithm>

using namespace std;

int main()
{
	char ss[100000];
	gets(ss);
	while (ss[0])
	{
		int length = strlen(ss);
		bool inside = false;
		string line = "";
		for (int i = 0; i < length; ++i)
		{
			if (inside && (ss[i] == '"'))
			{
				bool find = false;
				for(int j = i - 1; j >= 0; --j)
				{
					if (ss[j] == ' ')
						continue;
					if (ss[j] != '[')
						break;
					find = true;
					break;
				}
				if (find)
					continue;
				for (int j = i + 1; j < length; ++j)
				{
					if (ss[j] == ' ')
						continue;
					if (ss[j] != ']')
						break;
					find = true;
					break;
				}
				if (find)
					continue;
			}
			printf("%c", ss[i]);
			if (ss[i] == '[')
				inside = true;
			else if (ss[i] == ']')
				inside = false;
		}
		printf("\n");
		ss[0] = 0;
		gets(ss);
	}
}
