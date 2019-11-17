#include <cstdlib>
#include <ctime>
#include <iostream>
#include <vector>
#include <queue>
#include "args.hxx"

using namespace std;
constexpr int INFINITY = 100;
constexpr int DEFAULT_NUMBER_OF_NODES = 6;

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

	void display(bool show_columns = false)const
	{
		const auto n = number_of_nodes;

		if(show_columns)
		{
			cout<<"\t";
			for(int i=0;i<n;i++)
			{
				cout<<static_cast<char>(i+'A')<<'\t';
			}
		}

		for(int row=0;row<n;row++)
		{
			cout<<"\n";

			if(show_columns)
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
void dijkstra(const Graph& graph, int source, int target, bool show_columns, bool ignore_other_paths)
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
			continue;
		}
		const int u = nodes.top().index;nodes.pop();
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

	if(ignore_other_paths)
	{
		vector<int> prev2(num_nodes, -1);
		int j=num_nodes-1;
		while(j != source)
		{
			prev2[j] = prev[j];
			j = prev2[j];
		}
		for(int i=0;i<num_nodes;i++)
			prev[i] = prev2[i];
	}
	
	
	for(int i=0;i<num_nodes;i++)
	{
		if(show_columns)
			cout<<"\t"<<static_cast<char>('A'+prev[i]);
		else
			cout<<prev[i]<<"\t";
	}
	cout<<"\n";

	if (show_columns)
	{
		for(int i=0;i<num_nodes;i++)
		{
			cout<<"\t"<<dist[i];
		}
		cout<<"\n";
	}
}

int main(int argc, const char* argv[])
{
	args::ArgumentParser parser("Shortest path calculator", "");
	args::HelpFlag help(parser, "help", "Display this tedxt", {'h', "help"});
	args::Flag show_columns(parser, "show columns", "Show columns", {'c'});
	args::Flag show_meta(parser, "meta", "Display meta", {'m'});
	args::Flag ignore_other_paths(parser, "ignore_other_paths", "Ignore unimportant", {'i'});
	args::ValueFlag<int> size_opt(parser, "size", "Set number of nodes", {'n'});
	args::ValueFlag<int> seed_opt(parser, "seed", "Set seed", {'s'});

	
	try
	{
		parser.ParseCLI(argc, argv);
	}
	catch(const args::Help&)
	{
		cout << parser;
		return 0;
	}
	catch(const args::ParseError& e)
	{
		cerr << e.what() << endl;
		cerr << parser;
		return 1;
	}

	const int size = size_opt?args::get(size_opt):DEFAULT_NUMBER_OF_NODES;
	const int seed = seed_opt?args::get(seed_opt):time(NULL);

	if(args::get(show_meta))
	{
		cout << size << " " << seed << endl;
	}

	srand(seed);

	Graph graph(size);
	graph.display(args::get(show_columns));
	if(show_columns)
		cout<<"\n";
	dijkstra(graph, 0, size-1, show_columns, ignore_other_paths);
}
