package util

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"strings"
)

// Collection of submission results. Includes an order array to indicate the order of items in the
// internal map.
type SubmissionResults struct {
	Results map[string]*SubmissionResult
	Order   []string
}

// Record of a student's submission, with metadata about how it ran and compiled.
type SubmissionResult struct {
	Student        string
	CompileSuccess bool
	Score          int8
	Feedback       []string
	AssignmentId   int8
	StudentId      int8
}

type Test struct {
	Expected string `json:"Expected"`
	Input    string `json:"Input"`
	Weight   int8   `json:"Weight"`
	Open     bool   `json:"Open"`
}

type AssignmentInfo struct {
	AssignmentId int8   `json:"AssignmentId"`
	Args         string `json:"Args"`
	DryRun       bool   `json:"DryRun"`
	Language     string `json:"Language"`
	OutputFile   string `json:"OutputFile"`
	Wall         bool   `json:"Wall"`
	Tests        []Test `json:"Tests"`
}

type StudentInfo struct {
	StudentEuid  string `json:"StudentEuid"`
	StudentName  string `json:"StudentName"`
	StudentEmail string `json:"StudentEmail"`
}

func CalculateScore(result SubmissionResult, tests []Test) (score int) {
	var scorePossible int = 0
	var scoreEarned int = 0
	for i, feedback := range result.Feedback {
		scorePossible += int(tests[i].Weight)
		if feedback == "" {
			scoreEarned += int(tests[i].Weight)
		}
	}

	score = int((float64(scoreEarned) / float64(scorePossible)) * 100)
	return
}

// Crash if an error is present
func Throw(e error) {
	if e != nil {
		panic(e)
	}
}

// Load a file $fp into memory
func GetFile(fp string) string {
	data, err := os.ReadFile(fp)
	Throw(err)
	return string(data)
}

// Parse the oginfo.json file into the AssignmentInfo struct
func ParseAssignmentOgInfo(path string) (info AssignmentInfo) {
	// manually reading file bc need to fail gracefully
	data, err := os.ReadFile(path)

	if err != nil {
		return
	}

	unmarshalErr := json.Unmarshal(data, &info)
	Throw(unmarshalErr)

	return
}

// Parse the oginfo.json file into the StudentInfo struct
func ParseStudentOgInfo(path string) (info StudentInfo) {
	// manually reading file bc need to fail gracefully
	data, err := os.ReadFile(path)

	if err != nil {
		return
	}

	unmarshalErr := json.Unmarshal(data, &info)
	Throw(unmarshalErr)

	return
}

func EnforceFlagPrecedence(info *AssignmentInfo, runArgs, outFile, language string, wall, isDryRun bool, assignmentId int) {
	if isFlagPassed("args") {
		fmt.Println("args passed")
		info.Args = runArgs
	}

	if isFlagPassed("out") {
		fmt.Println("out passed")
		info.OutputFile = outFile
	}

	if isFlagPassed("lang") {
		fmt.Println("lang passed")
		info.Language = language
	}

	if isFlagPassed("Wall") {
		fmt.Println("Wall passed")
		info.Wall = wall
	}

	if isFlagPassed("dry-run") {
		fmt.Println("dry-run passed")
		info.DryRun = isDryRun
	}

	if isFlagPassed("assignment-id") {
		fmt.Println("assignment-id passed")
		info.AssignmentId = int8(assignmentId)
	}
}

// helper method to check if a flag has been passed | src: https://stackoverflow.com/questions/35809252/check-if-flag-was-provided-in-go
func isFlagPassed(name string) bool {
	found := false
	flag.Visit(func(f *flag.Flag) {
		if f.Name == name {
			found = true
		}
	})
	return found
}

// Helper method to turn string slice into a readable, new line separated string that will print well in the report
func StringSliceToPrettyString(input []string) string {
	var output string = ""
	for _, str := range input {
		if str != "" {
			output += fmt.Sprintf("%s\n", str)
		}
	}
	return strings.TrimSpace(output)
}
