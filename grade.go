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

func processInput(stdin io.WriteCloser, input []string) {
	for _, command := range input {
		io.WriteString(stdin, command+"\n")
	}
}

// Parse user input flags and return as strings.
func parseFlags() (workDir, runArgs, outFile, inFile string, wall bool) {
	flag.StringVar(&workDir, "directory", "/code", "student submissions directory")
	flag.StringVar(&runArgs, "args", "", "arguments to pass to compiled programs")
	flag.BoolVar(&wall, "Wall", true, "compile programs using -Wall")
	flag.StringVar(&inFile, "in", "", "file to read interactive input from")
	flag.StringVar(&outFile, "out", "report.csv", "file to write results to")

	flag.Parse()

	return
}

// Generate a list of strings, each a line of user input.
func parseInFile(inFile string) (input []string) {
	if inFile != "" {
		input = strings.Split(getFile(inFile), "\n")
	} else {
		input = []string{}
	}
	return
}

// Grade a single student's submission.
func gradeSubmission(dir, workDir, runArgs, expected string, input []string, wall bool) (result SubmissionResult) {
	result.student = dir

	result.compileSuccess = compile(filepath.Join(workDir, dir), wall)
	if result.compileSuccess {
		stdout := runCompiled(filepath.Join(workDir, dir), runArgs, input)
		result.runCorrect, result.diff = compare(expected, stdout)
	}

	return
}

func main() {
	workDir, runArgs, outFile, inFile, wall := parseFlags()

	fmt.Println("workdir: ", workDir)

	cmd := exec.Command("ls")
	cmd.Dir = workDir

	out, _ := cmd.Output()
	dirs := strings.Fields(string(out[:]))

	input := parseInFile(inFile)

	expected := getFile(workDir + "/.spec/out.txt")
	fmt.Println(expected)

	var results SubmissionResults
	results.results = make(map[string]*SubmissionResult)

	for _, dir := range dirs {
		result := gradeSubmission(dir, workDir, runArgs, expected, input, wall)
		results.results[dir] = &result
	}

	for _, id := range results.order {
		fmt.Printf("%s: [compileSuccess=%t] [runCorrect=%t]\n", id, results.results[id].compileSuccess, results.results[id].runCorrect)
	}

	createCsv(results, outFile)
}
