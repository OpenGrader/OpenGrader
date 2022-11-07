// Run with ./grade -directory "C:\Users\theja\OneDrive\Documents\Capstone\OpenGrader\submissions" -lang "python" -in "C:\Users\theja\OneDrive\Documents\Capstone\OpenGrader\submissions\.spec\out.txt" -args main.py
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

func runInterpreted(dir, args, pathVar string, input []string) string {

	command := strings.Join([]string{pathVar, ""}, " ")

	// alt method
	// put check for python or python3, error catching n shit
	command = "python" // only bc my shell works only with python and not python3
	out, err := exec.Command(command, dir+"\\"+args).Output()

	if err != nil {
		log.Fatal(err)
	}

	return string(out[:])
}

// figure out how to get rid of this / if it breaks something
func processInput(stdin io.WriteCloser, input []string) {

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

func main() {
	var workDir string
	var runArgs string
	var language string
	var wall bool
	var outfile string
	var infile string
	flag.StringVar(&language, "lang", "", "Language to be tested")
	flag.StringVar(&workDir, "directory", "/code", "student submissions directory")
	flag.StringVar(&runArgs, "args", "", "arguments to pass to compiled programs")
	flag.BoolVar(&wall, "Wall", true, "compile programs using -Wall")
	flag.StringVar(&infile, "in", "", "file to read interactive input from")
	flag.StringVar(&outfile, "out", "report.csv", "file to write results to")

	flag.Parse()

	cmd := exec.Command("ls")
	cmd.Dir = workDir

	out, _ := cmd.Output()
	dirs := strings.Fields(string(out[:]))

	var input []string
	if infile != "" {
		input = strings.Split(getFile(infile), "\n")
	} else {
		input = []string{}
	}

	expected := getFile(workDir + "/.spec/out.txt")
	fmt.Println("Expected output: ", expected)

	var results SubmissionResults
	results.results = make(map[string]*SubmissionResult)

	if language == "python" {
		for _, dir := range dirs {
			var result SubmissionResult
			results.results[dir] = &result
			results.order = append(results.order, dir)

			result.student = dir
			result.compileSuccess = true

			if result.compileSuccess {
				stdout := runInterpreted(filepath.Join(workDir, dir), runArgs, "python3", input)
				fmt.Printf("Output for %s: %s", result.student, stdout)
				result.runCorrect, result.diff = compare(expected, stdout)
			}
		}
	} else {
		for _, dir := range dirs {
			var result SubmissionResult
			results.results[dir] = &result
			results.order = append(results.order, dir)

			result.student = dir
			result.compileSuccess = compile(filepath.Join(workDir, dir), wall)

			if result.compileSuccess {
				stdout := runCompiled(filepath.Join(workDir, dir), runArgs, input)
				result.runCorrect, result.diff = compare(expected, stdout)
			}
		}
	}

	for _, id := range results.order {
		fmt.Printf("%s: [compileSuccess=%t] [runCorrect=%t]\n", id, results.results[id].compileSuccess, results.results[id].runCorrect)
	}

	createCsv(results, outfile)
}

// This is for getting files in a directory, later to be searched with *.py, if that is how we end up implementing it
// files, err := ioutil.ReadDir(workDir)
// if err != nil {
// 	log.Fatal(err)
// }

// for _, file := range files {
// 	fmt.Println(file.Name(), file.IsDir())
// }
