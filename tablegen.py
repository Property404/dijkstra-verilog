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
	columns = ["CriticalPathSlack", "CriticalPathClkPeriod", "TotalNegativeSlack", "DesignArea"]
	parent_path=None
	if node=="90":
		parent_path = "old_reports/90nm_reports"
		clock_ways = ["59", "58", "57"]
		parent = parent_path +"/reports/"
	elif node=="28":
		parent_path = "old_reports/28nm_reports"
		clock_ways = ["5", "4", "3"]
		parent = parent_path+"/"
	else:
		raise("I don't know man")
	map_ways = ["medium","high"]
	area_ways = ["low","medium","high"]
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
