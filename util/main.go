package util

import (
	"encoding/json"
	"os"
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
	RunCorrect     bool
	Feedback       string
	AssignmentId   int8
	StudentId      int8
}

type AssignmentInfo struct {
	AssignmentId int8
}

func CalculateScore(result SubmissionResult) (score int) {
	if result.CompileSuccess {
		score += 50
	}
	if result.RunCorrect {
		score += 50
	}
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
