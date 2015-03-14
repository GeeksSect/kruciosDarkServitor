module main;

import std.stdio;
import std.array;
import utils.parser;

void main(string[] args)
{
	writeln(args);
	string l, text;
	auto in_file = File(args[1], "r");
	while ((l = in_file.readln()) !is null)
		text ~= l;

	auto compiler = new Compiler;
	compiler.parse(text);
	writeln(compiler.build());

	auto out_file = File(std.array.split(args[1], '.')[0] ~ ".sml", "w");
	out_file.write(compiler.build());

	writeln ("Press any key ...");
	readln();
}
