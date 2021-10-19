package en;

import dn.heaps.filter.PixelOutline;

/**
 * Allows you to swim across water tiles.
 */
class Mermaid extends Vassal {
  public function new(x:Int, y:Int) {
    super(x, y);
    talent = SWIM;
  }

  override function setSprite() {
    super.setSprite();
    var tile = hxd.Res.img.mermaid.toTile();
    var g = new h2d.Graphics(spr);
    spr.filter = new PixelOutline(0x0, 1);
    g.beginTileFill(0, 0, 1, 1, tile);
    g.drawRect(0, 0, 16, 16);
    g.endFill();
    g.x -= 8;
    g.y -= 16;
  }
}