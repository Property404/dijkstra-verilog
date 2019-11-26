#!/usr/bin/env python
import datetime
import os
from os.path import isfile, join
import sys
def text_to_html(text):
	return text.replace("<","&lt;");

def start():
	print("""<!DOCTYPE HTML>
	<html><body>
	<link rel="stylesheet"
		  href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@9.16.2/build/styles/default.min.css">
		  <script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@9.16.2/build/highlight.min.js"></script>
	""");

def end():
	print("""<script>document.addEventListener('DOMContentLoaded', (event) => {
	  document.querySelectorAll('pre code').forEach((block) => {
	      hljs.highlightBlock(block);
	        });
			});</script>""")
	print("</body></html>")

def print_section_header(section_name):
	print("<h1>"+section_name+"</h1>")

def print_subsection_header(section_name):
	print("<h2>"+section_name+"</h2>")

def print_caption(caption):
	print("<strong>"+caption+"</strong><br>")
	
def show_text_file(filename, description=None):
	show_code(filename, description=description)

def show_code(filename, lang="nohighlight", description=None):
	if description is None:
		description = filename
	print(description)
	print("<pre>")
	print("<code class='"+lang+"'>")
	with open(filename, "r") as fp:
		print(text_to_html(fp.read()))
	print("</code>")
	print("</pre>")

def show_image_file(filename, description=None):
	if description is not None:
		print(description)
	print("<br>")
	print("<img src='"+filename+"'></img>")
	print("<br>")
	print("<br>")

def list_files(path, ext):
	return [os.path.join(path, f) for f in os.listdir(path) if os.path.splitext(f)[1] in ext]


start()

print_section_header("Appendix")

print_subsection_header("Appendix A - Source Code");
for f in list_files("../src", [".sv",".v"]):
	show_code(f, "verilog");
print_subsection_header("Appendix B - Testbench Code");
for f in list_files("../src/testbenches", [".sv",".v"]):
	show_code(f, "verilog");
print_subsection_header("Appendix C - Testvector Generator Code");
show_code("../src/testbenches/testvectors/dijkstra.cpp", "c++");

print_subsection_header("Appendix D - 90nm Synthesis Reports");
for f in list_files("../old_reports/90nm_reports/chosen/chosen", [".rpt"]):
	show_code(f);

print_subsection_header("Appendix E - 28nm Synthesis Reports");
for f in list_files("../old_reports/28nm_reports/chosen", [".rpt"]):
	show_code(f);

print_subsection_header("Appendix F - 90nm Synthesis Reports");
for f in list_files("../icc90nm/output", [".rpt"]):
	show_code(f);
for f in list_files("../icc90nm/output2", [".rpt"]):
	show_code(f);

print_subsection_header("Appendix G - 28nm Synthesis Reports");
for f in list_files("../icc28nm/output", [".rpt"]):
	show_code(f);

end()
