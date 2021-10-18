package en.enemy;

class Enemy extends Entity {
  public var pathPoints:Array<tools.Vec2>;
  public var looping:Bool;
  public var pointIndex = 0;
  public var reachedFinalDestination:Bool;
  public var forwards:Bool;

  public static inline var WAIT_TIME:Int = 1;

  public function new(patrol:Entity_Patrol) {
    super(patrol.cx, patrol.cy);
    looping = true;
    reachedFinalDestination = false;
    pathPoints = [];
    forwards = true;
    if (patrol.f_path != null) {
      pathPoints = patrol.f_path.map((lPoint) -> new tools.Vec2(lPoint.cx,
        lPoint.cy));
      pathPoints.unshift(new tools.Vec2(cx, cy));
    }
    setSprite();
  }

  public function setSprite() {
    var g = new h2d.Graphics(spr);
    g.beginFill(0xff0000);
    g.drawRect(0, 0, 16, 16);
    g.endFill();
    g.x -= 8;
    g.y -= 16;
  }

  override function update() {
    super.update();
    followPath();
  }

  public function followPath() {
    var point = pathPoints[pointIndex % pathPoints.length];

    if ((point.x != cx || point.y != cy) && !reachedFinalDestination
      && !cd.has('pathing')) {
      // Follow the path by checking the distance from point
      var dest = new Vec2(point.x - cx, point.y - cy).iUniform();
      cx += Std.int(dest.x);
      cy += Std.int(dest.y);
      cd.setS('pathing', WAIT_TIME);
    } else {
      // Hit the final point
      if (pointIndex == (pathPoints.length - 1)) {
        forwards = false;
        // reachedFinalDestination = true;
      } else if (pointIndex == 0) {
        forwards = true;
      }
      if (point.x == cx && point.y == cy) {
        forwards ? pointIndex++ : pointIndex--;
      }
    }
  }
}