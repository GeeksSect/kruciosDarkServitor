module main;

import std.stdio;
import std.format;
import std.exception;
import std.conv;

class VM
{
private:
	alias int REGISTER;
	alias int VM_WORD;
	alias int ADDRES;

	VM_WORD[] program;

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
		program = prog;
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
	}

	void BRANCHZERO(ADDRES addr)
	{
		if (A == 0)
			I = getPhysicalAddres(addr);
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
		foreach (VM_WORD word; program)
		{
			auto command = (word / 100 > 0) ? (word / 100) : -(word / 100);
			auto addr = word % 100;
			switch (command)
			{
				case COMMAND.READ:
					READ(addr);
					break;
				case COMMAND.WRITE:
					WRITE(addr);
					break;
				case COMMAND.LOAD:
					LOAD(addr);
					break;
				case COMMAND.STORE:
					STORE(addr);
					break;
				case COMMAND.LOADTOP:
					LOADTOP();
					break;
				case COMMAND.STORETOP:
					STORETOP();
					break;
				case COMMAND.LOADBIAS:
					LOADBIAS();
					break;
				case COMMAND.STOREBIAS:
					STOREBIAS();
					break;
				case COMMAND.PUSH:
					PUSH();
					break;
				case COMMAND.POP:
					POP();
					break;
				case COMMAND.ADD:
					ADD(addr);
					break;
				case COMMAND.SUBTRACT:
					SUBTRACT(addr);
					break;
				case COMMAND.DIVIDE:
					DIVIDE(addr);
					break;
				case COMMAND.MULTIPLY:
					MULTIPLY(addr);
					break;
				case COMMAND.MOD:
					MOD(addr);
					break;
				case COMMAND.LITERAL:
					LITERAL(addr);
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
				default:
			}
		}
	}
}

void main(string[] args)
{
	auto machine = new VM;
	int[] program = [+1007, 
		             +1008, 
		             +2007, 
		             +3008, 
		             +2109, 
		             +1109, 
		             +4300];

	machine.loadProgram(program);
	machine.execute();
	machine.memoryDump();
	stdin.readln();
}
