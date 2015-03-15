module main;

import std.stdio;
import std.file;
import std.format;
import std.exception;
import std.conv;

class VM
{
private:
	alias int REGISTER;
	alias int VM_WORD;
	alias int ADDRES;

	static const int MEMORY_SIZE = 100;

	int[MEMORY_SIZE] memory; // memory of Stack-o-tron

	REGISTER A, // accumulator register
	         I, // instruction register
	         T, // top of stack register
	         BS; // bias register

	// Commands:
	enum COMMAND
	{
		// Input/Output cmds
		READ       = 10,
		WRITE      = 11,
		// Load/Store cmds
		LOAD       = 20,
		STORE      = 21,
		LOADTOP    = 22,
		STORETOP   = 23,
		LOADBIAS   = 24,
		STOREBIAS  = 25,
		PUSH       = 26,
		POP        = 27,
		// Arithmetic cmds
		ADD        = 30,
		SUBTRACT   = 31,
		DIVIDE     = 32,
		MULTIPLY   = 33,
		MOD        = 34,
		LITERAL    = 35,
		// Control cmds
		BRANCH     = 40,
		BRANCHNEG  = 41,
		BRANCHZERO = 42,
		HALT       = 43,
		CALL       = 44,
		RETURN     = 45
	};

	void loadProgram(VM_WORD[] prog)
	{
		int i = 0;
		foreach(command; prog)
		{
			memory[i++] = command;
		}
	}

	// MEMORY ACCESS
	ADDRES getPhysicalAddres(ADDRES logicalAddres)
	{
		if (logicalAddres + BS < 0 || logicalAddres + BS > MEMORY_SIZE)
			throw new Exception("Addres error");
		else
			return logicalAddres + BS;
	}

	void setMem(ADDRES addr, VM_WORD word)
	{
		if (word < -9999 || word > 9999)
			throw new Exception("Wrong machine word");
		if (addr + BS < 0 || addr + BS > MEMORY_SIZE)
			throw new Exception("Addres error");
		else
			memory[addr + BS] = word;
	}

	VM_WORD getMem(ADDRES addr)
	{
		if (addr + BS < 0 || addr + BS > MEMORY_SIZE)
			throw new Exception("Addres error");
		else
			return(memory[addr + BS]);
	}

	// ----- VM COMMANDS
	// Read/Write cmds
	void READ(ADDRES addr)
	{
		VM_WORD temp = to!VM_WORD(readln()[0 .. $ -1]);
		setMem(addr, temp);
	}

	void WRITE(ADDRES addr)
	{
		writeln(getMem(addr));
	}

	// Load/Store cmds
	void LOAD(ADDRES addr)
	{
		A = getMem(addr);
	}

	void STORE(ADDRES addr)
	{
		setMem(addr, A);
	}

	void LOADTOP()
	{
		A = T;
	}

	void STORETOP()
	{
		T = A;
	}

	void LOADBIAS()
	{
		A = BS;
	}

	void STOREBIAS()
	{
		BS = A;
	}

	/* Register TOP refers to empty cell of stack
	 * .
	 * . <- TOP
	 * X <-|
	 * X   |- STACK
	 * X <-|
	 */
	void PUSH()
	{
		if (T == 0)
			throw new Exception("Stack overflow");
		else
		{
			setMem(T, A);
			--T;
		}
	}

	void POP()
	{
		if (T == 99)
			throw new Exception("Stack underflow");
		else
		{
			++T;
			A = getMem(T);
		}
	}

	// Arithmetic cmds
	void ADD(ADDRES addr)
	{
		A = A + getMem(addr);
	}

	void SUBTRACT(ADDRES addr)
	{
		A = A - getMem(addr);
	}

	void DIVIDE(ADDRES addr)
	{
		A = A / getMem(addr);
	}

	void MULTIPLY(ADDRES addr)
	{
		A = A * getMem(addr);
	}

	void MOD(ADDRES addr)
	{
		A = A % getMem(addr);
	}

	void LITERAL(ADDRES addr)
	{
		A = addr;
	}

	// Control cmds
	void BRANCH(ADDRES addr)
	{
		I = getPhysicalAddres(addr);
	}

	void BRANCHNEG(ADDRES addr)
	{
		if (A < 0)
			I = getPhysicalAddres(addr);
		else
			++I;
	}

	void BRANCHZERO(ADDRES addr)
	{
		if (A == 0)
			I = getPhysicalAddres(addr);
		else
			++I;
	}

	// HALT is implemented in main switch as return statement

	void CALL(ADDRES addr)
	{
		VM_WORD temp = A;
		A = I;
		PUSH();
		A = temp;
		BRANCH(addr);
	}

	void RETURN(ADDRES addr) 
	{
		VM_WORD temp = A;
		POP();
		BRANCH(A);
		for (int i = 0; i < addr; ++i)
			POP();
		A = temp;
	}

public:
	this()
	{
		A = 0;
		I = 0;
		T = 99;
		BS = 0;
	}

	void memoryDump()
	{
		writeln("--== REGISTERS ==--\n");
		writeln("Accumulator: ", A);
		writeln("Instruction: ", I);
		writeln("Top:         ", T);
		writeln("BIAS:        ", BS);
		writeln("\n--== MEMORY ==--\n");
		writeln("   |   0   |   1   |   2   |   3   |   4   |   5   |   6   |   7   |   8   |   9   |");
		for(int i = 0; i < MEMORY_SIZE / 10; ++i)
		{
			write(i, "0:");
			for(int j = 0; j < 10; ++j)
			{
				writef("%+8s", memory[i * 10 + j], " ");
			}
			write("\n");
		}

	}

	void execute()
	{
		while (true)
		{
			VM_WORD word = memory[I];
			// writeln("Instruction: ", I, " WORD: ", word);
			auto command = (word / 100 > 0) ? (word / 100) : -(word / 100);
			auto addr = word % 100;
			final switch (command)
			{
				case COMMAND.READ:
					READ(addr);
					++I;
					break;
				case COMMAND.WRITE:
					WRITE(addr);
					++I;
					break;
				case COMMAND.LOAD:
					LOAD(addr);
					++I;
					break;
				case COMMAND.STORE:
					STORE(addr);
					++I;
					break;
				case COMMAND.LOADTOP:
					LOADTOP();
					++I;
					break;
				case COMMAND.STORETOP:
					STORETOP();
					++I;
					break;
				case COMMAND.LOADBIAS:
					LOADBIAS();
					++I;
					break;
				case COMMAND.STOREBIAS:
					STOREBIAS();
					++I;
					break;
				case COMMAND.PUSH:
					PUSH();
					++I;
					break;
				case COMMAND.POP:
					POP();
					++I;
					break;
				case COMMAND.ADD:
					ADD(addr);
					++I;
					break;
				case COMMAND.SUBTRACT:
					SUBTRACT(addr);
					++I;
					break;
				case COMMAND.DIVIDE:
					DIVIDE(addr);
					++I;
					break;
				case COMMAND.MULTIPLY:
					MULTIPLY(addr);
					++I;
					break;
				case COMMAND.MOD:
					MOD(addr);
					++I;
					break;
				case COMMAND.LITERAL:
					LITERAL(addr);
					++I;
					break;
				case COMMAND.BRANCH:
					BRANCH(addr);
					break;
				case COMMAND.BRANCHNEG:
					BRANCHNEG(addr);
					break;
				case COMMAND.BRANCHZERO:
					BRANCHZERO(addr);
					break;
				case COMMAND.HALT:
					return; 
				case COMMAND.CALL:
					CALL(addr);
					break;
				case COMMAND.RETURN:
					RETURN(addr);
					break;
			}
		}
	}
}

int[] parseCode(string code)
{
	int[] program;
	string word = "+0000";
	while (code != "")
	{
		word = code[0 .. 5];
		code = code[6 .. $];
		program ~= to!int(word);
	}
	return program;
}

void main(string[] args)
{
	writeln(args);
	auto machine = new VM;
	string line, text;
	auto file = File(args[1], "r");
	while ((line = file.readln()) !is null)
		text ~= line;
	writeln(text);
	int[] program = parseCode(text);

	writeln("====== START PROGRAM ======");
	machine.loadProgram(program);
	machine.execute();
	writeln("==== PROGRAM COMPLETED ====");
	machine.memoryDump();
	readln();
}
