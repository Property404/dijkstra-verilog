#!/usr/bin/env python
import sys
def parse_qor(path):
	source = ""
	with open(path, "r") as fp:
		source = fp.read();

	lines = source.split("\n");

	pairs = {}
	for line in lines:
		tokens = line.split(":")
		if len(tokens) != 2:
			continue

		proper_tokens = []
		for token in tokens:
			proper_tokens.append(token.replace(" ",""))
		pairs[proper_tokens[0]] = proper_tokens[1]

	return pairs

def generate_table(node):
	columns = ["CriticalPathLength", "CriticalPathSlack", "CriticalPathClkPeriod", "TotalNegativeSlack", "CellArea", "DesignArea"]
	parent_path=None
	if node=="90":
		parent_path = "old_reports/90nm_reports"
		clock_ways = []
	else:
		raise("I don't know man")
	map_ways = ["none","medium","high"]
	area_ways = ["none","low","medium","high"]
	parent = parent_path+"/reports/"
	print("<table border=1><th>Setting</th>");

	for column in columns:
		print("<th><strong>"+column+"</strong></th>")

	for period in clock_ways:
		for map_level in map_ways:
			for area_level in area_ways:
				print("<tr>")
				print("<td><strong>"+map_level+" map, "+area_level+" area</strong></td>")
				filepath = parent+period+"_clock_"+map_level+"_map_"+area_level+"_area/qor.rpt"
				qor = parse_qor(filepath)
				for column in columns:
					print("<td>"+qor[column]+"</td>")

				print("</tr>")
	print("</table>");


if len(sys.argv) < 2:
	print("Need arg")
	exit(1)
generate_table(sys.argv[1])
