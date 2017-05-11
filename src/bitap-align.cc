#include <vector>
#include <string>
#include <iostream>
#include <fstream>
#include <climits>
#include <cassert>
#include <algorithm>

#define __DEBUG__
using namespace std;

string bin(int x,int len=32) {
  string ret = "";
  for(int i=0;i<len;++i) {
    ret += "01"[x%2];
    x/=2;
  }

  return ret;
}
vector<int> generateAlphabet(const string &needle) { 
  vector<int> ret(8,0);
  const string sym = "ACGTN";
  for(int i = 0 ; i < needle.size() ; ++i ) {
    ret[needle[i]%8] |= (1<<i);
  }
  return ret;
}


bool bitapSearch( const string &haystack, const string &needle, const vector<int> &alphabet, const int maxErr = 2 ) {

  vector<int> tableRow(maxErr+1,0);

  for(int i=0;i<tableRow.size();++i) tableRow[i] = ((1<<(i+1))-1);
  //cerr << bin(tableRow[0]) << endl;
  const int endMask = (1<<needle.size());
  //cerr << bin(endMask,10) << endl;
  for( int i = 0 ; i < haystack.size() ; ++i ) {
    int oldTableCell = 0, nextOldTableCell = 0;
    int charMask = alphabet[haystack[i]%8];
    //cerr << bin(charMask) << " " << haystack[i] << endl;
    for( int d = 0 ; d <= maxErr ; ++d ) {
      int nextSub = (oldTableCell|(tableRow[d] & charMask)) << 1;
      int nextIns = oldTableCell|((tableRow[d] & charMask) << 1);
      int nextDel = (nextOldTableCell|(tableRow[d] & charMask)) << 1;
      int nextTableCell = nextSub | nextIns | nextDel | 1;
      oldTableCell = tableRow[d];
      tableRow[d] = nextTableCell;
      nextOldTableCell = nextTableCell;
      //cerr << bin(tableRow[d],10) << " ";
    }
    //cerr << endl;
    if(tableRow[maxErr] & endMask) return true;
  } 

  return false;
}

int main(int argc, char *argv[]) {
  /*
  assert(bitapSearch("AA","AACC",generateAlphabet("AACC"),2));
  assert(bitapSearch("AA","CC",generateAlphabet("CC"),2));
  assert(bitapSearch("AACT", "AT", generateAlphabet("AT"), 2));
  assert(bitapSearch("CGAT", "GGCGAT", generateAlphabet("GGCGAT"), 2));
  assert(bitapSearch("AACT", "TCAACT", generateAlphabet("TCAACT"), 2));
  assert(bitapSearch("AGGCAAAGCCACAGATGTATATCCACTAAGATGTTTAGCA", "ATCCACTAAGAATGTTTAGCA", generateAlphabet("ATCCACTAAGAATGTTTAGCA"), 2));
  assert(bitapSearch("CCACTAAGAATGTTTAGCA", "ATCCACTAAGAATGTTTAGCA", generateAlphabet("ATCCACTAAGAATGTTTAGCA"), 2));
  assert(bitapSearch("AAAA","TTTT",generateAlphabet("TTTT"),2)==false);
  */
	cerr << argv[1] << " " << argv[2] << " " << argv[3] << " " << argv[4] << endl;
  vector<string> sample;
  vector<int> cnt;
  ifstream inp(argv[1]);
  string k;
  int v;
  while( inp >> k >> v ) {
    sample.push_back(k);
    cnt.push_back(v);
  }
  vector<bool> used(sample.size(),false);
  inp.close();
  ifstream inp2(argv[2]);
  vector<string> libs;
  string line;

  ofstream oup(argv[3]);

	int nmismatch = 2;
	if( argc > 4 ) {
		sscanf(argv[4], "%d", &nmismatch);
	}


  while( getline(inp2, line) ) {
    string name = line.substr(1);
    getline(inp2,line);
    int tot = 0;
    vector<int> alphabet = generateAlphabet(line);
    for( int i = 0 ; i < sample.size() ; ++i ) {
      bool ret = bitapSearch(sample[i], line, alphabet, nmismatch);
      tot += cnt[i] * ret;
      used[i] = used[i] | ret;
    }
    oup << name << " " <<  tot << endl;
    //break;
  }
  int tot_map_cnt = 0;
  for(int i=0;i<sample.size();++i) {
    tot_map_cnt += used[i] * cnt[i];
  }
  oup << "Total: " << tot_map_cnt << endl;
  oup.close();

  inp2.close();
}

