package tests;

import tests.Tests.TestTemplate;

class Main
{
	public static function main ()
	{
		Sys.print(tests.Tests.TestTemplate.execute({ myvar: "hello2?" }));
	}
}
