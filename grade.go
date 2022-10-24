package main

import (
	"encoding/csv"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/andreyvit/diff"
)

type cmdOutput struct {
	savedOutput []byte
}

type SubmissionResult struct {
	student        string
	compileSuccess bool
	runCorrect     bool
	diff           string
}

func (out *cmdOutput) Write(p []byte) (n int, err error) {
	out.savedOutput = append(out.savedOutput, p...)
	return 0, nil
}

func throw(e error) {
	if e != nil {
		panic(e)
	}
}

func getFile(fp string) string {
	data, err := os.ReadFile(fp)
	throw(err)
	return string(data)
}

func evaluateDiff(diff string) bool {
	for _, line := range strings.Split(diff, "\n") {
		if line[0] != ' ' {
			return false
		}
	}

	return true
}

func compare(expected, actual string) (bool, string) {
	d := diff.LineDiff(strings.TrimSpace(expected), strings.TrimSpace(actual))

	return evaluateDiff(d), d
}

func btoa(b bool) string {
	if b {
		return "true"
	}
	return "false"
}

func createCsv(results map[string]*SubmissionResult, outfile string) {
	file, err := os.Create(outfile)
	throw(err)

	writer := csv.NewWriter(file)
	writer.Write([]string{"student", "compiled", "ran correctly", "diff"})
	for _, result := range results {
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

func runCompiled(dir, args string) string {
	var stdout cmdOutput

	cmd := exec.Command("./a.out", strings.Fields(args)...)
	cmd.Dir = dir
	cmd.Stdout = &stdout

	cmd.Run()

	return string(stdout.savedOutput)
}

func main() {
	var workDir string
	var runArgs string
	var wall bool
	var outfile string
	flag.StringVar(&workDir, "directory", "/code", "student submissions directory")
	flag.StringVar(&runArgs, "args", "", "arguments to pass to compiled programs")
	flag.BoolVar(&wall, "Wall", true, "compile programs using -Wall")
	flag.StringVar(&outfile, "out", "report.csv", "file to write results to")

	flag.Parse()

	fmt.Println("workdir: ", workDir)

	cmd := exec.Command("ls")
	cmd.Dir = workDir

	out, _ := cmd.Output()
	dirs := strings.Fields(string(out[:]))

	expected := getFile(workDir + "/.spec/out.txt")
	fmt.Println(expected)

	var results map[string]*SubmissionResult
	results = make(map[string]*SubmissionResult)

	for _, dir := range dirs {
		var result SubmissionResult
		results[dir] = &result

		result.student = dir
		result.compileSuccess = compile(filepath.Join(workDir, dir), wall)

		if result.compileSuccess {
			stdout := runCompiled(filepath.Join(workDir, dir), runArgs)
			result.runCorrect, result.diff = compare(expected, stdout)
		}
	}

	for result := range results {
		fmt.Printf("%s: [compileSuccess=%t] [runCorrect=%t]\n", result, results[result].compileSuccess, results[result].runCorrect)
	}

	createCsv(results, outfile)
}
