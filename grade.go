package main

import (
	"encoding/csv"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/andreyvit/diff"
)

type CmdOutput struct {
	savedOutput []byte
}

type SubmissionResults struct {
	results map[string]*SubmissionResult
	order   []string
}

type SubmissionResult struct {
	student        string
	compileSuccess bool
	runCorrect     bool
	diff           string
}

// Allows capturing stdin by setting cmd.Stdin to an instance of CmdOutput
func (out *CmdOutput) Write(p []byte) (n int, err error) {
	out.savedOutput = append(out.savedOutput, p...)
	return 0, nil
}

// Crash if an error is present
func throw(e error) {
	if e != nil {
		panic(e)
	}
}

// Load a file $fp into memory
func getFile(fp string) string {
	data, err := os.ReadFile(fp)
	throw(err)
	return string(data)
}

// Evaluate a diff to see if they are equal
func evaluateDiff(diff string) bool {
	for _, line := range strings.Split(diff, "\n") {
		if line[0] != ' ' {
			return false
		}
	}

	return true
}

// Diff two strings
func compare(expected, actual string) (bool, string) {
	d := diff.LineDiff(strings.TrimSpace(expected), strings.TrimSpace(actual))

	return evaluateDiff(d), d
}

// Convert boolean to string
func btoa(b bool) string {
	if b {
		return "true"
	}
	return "false"
}

// Write a CSV report with information from $results to $outfile
func createCsv(results SubmissionResults, outfile string) {
	file, err := os.Create(outfile)
	throw(err)

	writer := csv.NewWriter(file)
	writer.Write([]string{"student", "compiled", "ran correctly", "diff"})
	for _, id := range results.order {
		result := results.results[id]
		row := []string{result.student, btoa(result.compileSuccess), btoa(result.runCorrect), result.diff}
		if err := writer.Write(row); err != nil {
			log.Fatalln("error writing record to file", err)
		}
	}
	writer.Flush()
	file.Close()
}

// Compiles a student submission located in $dir.
// Returns true if compiled without errors.
func compile(dir string, wall bool) bool {
	compilePath, err := filepath.Glob(dir + "/*.cpp")
	throw(err)

	var cmd *exec.Cmd
	if wall {
		compilePath = append([]string{"-Wall"}, compilePath...)
		cmd = exec.Command("g++", compilePath...)
	} else {
		cmd = exec.Command("g++", compilePath...)
	}
	cmd.Dir = dir

	compileErr := cmd.Run()

	// test if exit 0
	return compileErr == nil
}

// Run the compiled program in directory $dir with command-line args $args
func runCompiled(dir, args string, input []string) string {
	var stdout CmdOutput

	cmd := exec.Command("./a.out", strings.Fields(args)...)
	cmd.Dir = dir
	cmd.Stdout = &stdout

	stdin, err := cmd.StdinPipe()
	throw(err)

	cmd.Start()

	processInput(stdin, input)

	cmd.Wait()
	return string(stdout.savedOutput)
}

// Takes pipe to standard input $stdin and an array of strings $input as input. It writes each string in the array to standard input $stdin.
func processInput(stdin io.WriteCloser, input []string) {
	for _, command := range input {
		io.WriteString(stdin, command+"\n")
	}
}

func main() {

	// All of the flags for the executable. The functions follow the pattern of
	// Pointer to variable where value of flag will be stored, name of flag, default value if none given, description of flag
	var workDir string
	var runArgs string
	var wall bool
	var outfile string
	var infile string
	flag.StringVar(&workDir, "directory", "/code", "student submissions directory")
	flag.StringVar(&runArgs, "args", "", "arguments to pass to compiled programs")
	flag.BoolVar(&wall, "Wall", true, "compile programs using -Wall")
	flag.StringVar(&infile, "in", "", "file to read interactive input from")
	flag.StringVar(&outfile, "out", "report.csv", "file to write results to")

	flag.Parse()

	fmt.Println("workdir: ", workDir)

	cmd := exec.Command("ls") // Sets the command to be executed. Does not execute at this point.
	cmd.Dir = workDir         // Assigns the value of the working directory passed from args as the working directory for command to be executed in.

	out, _ := cmd.Output()                 // This runs and takes the output from "ls" called above and returns it as a singular byte slice
	dirs := strings.Fields(string(out[:])) // Parses the entire out byte slice (think of it as a char array) and returns an array of strings with the name of each directory

	var input []string
	if infile != "" { // If an input file does exist
		input = strings.Split(getFile(infile), "\n") // Split each of the newline separated inputs in the file into an array of strings
	} else {
		input = []string{} // If input file is blank / does not exist, return empty array
	}

	expected := getFile(workDir + "/.spec/out.txt") // Read file containing expected output
	fmt.Println(expected)

	var results SubmissionResults                        // Initialize a variable with the type of SubmissionResults struct (not SubmissionResult!)
	results.results = make(map[string]*SubmissionResult) // Construct a map w keys of string type and values of SubmissionResult pointer

	for _, dir := range dirs { // Loop through each directory
		var result SubmissionResult
		results.results[dir] = &result             // Assign the value in the results map to a pointer to the result with the directory name as key
		results.order = append(results.order, dir) // Add directory name to results to keep track of order

		result.student = dir                                               // Set the student attribute to the name of directory
		result.compileSuccess = compile(filepath.Join(workDir, dir), wall) // Verify compilation

		if result.compileSuccess {
			stdout := runCompiled(filepath.Join(workDir, dir), runArgs, input) // If compiled successfully, execute and
			result.runCorrect, result.diff = compare(expected, stdout)
		}
	}

	for _, id := range results.order {
		fmt.Printf("%s: [compileSuccess=%t] [runCorrect=%t]\n", id, results.results[id].compileSuccess, results.results[id].runCorrect)
	}

	createCsv(results, outfile)
}
