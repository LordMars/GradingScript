#include <iostream>
#include <set>
#include <map>

using namespace std;
int main(){
    vector<int> A = {1, 1, 1, 2, 2};
    vector<int> E = {1, 2, 1, 3, 2, 4, 2, 5};
    solution(A, E);
}
int solution(vector<int> &A, vector <int> &E){
    int gcount; //holds the largest edge count so far
    int count; //holds the current count of edges
    map<int, set<int>> labels;
    for(int i = 0; i < A.size(); i++){//for every value in the labels vector, A
        labels[a[i]].insert(i+1);//in the set referenced by the label, insert the node number
    }
}