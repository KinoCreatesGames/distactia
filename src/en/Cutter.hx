package en;

/**
 * Vassal with the talent that allows them to cut down trees.
 */
class Cutter extends Vassal {
  public function new(x:Int, y:Int) {
    super(x, y);
    talent = CUT;
  }

  override function setSprite() {
    super.setSprite();
    var g = new h2d.Graphics(spr);
    g.drawRect(0, 0, 16, 16);
    g.endFill();
    g.x -= 8;
  }
}