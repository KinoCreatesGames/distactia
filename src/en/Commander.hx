package en;

/**
 * Commander that boosts your overal
 * power by 2.
 */
class Commander extends Vassal {
  public function new(x:Int, y:Int) {
    super(x, y);
    talent = COMMANDER;
  }

  override function setSprite() {
    var g = new h2d.Graphics(spr);
    g.beginFill(0xff4400);
    g.drawRect(0, 0, 16, 16);
    g.x -= 8;
    g.y -= 16;
  }
}