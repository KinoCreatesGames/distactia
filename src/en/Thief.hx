package en;

/**
 * Vassal with the talent that allows them to cut down trees.
 */
class Thief extends Vassal {
  public function new(x:Int, y:Int) {
    super(x, y);
    talent = LOCKPICK;
  }

  override function setSprite() {
    var g = new h2d.Graphics(spr);
    g.beginFill(0x0000aa);
    g.drawRect(0, 0, 16, 16);
    g.endFill();
    g.x -= 8;
  }
}