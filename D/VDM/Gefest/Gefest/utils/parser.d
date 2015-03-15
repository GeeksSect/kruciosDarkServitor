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
	int addres;
	
	this(SType type = SType.undefined, int addres = -1)
	{
		this.type = type;
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
			// std.stdio.writeln(line);
			auto terms = split(line);
			
			auto cmd_n = terms[0];
			auto cmd = terms[1];

			std.stdio.writeln(cmd_n ~ " " ~ cmd);

			switch(cmd)
			{
				case "rem": // [cmd_n] rem [comment]
					symbol_table[cmd_n] = Symbol(SType.label, I);
					break;
					
				case "var": // var [variable_name]
					symbol_table[cmd_n] = Symbol(SType.label, I);
					auto var_name = terms[2];
					if ((var_name in symbol_table) is null)
					{
						symbol_table[var_name] = Symbol(SType.var, V);
						V--;
					}
					break;
					
				case "input": // input [variable_name]
					symbol_table[cmd_n] = Symbol(SType.label, I);
					command[I] = 1000;
					auto var_name = terms[2];
					if ((var_name in symbol_table) is null)
					{
						throw new Exception("Undefined variable" ~ var_name);
					}
					argument[I] = var_name;
					I++;
					break;
					
				case "print": // print [variable_name]
					symbol_table[cmd_n] = Symbol(SType.label, I);
					command[I] = 1100;
					auto var_name = terms[2];
					if ((var_name in symbol_table) is null)
					{
						throw new Exception("Undefined variable" ~ var_name);
					}
					argument[I] = var_name;
					I++;
					break;
					
				case "goto": // goto [label]
					symbol_table[cmd_n] = Symbol(SType.label, I);
					command[I] = 4000;
					auto lbl_name = terms[2];
					if ((lbl_name in symbol_table) is null || (lbl_name in symbol_table).type != SType.label)
					{
						throw new Exception("Undefined label" ~ lbl_name);
					}
					argument[I] = lbl_name;
					I++;
					break;

				case "if": /* if [variable_name] [compare_operator] [variable_name] goto [label]
				            * compare_operator: <, >, <=, >=, !=, ==
				            */
					foreach(string term; terms)
					{
						std.stdio.writeln(term);
					}

					symbol_table[cmd_n] = Symbol(SType.label, I);
					auto var1 = terms[2];
					if ((var1 in symbol_table) is null)
					{
						throw new Exception("Undefined variable " ~ var1);
					}

					auto op = terms[3];

					auto var2 = terms[4];
					if ((var2 in symbol_table) is null)
					{
						throw new Exception("Undefined variable " ~ var2);
					}

					assert(terms[5] == "goto");
					
					auto lbl = terms[6];
					if ((lbl in symbol_table) is null)
					{
						symbol_table[lbl] = Symbol(SType.label, -1); // adress will be set later 
					}

					switch (op)
					{
						case "<":
							command[I] = 2000;
							argument[I] = var1;
							I++;

							command[I] = 3100;
							argument[I] = var2;
							I++;

							command[I] = 4100;
							argument[I] = lbl;
							I++;
							break;

						case ">":
							command[I] = 2000;
							argument[I] = var2;
							I++;
							
							command[I] = 3100;
							argument[I] = var1;
							I++;
							
							command[I] = 4100;
							argument[I] = lbl;
							I++;
							break;

						case "<=":
							command[I] = 2000;
							argument[I] = var1;
							I++;
							
							command[I] = 3100;
							argument[I] = var2;
							I++;
							
							command[I] = 4100;
							argument[I] = lbl;
							I++;

							command[I] = 4200;
							argument[I] = lbl;
							I++;
							break;

						case ">=":
							command[I] = 2000;
							argument[I] = var2;
							I++;
							
							command[I] = 3100;
							argument[I] = var1;
							I++;
							
							command[I] = 4100;
							argument[I] = lbl;
							I++;
							
							command[I] = 4200;
							argument[I] = lbl;
							I++;
							break;

						case "!=":
							throw new Exception("!= not implemented");

						case "==":
							command[I] = 2000;
							argument[I] = var1;
							I++;
							
							command[I] = 3100;
							argument[I] = var2;
							I++;
							
							command[I] = 4200;
							argument[I] = lbl;
							I++;
							break;
					}
					break;

				case "end": // end
					command[I] = 4300;
					I++;
					break;
			}
		}

		foreach(string name, Symbol symbol; symbol_table)
		{
			std.stdio.writeln(name ~ " -> " ~ to!string(symbol.addres));
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