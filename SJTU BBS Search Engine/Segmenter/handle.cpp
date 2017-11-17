#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <sstream>
#include <string>

using namespace std;

int main()
{
	string input;
	
	istringstream is;
	while (cin >> input)
	{
		if (input == "")
			break;
		cout << input; //{"url"
		cin >> input;
		cout << input; //:
		cin >> input;
		cout << input; //[
		do
		{
			cin >> input;
			cout << input;
		} while (input != "]");
		cin >> input;
		cout << input; //,
		cin >> input;
		cout << input; //"
		cin >> input;
		cout << input; //content"
		cin >> input;
		cout << input; //:
		
		char line[100000];
		gets(line);
		bool ff = false;
		//cerr << "+" << line << endl;
		while (line[0])
		{
			int length = strlen(line);
			//cerr << "!" << line << "#" << endl;
			for (int i = 1; i < length - 5; ++i)
				if ((line[i - 1] == '"') && (line[i] == 't') && (line[i + 1] == 'i') && (line[i + 2] == 't') && (line[i + 3] == 'l') && (line[i + 4] == 'e'))
				{
					//cerr << "+" << line << "#" << endl;
					int j = i - 1;
					string vStandard = "\"],\"";
					int pointer = vStandard.size() - 1;
					for (; (j >= 0) && (pointer >= 0); --j)
						if (line[j] == vStandard[pointer])
							--pointer;
					for (int e = 0; e <= j; ++e)
						cout << line[e];
					cout << "$";
					string temp = string(line).substr(j + 1, strlen(line) - j - 1);
					for (int i = 0; i < temp.size(); ++i)
						line[i] = temp[i];
					line[temp.size()] = 0;
					ff = true;
					break;
				}
			if (ff)
				break;
			cout << line << "$";
			line[0] = 0;
			gets(line);
		}
		//cerr << "-" << line << "#" << endl;
		string aStandard = "\"],\"title\":[\"";
		int i = 0, pointer = 0;
		int length = strlen(line);
		for (; (i < length) && (pointer < aStandard.size()); ++i)
			if (line[i] == aStandard[pointer])
			{
				cout << line[i];
				++pointer;
			}
		//cerr << "#" << endl;
		for (; i < length; ++i)
			if (line[i] != ' ')
				cout << line[i];
		
		//cerr << "#" << endl;
		gets(line);
		//cerr << "#" << line << "#" << endl;
		string standard = "\"],\"author\":[\"";
		int point = 0;
		for (i = 0; point < standard.size(); ++i)
			if (line[i] == standard[point])
			{
				cout << line[i];
				++point;
			}
		//cout << "#" << endl;
		for (; line[i] != '"'; ++i)
			if (line[i] != ' ')
				cout << line[i];
		cout << "\"]}" << endl;
		//cerr << "#" << endl;
	}
}
