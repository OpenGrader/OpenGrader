// Run with ./grade -directory "C:\Users\theja\OneDrive\Documents\Capstone\OpenGrader\submissions" -lang "python3" -in "C:\Users\theja\OneDrive\Documents\Capstone\OpenGrader\submissions\.spec\out.txt" -args main.py
// .py file to be checked is passed in as an CL argument now
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

// Emulates stdout, stores bytes written.
type CmdOutput struct {
	savedOutput []byte
}

// Collection of submission results. Includes an order array to indicate the order of items in the
// internal map.
type SubmissionResults struct {
	results map[string]*SubmissionResult
	order   []string
}

// Record of a student's submission, with metadata about how it ran and compiled.
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
func compile(dir, language string, wall bool) bool {
	var err error
	var compilePath []string
	var cmd *exec.Cmd

	if language == "java" {
		compilePath, err = filepath.Glob(dir + "/*.java")
		cmd = exec.Command("javac", compilePath...)

	} else if language == "c++" {
		compilePath, err = filepath.Glob(dir + "/*.cpp")
		if wall {
			compilePath = append([]string{"-Wall"}, compilePath...)
			cmd = exec.Command("g++", compilePath...)
		} else {
			cmd = exec.Command("g++", compilePath...)
		}
	} else {
		throw(err)
		fmt.Print("Compilation error, no language found")
	}

	cmd.Dir = dir
	compileErr := cmd.Run()

	// test if exit 0
	return compileErr == nil
}

// Run the compiled program in directory $dir with command-line args $args
func runCompiled(dir, args, language string, input []string) string {
	var stdout CmdOutput
	var cmd *exec.Cmd
	var err error

	if language == "java" {
		cmd = exec.Command("java", strings.Fields(args)...)
	} else if language == "c++" {
		cmd = exec.Command("./a.out", strings.Fields(args)...) // my computer uses a.exe, but this was originally a.out, in case it doesn't work for u, we are working on not hard coding it
	}
	cmd.Dir = dir
	cmd.Stdout = &stdout

	stdin, err := cmd.StdinPipe()
	throw(err)

	cmd.Start()

	processInput(stdin, input)
	cmd.Wait()
	return string(stdout.savedOutput)
}

func runInterpreted(dir, args, language string, input []string) string {
	var stdout CmdOutput
	var cmd *exec.Cmd

	if language == "js" || language == "javascript" {
		cmd = exec.Command("node", strings.Fields(args)...)
	} else {
		cmd = exec.Command(language, strings.Fields(args)...) // ex: python3 main.py arg1 arg2 ... argN
	}
	cmd.Dir = dir
	cmd.Stdout = &stdout
	stdin, err := cmd.StdinPipe()
	throw(err)

	cmd.Start()
	processInput(stdin, input)
	cmd.Wait()

	return string(stdout.savedOutput)
}

// Write provided input to stdin, line by line.
func processInput(stdin io.WriteCloser, input []string) {
	for _, command := range input {
		io.WriteString(stdin, command+"\n")
	}
}

func OSReadDir(root string) []string {
	var files []string
	f, err := os.Open(root)
	if err != nil {
		return files
	}
	fileInfo, err := f.Readdir(-1)
	f.Close()
	if err != nil {
		return files
	}

	for _, file := range fileInfo {
		files = append(files, file.Name())
	}
	print("no error\n")
	return files
}

// Parse user input flags and return as strings.
func parseFlags() (workDir, runArgs, outFile, inFile, language string, wall bool) {
	flag.StringVar(&workDir, "directory", "/code", "student submissions directory")
	flag.StringVar(&runArgs, "args", "", "arguments to pass to compiled programs")
	flag.BoolVar(&wall, "Wall", true, "compile programs using -Wall")
	flag.StringVar(&inFile, "in", "", "file to read interactive input from")
	flag.StringVar(&outFile, "out", "report.csv", "file to write results to")
	flag.StringVar(&language, "lang", "", "Language to be tested")

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
func gradeSubmission(dir, workDir, runArgs, expected, language string, input []string, wall bool) (result SubmissionResult) {
	result.student = dir
	result.compileSuccess = compile(filepath.Join(workDir, dir), language, wall)

	if result.compileSuccess {
		stdout := runCompiled(filepath.Join(workDir, dir), runArgs, language, input)
		fmt.Print(stdout)

		result.runCorrect, result.diff = compare(expected, stdout)
	}

	return
}

func main() {
	workDir, runArgs, outFile, inFile, language, wall := parseFlags()

	cmd := exec.Command("ls")
	cmd.Dir = workDir

	out, _ := cmd.Output()
	dirs := strings.Fields(string(out[:]))

	input := parseInFile(inFile)

	expected := getFile(workDir + "/.spec/out.txt")

	fmt.Println("\nExpected output: ", expected)
	fmt.Print("\n")

	var results SubmissionResults
	results.results = make(map[string]*SubmissionResult)

	if language == "python3" || language == "python" || language == "javascript" || language == "js" {
		for _, dir := range dirs {
			var result SubmissionResult
			results.results[dir] = &result
			results.order = append(results.order, dir)

			result.student = dir
			result.compileSuccess = true

			if result.compileSuccess {
				stdout := runInterpreted(filepath.Join(workDir, dir), runArgs, language, input)
				fmt.Printf("Output for %s: %s", result.student, stdout)
				result.runCorrect, result.diff = compare(expected, stdout)
			}
		}
	} else if language == "java" || language == "c++" {
		for _, dir := range dirs {
			result := gradeSubmission(dir, workDir, runArgs, expected, language, input, wall)
			results.results[dir] = &result
			results.order = append(results.order, dir)
		}
	} else {
		fmt.Print("No language found")
	}
	fmt.Print("\n")
	for _, id := range results.order {
		fmt.Printf("%s: [compileSuccess=%t] [runCorrect=%t]\n", id, results.results[id].compileSuccess, results.results[id].runCorrect)
	}

	createCsv(results, outFile)
}

// This is for getting files in a directory, later to be searched with *.py, if that is how we end up implementing it
// files, err := ioutil.ReadDir(workDir)
// if err != nil {
// 	log.Fatal(err)
// }

// for _, file := range files {
// 	fmt.Println(file.Name(), file.IsDir())
// }
