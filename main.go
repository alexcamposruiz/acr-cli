package main

import (
	"fmt"
	"io"
	"os"
)

var (
	version = "dev"
	commit  = "none"
	date    = "unknown"
)

func main() {
	os.Exit(run(os.Args[1:], os.Stdout, os.Stderr))
}

func run(args []string, stdout, stderr io.Writer) int {
	if len(args) == 0 {
		printHelp(stdout)
		return 0
	}

	switch args[0] {
	case "-h", "--help", "help":
		printHelp(stdout)
		return 0
	case "version":
		fmt.Fprintf(stdout, "acrcli %s\ncommit: %s\nbuilt: %s\n", version, commit, date)
		return 0
	case "doctor":
		fmt.Fprintln(stdout, "acrcli is installed and ready")
		return 0
	default:
		fmt.Fprintf(stderr, "unknown command: %s\n\n", args[0])
		printHelp(stderr)
		return 2
	}
}

func printHelp(w io.Writer) {
	fmt.Fprint(w, `acrcli is a small release-ready Go CLI.

Usage:
  acrcli <command>

Commands:
  doctor    Check that acrcli runs correctly
  version   Print version and build metadata
  help      Show this help
`)
}
