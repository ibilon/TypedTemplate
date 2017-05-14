package typedtemplate;

enum Token
{
	TAny (value:String);
	TEnd;
	TEoF;
	TEscN;
	TEscR;
	TEscT;
	TQuote;
	TStart;
}

class Lexer extends hxparse.Lexer
{
	public static var tok = hxparse.Lexer.buildRuleset([
		{ rule: "<\\?haxe",  func: function (lexer) return TStart },
		{ rule: "haxe\\?>",  func: function (lexer) return TEnd },
		{ rule: "\t",        func: function (lexer) return TEscT },
		{ rule: "\n",        func: function (lexer) return TEscN },
		{ rule: "\r",        func: function (lexer) return TEscR },
		{ rule: '\\\\"',     func: function (lexer) return TAny('\\"') },
		{ rule: "\\\\.",     func: function (lexer) return TAny("\\" + lexer.current) },
		{ rule: '"',         func: function (lexer) return TQuote },
		{ rule: ".",         func: function (lexer) return TAny(lexer.current) },
		{ rule: "",          func: function (lexer) return TEoF }
	]);
}

class Parser
{
	public static function getCode (template:String) : String
	{
		var result = new StringBuf();

		function openNormalMode ()
		{
			result.add('\nprint("');
		}

		function closeNormalMode ()
		{
			result.add('");\n');
		}

		var lexer = new Lexer(byte.ByteData.ofString(template));
		var inHaxeMode = false;
		var inString = false;

		openNormalMode();

		while (true)
		{
			var token = lexer.token(typedtemplate.Lexer.tok);

			switch (token)
			{
				case TAny(v):
					result.add(v);

				case TEnd:
					if (inString)
					{
						result.add("haxe?>");
					}
					else
					{
						inHaxeMode = false;
						openNormalMode();
					}

				case TEoF:
					if (!inHaxeMode)
					{
						closeNormalMode();
					}
					break;

				case TEscN:
					if (inString)
					{
						result.add("\\n");
					}
					else
					{
						result.add("\n");
					}

				case TEscR:
					if (inString)
					{
						result.add("\\r");
					}
					else
					{
						result.add("\r");
					}

				case TEscT:
					if (inString)
					{
						result.add("\\t");
					}
					else
					{
						result.add("\t");
					}

				case TQuote:
					if (inHaxeMode)
					{
						inString = !inString;
						result.add('"');
					}
					else
					{
						result.add('\\"');
					}

				case TStart:
					if (inString)
					{
						result.add("<?haxe");
					}
					else
					{
						closeNormalMode();
						inHaxeMode = true;
					}
			}
		}

		return result.toString();
	}
}
