/**
 * Abilities that each vassal has in the game.
 */
enum abstract Talent(String) from String to String {
  var NONE:String = 'none';

  /**
   * Allows you to cut down trees.
   */
  var CUT:String = 'cut';

  /**
   * Allows you to go through gates
   */
  var LOCKPICK:String = 'lockpick';

  /**
   * Boosts your power by a factor of 2
   */
  var COMMANDER:String = 'commander';

  /**
   * Allows you to swim across water tiles.
   * Without it, you will drown or be stuck.
   */
  var SWIM:String = 'swim';
}

enum abstract Facing(String) from String to String {
  var LEFT:String = 'left';
  var RIGHT:String = 'right';
  var DOWN:String = 'down';
  var UP:String = 'up';
}