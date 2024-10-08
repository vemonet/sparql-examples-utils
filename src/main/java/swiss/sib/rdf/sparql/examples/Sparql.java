package swiss.sib.rdf.sparql.examples;

import picocli.CommandLine;
import picocli.CommandLine.Command;

@Command(subcommands = { Converter.class, Tester.class, Fixer.class }, name = "sparql-examples")
public class Sparql {
	public static void main(String[] args) {

		int exitCode = new CommandLine(new Sparql()).execute(args);
		System.exit(exitCode);
	}
}
