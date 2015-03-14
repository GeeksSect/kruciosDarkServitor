module utils.parser;

import std.string;
import std.conv;
import std.algorithm;

enum SType
{
	undefined,
	label,
	var
}

struct Symbol
{
	SType type;
	string value;
	int addres;
	
	this(SType type = SType.undefined, string value = "", int addres = -1)
	{
		this.type = type;
		this.value = value;
		this.addres = addres;
	}
}

class Compiler
{
private:
	Symbol[string] symbol_table;
	int[100] command;
	string[100] argument;
	int I = 0;
	int V = 99;

public:
	this() {}

	string build()
	{
		string result = "";
		for(int i = 0; i < I; ++i)
		{
			int cmd = command[i];
			if (cmd >= 0)
				result ~= "+" ~ to!string(cmd) ~ "\n";
			else
				result ~= to!string(cmd) ~ "\n";
		}
		return result;
	}

	void parse(string text)
	{
		auto lines = splitLines(text);
		foreach(string line; lines)
		{
			// writeln(line);
			auto terms = split(line);
			
			auto cmd_n = terms[0];
			auto cmd = terms[1];
			
			switch(cmd)
			{
				case "rem":
					symbol_table[cmd_n] = Symbol(SType.label, cmd_n, I);
					break;
					
				case "var":
					symbol_table[cmd_n] = Symbol(SType.label, cmd_n, I);
					auto var_name = terms[2];
					Symbol* temp = var_name in symbol_table;
					if (temp is null)
					{
						symbol_table[var_name] = Symbol(SType.var, var_name, V);
						V--;
					}
					break;
					
				case "input":
					symbol_table[cmd_n] = Symbol(SType.label, cmd_n, I);
					command[I] = 1000;
					auto var_name = terms[2];
					Symbol* temp = var_name in symbol_table;
					if (temp is null)
					{
						throw new Exception("Undefined variable");
					}
					argument[I] = var_name;
					I++;
					break;
					
				case "print":
					symbol_table[cmd_n] = Symbol(SType.label, cmd_n, I);
					command[I] = 1100;
					auto var_name = terms[2];
					Symbol* temp = var_name in symbol_table;
					if (temp is null)
					{
						throw new Exception("Undefined variable");
					}
					argument[I] = var_name;
					I++;
					break;
					
				case "goto":
					symbol_table[cmd_n] = Symbol(SType.label, cmd_n, I);
					command[I] = 4000;
					auto lbl_name = terms[2];
					Symbol* temp = lbl_name in symbol_table;
					if (temp is null || temp.type != SType.label)
					{
						throw new Exception("Undefined label");
					}
					argument[I] = lbl_name;
					I++;
					break;
					
				case "end":
					command[I] = 4300;
					I++;
					break;
			}
		}

		for (auto i = 0; i < I; ++i)
		{
			auto arg_name = argument[i];
			Symbol* temp = arg_name in symbol_table;
			if (temp !is null)
			{
				command[i] += symbol_table[arg_name].addres;
			}
			// std.stdio.writeln (command[i]);
		}
	}
}