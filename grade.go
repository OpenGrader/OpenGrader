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
	"github.com/joho/godotenv"
	supa "github.com/nedpals/supabase-go"

	"github.com/OpenGrader/OpenGrader/db"
	"github.com/OpenGrader/OpenGrader/util"
)

// Emulates stdout, stores bytes written.
type CmdOutput struct {
	savedOutput []byte
}

// Enum to contain the different types of directives that could be used in spec file
type directive int

const (
	MENU directive = iota
	IGNORE
	NONE
)

// Allows capturing stdin by setting cmd.Stdin to an instance of CmdOutput
func (out *CmdOutput) Write(p []byte) (n int, err error) {
	out.savedOutput = append(out.savedOutput, p...)
	return 0, nil
}

// Load a file $fp into memory
func getFile(fp string) string {
	data, err := os.ReadFile(fp)
	util.Throw(err)
	return string(data)
}

// Evaluate a diff to see if they are equal
func evaluateDiff(diff string) bool {
	for _, line := range strings.Split(diff, "\n") {
		if len(line) == 0 {
			continue
		}
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

func handleDirectives(expected, actual []string) (fixedExpected, fixedActual []string) {
	// If there is no bang-sh
	if !strings.Contains(expected[0], "!#") {
		return expected, actual
	} else {
		fixedExpected = expected[1:] // Copy everything beyond the first value in expected (the line with the directives)
		fixedActual = actual
		if strings.Contains(expected[0], "c") {
			for i := range fixedExpected {
				// set all lowercase
				fixedExpected[i] = strings.ToLower(fixedExpected[i])
			}
			for i := range fixedActual {
				fixedActual[i] = strings.ToLower(fixedActual[i])
			}
		}

		if strings.Contains(expected[0], "w") {
			for i := range fixedExpected {
				// set all lowercase
				fixedExpected[i] = strings.ReplaceAll(fixedExpected[i], " ", "")
			}
			for i := range fixedActual {
				fixedActual[i] = strings.ReplaceAll(fixedActual[i], " ", "")
			}
		}
	}
	return fixedExpected, fixedActual
}

// Helper method to make process output simpler and more readable.
// Checks to see if a custom syntax is used and returns the proper directive
func getDirectives(line string) directive {
	if strings.HasPrefix(line, "!") {
		if strings.Contains(strings.ToLower(line), "menu") {
			return MENU
		} else if strings.Contains(strings.ToLower(line), "ignore") {
			return IGNORE
		}
	}
	return NONE
}

// Helper method to turn string slice into a readable, new line separated string that will print well in the report
func stringSliceToPrettyString(input []string) string {
	var output string = ""
	for _, str := range input {
		if str != "" {
			output += fmt.Sprintf("%s\n", str)
		}
	}
	return strings.TrimSpace(output)
}

// If all of the results are empty strings, program ran correct so return true. Else, return false
func evalResults(res []string) bool {
	for _, v := range res {
		if v != "" {
			return false
		}
	}
	return true
}

// Function that evaluates student program output by computing it to expected output
// Supports custom syntax in out.txt file, represented by the Syntax Dictionary in support.go
func processOutput(expected, actual string) (bool, string) {

	// Convert strings into array of strings separated by a newline and manipulate text to handle any directives
	expectedLines, actualLines := handleDirectives(strings.Split(expected, "\n"), strings.Split(actual, "\n"))

	// Variable to track position in actualLines[]
	position := 0

	// String array containing feedback of each line.
	results := make([]string, len(expectedLines))

	// Loop across each line of expected to compare to actual
	for i, line := range expectedLines {
		if i > 0 {
			position++ // Increment each step after first pass
		}
		// if there are no more lines of actual output to compare it to, break
		if i+1 > len(actualLines) {
			break
		}

		switch getDirectives(line) {
		case MENU:
			var feedback []string
			feedback, position, actualLines = SyntaxDictionary["menu"](line, actualLines, i)
			results[i] = stringSliceToPrettyString(feedback)
		case IGNORE:
			var feedback []string
			feedback, position, actualLines = SyntaxDictionary["ignore"](line, actualLines, i)
			results[i] = stringSliceToPrettyString(feedback)
		case NONE:
			isNotDiff, diff := compare(line, actualLines[position])
			if isNotDiff {
				results[i] = ""
			} else {
				results[i] = diff
			}

		}
	}
	return evalResults(results), stringSliceToPrettyString(results)
}

// Convert boolean to string
func btoa(b bool) string {
	if b {
		return "true"
	}
	return "false"
}

// Write a CSV report with information from $results to $outfile
func createCsv(results util.SubmissionResults, outfile string) {
	file, err := os.Create(outfile)
	util.Throw(err)

	writer := csv.NewWriter(file)
	writer.Write([]string{"student", "compiled", "ran correctly", "feedback"})
	for _, id := range results.Order {
		result := results.Results[id]
		row := []string{result.Student, btoa(result.CompileSuccess), btoa(result.RunCorrect), result.Feedback}
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
	util.Throw(err)

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
	util.Throw(err)

	cmd.Start()

	processInput(stdin, input)

	cmd.Wait()
	return string(stdout.savedOutput)
}

func runInterpreted(dir, args string, input []string) string {
	var stdout CmdOutput

	cmd := exec.Command("python3", strings.Fields(args)...) //ex: python3 main.py arg1 arg2 ... argN
	cmd.Dir = dir
	cmd.Stdout = &stdout
	stdin, err := cmd.StdinPipe()
	util.Throw(err)

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
func parseFlags() (workDir, runArgs, outFile, inFile, language string, wall bool, isDryRun bool, server bool) {
	flag.StringVar(&workDir, "directory", "/code", "student submissions directory")
	flag.StringVar(&runArgs, "args", "", "arguments to pass to compiled programs")
	flag.BoolVar(&wall, "Wall", true, "compile programs using -Wall")
	flag.StringVar(&inFile, "in", "", "file to read interactive input from")
	flag.StringVar(&outFile, "out", "report.csv", "file to write results to")
	flag.StringVar(&language, "lang", "", "Language to be tested")
	flag.BoolVar(&isDryRun, "dry-run", false, "skip upload to db")
	flag.BoolVar(&server, "server", false, "Run OpenGrader server instead of engine")

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
func gradeSubmission(dir, workDir, runArgs, expected string, input []string, wall bool) (result util.SubmissionResult) {
	result.Student = dir

	result.CompileSuccess = compile(filepath.Join(workDir, dir), wall)
	if result.CompileSuccess {
		stdout := runCompiled(filepath.Join(workDir, dir), runArgs, input)
		result.RunCorrect, result.Feedback = compare(expected, stdout)
	}

	return
}

func initSupabase() *supa.Client {
	supabaseUrl := os.Getenv("SUPABASE_URL")
	supabaseKey := os.Getenv("SUPABASE_KEY")
	return supa.CreateClient(supabaseUrl, supabaseKey)
}

func writeFullOutputToDb(supabase *supa.Client, results util.SubmissionResults) {
	for _, id := range results.Order {
		result := results.Results[id]
		db.SaveResult(supabase, result)
	}
}

func main() {
	workDir, runArgs, outFile, inFile, language, wall, isDryRun, server := parseFlags()
	if server {
		fmt.Println("=== API Started ===")
		Server()
		return
	}

	if isDryRun {
		fmt.Println("=== Dry run - output will not be uploaded to database ===")
	}
	godotenv.Load()

	supabase := initSupabase()

	fmt.Println("workdir: ", workDir)

	cmd := exec.Command("ls")
	cmd.Dir = workDir

	out, _ := cmd.Output()
	dirs := strings.Fields(string(out[:]))

	input := parseInFile(inFile)

	expected := getFile(workDir + "/.spec/out.txt")
	fmt.Println(expected)

	var results util.SubmissionResults
	results.Results = make(map[string]*util.SubmissionResult)

	for _, dir := range dirs {
		var result util.SubmissionResult
		results.Results[dir] = &result
		results.Order = append(results.Order, dir)

		result.Student = dir
		// find hydratedStudent information from EUID (dirname)
		hydratedStudent := db.GetStudentByEuid(supabase, dir)

		// if student doesn't exist, commit to db
		if hydratedStudent.Id == 0 {
			hydratedStudent.Euid = dir
			hydratedStudent.Email = fmt.Sprintf("%s@unt.edu", dir) // all students have euid@unt.edu

			fmt.Printf("%8s: ", dir)
			fmt.Printf("%+v\n", hydratedStudent)

			if !isDryRun {
				hydratedStudent.Save(supabase)
			}
		}

		result.StudentId = hydratedStudent.Id
		result.AssignmentId = int8(1)

		if language == "python3" || language == "python" {
			result.CompileSuccess = true

			stdout := runInterpreted(filepath.Join(workDir, dir), runArgs, input)
			fmt.Printf("Output for %s: %s", result.Student, stdout)
			result.RunCorrect, result.Feedback = compare(expected, stdout)
		} else {
			result.CompileSuccess = compile(filepath.Join(workDir, dir), wall)
			if result.CompileSuccess {
				stdout := runCompiled(filepath.Join(workDir, dir), runArgs, input)
				result.RunCorrect, result.Feedback = processOutput(expected, stdout)
			}
		}
	}

	for _, id := range results.Order {
		fmt.Printf("%s: [compileSuccess=%t] [runCorrect=%t]\n", id, results.Results[id].CompileSuccess, results.Results[id].RunCorrect)
	}

	if !isDryRun {
		writeFullOutputToDb(supabase, results)
	}

	createCsv(results, outFile)

	// This is for getting files in a directory, later to be searched with *.py, if that is how we end up implementing it
	// files, err := ioutil.ReadDir(workDir)
	// if err != nil {
	// 	log.Fatal(err)
	// }

	//	for _, file := range files {
	//		fmt.Println(file.Name(), file.IsDir())
	//	}
}
