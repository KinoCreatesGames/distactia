package en;

import GameTypes.Talent;

class Vassal extends Entity {
  public var talent:Talent;

  public function new(x:Int, y:Int) {
    super(x, y);
    setSprite();
  }

  public function setSprite() {
    var g = new h2d.Graphics(spr);
    g.beginFill(0xffffff);
    g.drawRect(0, 0, 16, 16);
    g.endFill();
    g.x -= 8;
  }
}