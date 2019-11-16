#include <cstdlib>
#include <ctime>
#include <iostream>
#include <vector>
#include <queue>
using namespace std;
constexpr int INFINITY = 100;
class Graph
{
	int** edge_matrix;
	int number_of_nodes;
	public:
	Graph(int n)
	{
		number_of_nodes = n;
		edge_matrix = new int*[n];
		for(int i=0;i<n;i++)
		{
			edge_matrix[i] = new int[n];
		}

		for(int i=0;i<n;i++)
		for(int j=0;j<n;j++)
		{
			edge_matrix[i][j] = rand()%2?rand()%10:rand()%100;
			edge_matrix[j][i] = edge_matrix[i][j];

			if(i==j)edge_matrix[i][j] = 0;
		}
	}

	void display()const
	{
		const auto n = number_of_nodes;
		cout<<"\t";
		for(int i=0;i<n;i++)
		{
			cout<<static_cast<char>(i+'A')<<'\t';
		}

		for(int row=0;row<n;row++)
		{
			cout<<"\n";
			cout<<static_cast<char>(row+'A')<<"\t";
			for(int column=0;column<n;column++)
			{
				cout<<get_length(row, column)<<'\t';
			}

		}
		cout<<"\n";
	}

	int get_number_of_nodes()const
	{
		return number_of_nodes;
	}

	int get_length(int row, int column)const
	{
		return edge_matrix[row][column];
	}

	~Graph(){
		for(int i=0;i<number_of_nodes;i++)
		{
			delete edge_matrix[i];
		}
		delete edge_matrix;
	}
};

class PriorityNode{
	public:
		int index;
		int priority;

	PriorityNode(int i, int p)
	{
		index = i;
		priority = p;
	}

};
bool operator<(const PriorityNode& lhs, const PriorityNode& rhs)
{
	if(lhs.priority < rhs.priority)
	{
		return true;
	}
	return false;
}

bool operator>(const PriorityNode& lhs, const PriorityNode& rhs)
{
	if(lhs.priority > rhs.priority)
	{
		return true;
	}
	return false;
}
void dijkstra(const Graph& graph, int source, int target)
{
	const int num_nodes = graph.get_number_of_nodes();

	vector<int> dist(num_nodes, INFINITY);
	vector<int> prev(num_nodes, -1);
	vector<bool> visited(num_nodes, false);
	dist[source] = 0;


	priority_queue<PriorityNode, vector<PriorityNode>, std::greater<PriorityNode>> nodes;
	for (int i=0;i<num_nodes;i++)
	{
		nodes.emplace(i, dist[i]);
	}

	while(!nodes.empty())
	{
		if(nodes.top().priority != dist[nodes.top().index])	
		{
			nodes.pop();
			cout<<"Popping old value\n";
			continue;
		}
		const int u = nodes.top().index;nodes.pop();
		cout<<static_cast<char>('A'+u)<<endl;
		visited[u] = true;
		if(u == target)break;


		for(int v=0;v<num_nodes;v++)
		{
			if(visited[v]) continue;
			const int alt = dist[u] + graph.get_length(u,v);
			if(alt<dist[v])
			{
				dist[v] = alt;
				prev[v] = u;
				nodes.emplace(v, alt);
			}
		}
	}
	
	for(int i=0;i<num_nodes;i++)
	{
		cout<<"\t"<<static_cast<char>('A'+prev[i]);
	}
	cout<<"\n";
	for(int i=0;i<num_nodes;i++)
	{
		cout<<"\t"<<dist[i];
	}
	cout<<"\n";
}

int main()
{
	int n = 6;
	srand(time(NULL));
	Graph graph(n);
	graph.display();
	cout<<"\n";
	dijkstra(graph, 0, n-1);
}
