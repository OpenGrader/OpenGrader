// Run with ./grade -directory "C:\Users\theja\OneDrive\Documents\Capstone\OpenGrader\submissions" -lang "python3" -in "C:\Users\theja\OneDrive\Documents\Capstone\OpenGrader\submissions\.spec\out.txt" -args main.py
// .py file to be checked is passed in as an CL argument now
package main

import (
	"bytes"
	"archive/zip"
	"encoding/csv"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
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

// Emulates stderr, stores bytes written.
type CmdError struct {
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

func (e *CmdError) Write(p []byte) (n int, err error) {
	e.savedOutput = append(e.savedOutput, p...)
	return 0, nil
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

// Function that evaluates student program output by computing it to expected output
// Supports custom syntax in out.txt file, represented by the Syntax Dictionary in support.go
func processOutput(expected, actual string) string {

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
			results[i] = util.StringSliceToPrettyString(feedback)
		case IGNORE:
			var feedback []string
			feedback, position, actualLines = SyntaxDictionary["ignore"](line, actualLines, i)
			results[i] = util.StringSliceToPrettyString(feedback)
		case NONE:
			isNotDiff, diff := compare(line, actualLines[position])
			if isNotDiff {
				results[i] = ""
			} else {
				results[i] = diff
			}

		}
	}
	return util.StringSliceToPrettyString(results)
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

	writeErr := writer.Write([]string{"student", "compiled", "score", "feedback"})
	util.Throw(writeErr)

	for _, id := range results.Order {
		result := results.Results[id]
		row := []string{result.Student, btoa(result.CompileSuccess), fmt.Sprint(result.Score), util.StringSliceToPrettyString(result.Feedback)}
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
		util.Throw(err)
		cmd = exec.Command("javac", compilePath...)
	} else if language == "c++" {
		compilePath, err = filepath.Glob(dir + "/*.cpp")
		util.Throw(err)
		if wall {
			compilePath = append([]string{"-Wall"}, compilePath...)
			cmd = exec.Command("g++", compilePath...)
		} else {
			cmd = exec.Command("g++", compilePath...)
		}
	} else {
		fmt.Print("Compilation error, no language found")
	}
	cmd.Dir = dir
	compileErr := cmd.Run()
	// test if exit 0, aka successful compilation
	return compileErr == nil
}

// Run the compiled program in directory $dir with command-line args $args
func runCompiled(dir, args, language string, input []string, c chan string) {
	var cmd *exec.Cmd
	var err error
	os := runtime.GOOS
	if language == "java" {
		cmd = exec.Command("java", strings.Fields(args)...)
	} else if language == "c++" {
		if os == "windows" {
			cmd = exec.Command(".\\a.exe", strings.Fields(args)...)
		} else if os == "linux" || os == "darwin" {
			cmd = exec.Command("./a.out", strings.Fields(args)...)
		} else {
			panic("Error: OS is not compatible.")
		}
	}
	cmd.Dir = dir

	stdout, err := cmd.StdoutPipe()
	util.Throw(err)
	stdin, err := cmd.StdinPipe()
	util.Throw(err)

	cmdErr := cmd.Start()
	util.Throw(cmdErr)

	processInput(stdin, input)

	outputBuffer := new(bytes.Buffer)

	go func() {
		_, err := io.Copy(outputBuffer, stdout)
		util.Throw(err)
	}()

	waitErr := cmd.Wait()

	// ignore short write errors since this is expected
	if waitErr != nil && waitErr.Error() != "short write" {
		util.Throw(waitErr)
	}

	// Check subprocess exit code
	exitCode := cmd.ProcessState.ExitCode()
	fmt.Println("Exit code: ", exitCode)

	c <- outputBuffer.String()
}

func runInterpreted(dir, args, language string, input []string) string {
	var stdout CmdOutput
	var cmd *exec.Cmd
	if language == "js" || language == "javascript" {
		cmd = exec.Command("node", strings.Fields(args)...)
	} else if language == "python" || language == "python3" {
		cmd = exec.Command(language, strings.Fields(args)...) // ex: python3 main.py arg1 arg2 ... argN
	}
	cmd.Dir = dir
	cmd.Stdout = &stdout
	stdin, err := cmd.StdinPipe()
	util.Throw(err)

	cmdErr := cmd.Start()
	util.Throw(cmdErr)

	processInput(stdin, input)
	waitErr := cmd.Wait()

	// ignore short write errors since this is expected
	if waitErr != nil && waitErr.Error() != "short write" {
		panic(waitErr)
	}

	return string(stdout.savedOutput)
}

// Write provided input to stdin, line by line.
func processInput(stdin io.WriteCloser, input []string) {
	for _, command := range input {
		_, err := io.WriteString(stdin, command+"\n")
		util.Throw(err)
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
func parseFlags() (workDir, runArgs, outFile, language string, wall bool, isDryRun bool, server bool, assignmentId int) {
	flag.StringVar(&workDir, "directory", "/code", "student submissions directory")
	flag.StringVar(&runArgs, "args", "", "arguments to pass to compiled programs")
	flag.BoolVar(&wall, "Wall", true, "compile programs using -Wall")
	flag.StringVar(&outFile, "out", "report.csv", "file to write results to")
	flag.StringVar(&language, "lang", "", "Language to be tested")
	flag.BoolVar(&isDryRun, "dry-run", false, "skip upload to db")
	flag.BoolVar(&server, "server", false, "Run OpenGrader server instead of engine")
	flag.IntVar(&assignmentId, "assignment-id", 0, "Assignment ID to use, defaults to using oginfo.json")

	flag.Parse()

	return
}

// Generate a list of strings, each a line of user input.
func parseInFile(inFile string) (input []string) {
	if inFile != "" {
		input = strings.Split(util.GetFile(inFile), "\n")
	} else {
		input = []string{}
	}
	return
}

// Grade a single student's submission.
func gradeSubmission(result *util.SubmissionResult, dir, workDir, expected string, input []string, testNumber int, info util.AssignmentInfo) {
	result.Student = dir

	if info.Language == "python" || info.Language == "javascript" {
		result.CompileSuccess = true
		stdout := runInterpreted(filepath.Join(workDir, dir), info.Args, info.Language, input)

		result.Feedback[testNumber] = processOutput(expected, stdout)
	} else if info.Language == "c++" || info.Language == "java" {
		result.CompileSuccess = compile(filepath.Join(workDir, dir), info.Language, info.Wall)
		if result.CompileSuccess {
			c := make(chan string)
			go runCompiled(filepath.Join(workDir, dir), info.Args, info.Language, input, c)
			stdout := <-c
			result.Feedback[testNumber] = processOutput(expected, stdout)
		}
	} else {
		fmt.Print("No language found")
	}
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

func checkForZip(workDir string, dir string) {
	workDir = workDir + "/" + dir
	if err := os.Chdir(workDir); err != nil {
		panic(err)
	}

	cmd := exec.Command("ls", ".")

	output, err := cmd.Output()
	if err != nil {
		panic(err)
	}

	for _, file := range strings.Split(string(output), "\n") {
		if strings.Contains(file, ".zip") {
			zipPath := workDir + "/" + file
			if err := unzipDir(zipPath, workDir); err != nil {
				fmt.Printf("Error extracting %s: %s\n", zipPath, err)
			}
			// remove the zip file
			if err := os.Remove(zipPath); err != nil {
				fmt.Printf("Error removing %s: %s\n", zipPath, err)
			}
		}
	}
}

func unzipDir(zipPath string, outputDir string) error {
	// open the zip archive
	reader, err := zip.OpenReader(zipPath)
	if err != nil {
		return err
	}
	defer reader.Close()

	// extract each file in the archive
	for _, file := range reader.File {
		fmt.Printf("Extracting file: %s\n", file.Name)
		if err := extractFile(file, outputDir); err != nil {
			return err
		}
	}

	return nil
}
func extractFile(file *zip.File, outputDir string) error {
	// open the file in the archive
	rc, err := file.Open()
	if err != nil {
		return err
	}
	defer rc.Close()

	// create the output file in the output directory
	outputPath := filepath.Join(outputDir, file.Name)
	output, err := os.Create(outputPath)
	if err != nil {
		return err
	}
	defer output.Close()

	// write the file contents to the output file
	_, err = io.Copy(output, rc)
	if err != nil {
		return err
	}

	return nil
}

func main() {
	workDir, runArgs, outFile, language, wall, isDryRun, server, passedAssignmentId := parseFlags()
	if server {
		fmt.Println("=== API Started ===")
		Server()
		return
	}

	assignmentInfo := util.ParseAssignmentOgInfo(workDir + "/.spec/oginfo.json")

	// enforce flag precedence over oginfo file
	util.EnforceFlagPrecedence(&assignmentInfo, runArgs, outFile, language, wall, isDryRun, passedAssignmentId)

	if assignmentInfo.DryRun || isDryRun {
		fmt.Println("=== Dry run - output will not be uploaded to database ===")
	}
	envErr := godotenv.Load()
	util.Throw(envErr)

	supabase := initSupabase()

	cmd := exec.Command("ls")
	cmd.Dir = workDir

	out, _ := cmd.Output()
	dirs := strings.Fields(string(out[:]))
	// dirs holds the student files where zip files should be checked for

	var assignmentId int8
	// determine which assignment id to use, flag takes precedence over file
	if passedAssignmentId == 0 {
		if assignmentInfo.AssignmentId == 0 {
			assignmentId = 1
		} else {
			assignmentId = assignmentInfo.AssignmentId
		}
	} else {
		assignmentId = int8(passedAssignmentId)
	}

	var results util.SubmissionResults
	results.Results = make(map[string]*util.SubmissionResult)

	for _, dir := range dirs {
		var result util.SubmissionResult
		studentInfo := util.ParseStudentOgInfo(workDir + "/" + dir + "/oginfo.json")

		// Find any zips, unzip to current directory, then delete the zip
		checkForZip(workDir, dir)

		if studentInfo.StudentEuid != "" {
			result.Student = studentInfo.StudentEuid
		} else {
			result.Student = dir
		}

		results.Results[result.Student] = &result
		results.Order = append(results.Order, result.Student)

		result.AssignmentId = assignmentId
		// find hydratedStudent information from EUID (dirname)
		hydratedStudent := db.GetStudentByEuid(supabase, result.Student)
		// if student doesn't exist, commit to db
		if hydratedStudent.Id == 0 {
			hydratedStudent.Euid = result.Student

			if studentInfo.StudentEmail != "" {
				hydratedStudent.Email = studentInfo.StudentEmail
			} else {
				hydratedStudent.Email = fmt.Sprintf("%s@unt.edu", result.Student) // all students have euid@unt.edu
			}

			fmt.Printf("%8s: ", result.Student)
			fmt.Printf("%+v\n", hydratedStudent)

			if !assignmentInfo.DryRun {
				hydratedStudent.Save(supabase)
			}
		}

		result.StudentId = hydratedStudent.Id

		result.Feedback = make([]string, len(assignmentInfo.Tests))

		for i, test := range assignmentInfo.Tests {
			expected := util.GetFile(workDir + "/.spec/" + test.Expected)

			fmt.Printf("Test #%d Expected Output:\n%s\n\n", i+1, expected)

			var input = []string{}
			if test.Input != "" {
				input = parseInFile(workDir + "/.spec/" + test.Input)
			}

			gradeSubmission(&result, dir, workDir, expected, input, i, assignmentInfo)

			var testResult string
			if result.CompileSuccess && result.Feedback[i] == "" {
				testResult = "PASS"
			} else {
				testResult = "FAIL"
			}

			fmt.Printf("Test #%d Result:\n%s\n\n", i+1, testResult)

			if result.CompileSuccess && result.Feedback[i] != "" {
				fmt.Printf("Test #%d Feedback:\n%s\n\n", i+1, result.Feedback[i])
			}

			if !result.CompileSuccess {
				fmt.Printf("Test #%d Feedback:\nCompilation failed.\n\n", i+1)
			}

		}

		// If successfully compiled, calculate score. Otherwise, score is 0. Score is calculated by lack of feedback.
		// So, if something didn't compile, it would receive a score of 100 and we do not want that.
		if result.CompileSuccess {
			result.Score = int8(util.CalculateScore(result, assignmentInfo.Tests))
		}
	}
	for _, id := range results.Order {
		fmt.Printf("%s: [compileSuccess=%t] [Score=%d] \n", id, results.Results[id].CompileSuccess, results.Results[id].Score)

	}
	if !assignmentInfo.DryRun {
		writeFullOutputToDb(supabase, results)
	}
	createCsv(results, outFile)
}
