package util

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
