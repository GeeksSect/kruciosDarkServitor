module main;

import std.stdio, std.math;

T gdc(T)(T a, T b)
	if (__traits(compiles, {T a,b,c; c=a%b;} ))
{
	if (!b)
		return a;
	while (a % b)
	{
		T c = a % b;
		a = b;
		b = c;
	}
	return b;
}

struct Vector2d
{
private:
	int fst;
	int sec;

public:
	@property ulong length()
	{
		return 2;
	}

	this(int[2] v)
	{
		fst = v[0];
		sec = v[1];
	}

	this(int n_1, int n_2)
	{
		fst = n_1;
		sec = n_2;
	}

	bool isCollinear(Vector2d n)
	{
		if (this.fst * n.sec - this.sec * n.fst)
			return false;
		return true;
	}

	void print()
	{
		writefln ("[ %d, %d ]", fst, sec);
	}

	Vector2d opBinary(string op)(Vector2d p)
		if (op == "%")
	{
		assert(isCollinear(p));
		return Vector2d(abs(this.fst) % abs(p.fst), abs(this.sec) % abs(p.sec));
	}

	bool opCast(T)()
		if (is (T == bool))
	{
		return (this.fst != 0 || this.sec != 0);
	}
}

void main(string[] args)
{
	Vector2d v1 = [12, 24];
	Vector2d v2 = [-8, -16];
	Vector2d v3 = v1 % v2;
	(gdc(v1, v2)).print();
}

