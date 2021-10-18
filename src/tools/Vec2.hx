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

  /**
   * Returns a new vector where the numbers are at uniform
   * length. If the vec is (5, 1) it will be 1, 1.
   */
  public inline function iUniform():Vec2 {
    var resX = x == 0 ? 0 : x / M.fabs(x);
    var resY = y == 0 ? 0 : y / M.fabs(y);
    return new Vec2(resX, resY);
  }
}