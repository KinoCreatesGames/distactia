package tools;

@:structInit
class Vec2 {
  public var x:Float;
  public var y:Float;

  public function new(x:Float, y:Float) {
    this.x = x;
    this.y = y;
  }

  public inline function normalize():Vec2 {
    var mag = this.magnitude();
    return new Vec2(x / mag, y / mag);
  }

  public inline function magnitude() {
    return Math.sqrt(M.pow(x, 2) + M.pow(y, 2));
  }
}