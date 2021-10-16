package ext;

/**
 * Abstract Pipe for piping data in the application.
 * Credit to Jeremy Meltingtallow
 */
abstract Pipe<T>(T) to T {
	public inline function new(s:T) {
		this = s;
	}

	@:op(A | B)
	public inline function pipe1<U>(fn:T -> U):Pipe<U> {
		return new Pipe(fn(this));
	}

	@:op(A | B)
	public inline function pipe2<A, B>(fn:T -> A -> B):Pipe<A -> B> {
		return new Pipe(fn.bind(this));
	}

	@:op(A | B)
	public inline function pipe3<A, B, C>(fn:T -> A -> B -> C):Pipe<A -> B ->
		C> {
		return new Pipe(fn.bind(this));
	}

	@:op(A | B)
	public inline function pipe4<A, B, C, D>(fn:T -> A -> B -> C ->
		D):Pipe<A -> B -> C -> D> {
		return new Pipe(fn.bind(this));
	}
}