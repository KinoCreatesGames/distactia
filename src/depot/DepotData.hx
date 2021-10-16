package depot;

// Path to your own depot file
#if !macro
@:build(depot.macros.DepotMacros.buildDepotFile('res/depot/database.dpo'))
#end
class DepotData {}
