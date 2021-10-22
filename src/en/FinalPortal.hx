package en;

class FinalPortal extends Entity {
  public function new(x:Int, y:Int) {
    super(x, y);
    setSprite();
  }

  public function setSprite() {
    var tile = hxd.Res.maps.map.toTile();
    tile.setPosition(80, 80);
    var g = new h2d.Graphics(spr);
    g.beginTileFill(0, 0, 1, 1, tile);
    g.drawRect(0, 0, 16, 16);
    g.endFill();
    g.x -= 8;
    g.y -= 16;
  }
}