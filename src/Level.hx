import en.enemy.Enemy;
import en.obstacles.Gate;
import en.Goal;
import en.Commander;
import en.obstacles.Tree;
import en.Thief;
import en.Cutter;
import en.Player;
import en.obstacles.Obstacle;

class Level extends dn.Process {
  var game(get, never):Game;

  inline function get_game()
    return Game.ME;

  var fx(get, never):Fx;

  inline function get_fx()
    return Game.ME.fx;

  /** Level grid-based width**/
  public var cWid(get, never):Int;

  inline function get_cWid()
    return 16;

  /** Level grid-based height **/
  public var cHei(get, never):Int;

  inline function get_cHei()
    return 16;

  /** Level pixel width**/
  public var pxWid(get, never):Int;

  inline function get_pxWid()
    return cWid * Const.GRID;

  /** Level pixel height**/
  public var pxHei(get, never):Int;

  inline function get_pxHei()
    return cHei * Const.GRID;

  var invalidated = true;

  public var player:en.Player;
  public var vassalGrp:Array<en.Vassal>;
  public var enemyGrp:Array<Enemy>;

  public var hazards:Array<Obstacle>;
  public var goals:Array<Goal>;

  public var data:LDTkProj_Level;

  public function new(level:LDTkProj_Level) {
    super(Game.ME);
    data = level;
    createRootInLayers(Game.ME.scroller, Const.DP_BG);
    createGroups();
    createEntities();
  }

  public function createGroups() {
    vassalGrp = [];
    hazards = [];
    goals = [];
    enemyGrp = [];
  }

  public function createEntities() {
    for (lPlayer in data.l_Entities.all_Player) {
      player = new Player(lPlayer.cx, lPlayer.cy);
    }

    for (enemy in data.l_Entities.all_Patrol) {
      enemyGrp.push(new Enemy(enemy));
    }

    for (cutter in data.l_Entities.all_Cutter) {
      vassalGrp.push(new Cutter(cutter.cx, cutter.cy));
    }

    for (thief in data.l_Entities.all_Thief) {
      vassalGrp.push(new Thief(thief.cx, thief.cy));
    }

    for (commander in data.l_Entities.all_Commander) {
      vassalGrp.push(new Commander(commander.cx, commander.cy));
    }

    for (tree in data.l_Entities.all_Tree) {
      hazards.push(new Tree(tree.cx, tree.cy));
    }

    for (gate in data.l_Entities.all_Gate) {
      hazards.push(new Gate(gate.cx, gate.cy));
    }

    for (goal in data.l_Entities.all_Goal) {
      goals.push(new Goal(goal.cx, goal.cy));
    }
  }

  public function hasAnyCollision(x:Int, y:Int) {
    return data.l_AutoBase.getInt(x, y) == 1;
  }

  public function collidedEnemy(x:Int, y:Int) {
    return enemyGrp.filter((enemy) -> enemy.cx == x && enemy.cy == y
      && enemy.isAlive())
      .first();
  }

  public function collidedVassal(x:Int, y:Int) {
    return vassalGrp.filter((vassal) -> vassal.cx == x && vassal.cy == y
      && vassal.isAlive())
      .first();
  }

  public function collidedObstacle(x:Int, y:Int) {
    return hazards.filter((hazard) -> hazard.cx == x && hazard.cy == y
      && hazard.isAlive())
      .first();
  }

  public function collidedGoal(x:Int, y:Int) {
    return goals.filter((goal) -> goal.cx == x && goal.cy == y
      && goal.isAlive())
      .first();
  }

  /** TRUE if given coords are in level bounds **/
  public inline function isValid(cx, cy)
    return cx >= 0 && cx < cWid && cy >= 0 && cy < cHei;

  /** Gets the integer ID of a given level grid coord **/
  public inline function coordId(cx, cy)
    return cx + cy * cWid;

  /** Ask for a level render that will only happen at the end of the current frame. **/
  public inline function invalidate() {
    invalidated = true;
  }

  function render() {
    // Placeholder level render
    root.removeChildren();
    // Render Map
    var group = data.l_AutoTiles.render();

    root.addChild(group);
    dn.Process.resizeAll();
  }

  override function postUpdate() {
    super.postUpdate();

    if (invalidated) {
      invalidated = false;
      render();
    }
  }

  override function onDispose() {
    super.onDispose();
    if (player != null) {
      player.dispose();
    }

    for (follower in vassalGrp) {
      follower.dispose();
    }
    for (el in hazards) {
      el.dispose();
    }

    for (enemy in enemyGrp) {
      enemy.dispose();
    }
  }
}