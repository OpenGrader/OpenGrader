package util

import (
	"encoding/json"
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
}

type AssignmentInfo struct {
	AssignmentId int8   `json:"AssignmentId"`
	Tests        []Test `json:"Tests"`
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
func ParseOgInfo(path string) (info AssignmentInfo) {
	// manually reading file bc need to fail gracefully
	data, err := os.ReadFile(path)

	if err != nil {
		return
	}

	json.Unmarshal(data, &info)
	return
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
