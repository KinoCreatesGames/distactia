package en.obstacles;

class Obstacle extends Entity {
  public function new(x:Int, y:Int) {
    super(x, y);
    setSprite();
  }

  // For some reason causing issues; inline fixes issue
  public inline function setSprite() {
    var g = new h2d.Graphics(spr);
    g.beginFill(0xff3000);
    g.drawRect(0, 0, 16, 16);
    g.endFill();
    g.x -= 8;
  }
}