package depot.macros;

#if macro
import haxe.DynamicAccess;
import depot.Types.DepotFile;
import sys.io.File;
import sys.FileSystem;
import haxe.macro.Expr.Field;
import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;
#end
using Lambda;
using StringTools;
using ext.StringExt;

// using StringExtensions;

/**
 * Contains the build macros for creating Depot
 * integration within the Haxe programming language.
 */
class DepotMacros {
	#if macro
	public static macro function buildDepotFile(filePath:String):Array<Field> {
		var buildFields = Context.getBuildFields();

		if (FileSystem.exists(filePath)) {
			var fileData = File.getContent(filePath);
			var depotData:DepotFile = Json.parse(fileData);
			// Depot Starts from inside the data element

			depotData.sheets.iter((sheet) -> {
				var dynamicSheet:DynamicAccess<Dynamic> = cast sheet;
				dynamicSheet.remove('columns'); // Remove columns not needed
				var cleanName = ~/!|\$|-|\s+/g.replace(sheet.name, '_').capitalize();
				var sheetFields = new Map<String, ObjectField>();

				for (key => value in dynamicSheet) {
					var cleanKey = ~/!|\$|-|\s+/g.replace(key, '_');

					// Handles Finding Important Fields
					var endVal = macro $v{value};
					var includeField = true;
					switch (endVal.expr) {
						case EObjectDecl(fields):
							endVal = {
								expr: EObjectDecl(fields.filter((field) -> {
									return switch (field.expr.expr) {
										case EArrayDecl(values):
											values.length > 0 ? true : false;
										case _:
											true;
									}
								})),
								pos: Context.currentPos()
							};

						// Start Of Lines and other array declarations
						case EArrayDecl(values):
							if (values.length < 1) {
								includeField = false;
							} else {
								var newValues = [];
								values.iter((arrExpr) -> {
									// trace(arrExpr);
									switch (arrExpr.expr) {
										case EArrayDecl(values):
											if (values.length > 0) {
												newValues.push(arrExpr);
											}
										case EObjectDecl(fields):
											// Most like creates the lines in the DepotData
											var lineName = '';
											var newDecl = EObjectDecl(fields.filter((field) -> {
												return switch (field.expr.expr) {
													case EArrayDecl(values):
														values.length > 0 ? true : false;
													case _:
														true;
												}
											}).map((field -> {
												field.field = ~/!|\$|-|\s+/g.replace(field.field, '_');
												// Name Individual Lines
												lineName = field.field.contains('name')
													&& lineName == '' ? field.expr.toString() : lineName;
												return field;
											})));
											// Final Result for the line
											var objExpr = {
												expr: newDecl,
												pos: Context.currentPos()
											};
											// Take Result and Convert to individual element
											var valueComplexType = Context.toComplexType(Context.typeof(objExpr));
											var cleanLineName = lineName.replace("\"", "");
											cleanLineName = ~/!|\$|-|\s+/g.replace(cleanLineName, "_");
											var newField:Field = {
												name: '${cleanName}_${cleanLineName}',
												pos: Context.currentPos(),
												kind: FVar(valueComplexType, objExpr),
												access: [Access.APublic, Access.AStatic]
											};
											// Push line as a class property with sheet prefix
											buildFields.push(newField);
											// Push Lines to their individual Sheets
											newValues.push(objExpr);
										case _:
											newValues.push(arrExpr);
									}
								});

								endVal = {
									expr: EArrayDecl(newValues),
									pos: Context.currentPos()
								}
							}
						case _:
							// Do nothing
					}
					// Includes a Field in the sheet, such as lines
					if (includeField) {
						sheetFields.set(cleanKey, {
							field: cleanKey,
							expr: endVal,
						});
					}
				}

				var valueExpr = EObjectDecl(sheetFields.array());
				var result = {expr: valueExpr, pos: Context.currentPos()};
				var valueComplexType = Context.toComplexType(Context.typeof(result));

				var newField:Field = {
					name: cleanName,
					pos: Context.currentPos(),
					kind: FVar(valueComplexType, result),
					access: [Access.APublic, Access.AStatic]
				};
				buildFields.push(newField);
			});
		}

		return buildFields;
	}
	#end
}
