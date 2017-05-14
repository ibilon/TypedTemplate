package typedtemplate;

import haxe.macro.Context;

using haxe.io.Path;

class TypedTemplateBuilder
{
	public static function build ()
	{
		return switch (Context.getLocalType())
		{
			case TInst(_, [TInst(_.get() => { kind: KExpr(macro $v{(s:String)}) }, _)]):
				make(s);

			default:
				Context.error("Class expected", Context.currentPos());
				null;
		}
	}

	static function make (filename:String)
	{
		var name = filename.withoutDirectory().withoutExtension();
		name = "TypedTemplate__Impl__" + name.charAt(0).toUpperCase() + name.substr(1);

		try
		{
			return Context.getType(name);
		}
		catch (_:Dynamic)
		{
		}

		var code = "{" + typedtemplate.Parser.getCode(sys.io.File.getContent(filename)) + "}";
		var codeExpr = Context.parseInlineString(code, Context.makePosition({ min: 0, max: 0, file: filename }));

		var cls = macro class $name
		{
			public static function execute (vars)
			{
				var __result = new StringBuf();

				function print<T> (v:T)
				{
					__result.add(Std.string(v));
				}

				function println<T> (v:T)
				{
					print(v);
					print("\n");
				}

				$codeExpr;

				return __result.toString();
			}
		};

		/*
		var p = new haxe.macro.Printer();
		trace(p.printTypeDefinition(cls));
		*/

		Context.defineType(cls);
		return Context.getType(name);
	}
}
