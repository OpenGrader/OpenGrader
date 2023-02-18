package util

import (
	"errors"
	"fmt"
	"os"
	"testing"
)

// Write unit tests for the util package.

func TestCalculateScore(t *testing.T) {
	var tests = []struct {
		result SubmissionResult
		want   int
	}{
		{
			SubmissionResult{
				CompileSuccess: true,
				RunCorrect:     true,
			},
			100,
		},
		{
			SubmissionResult{
				CompileSuccess: false,
				RunCorrect:     true,
			},
			50,
		},
		{
			SubmissionResult{
				CompileSuccess: true,
				RunCorrect:     false,
			},
			50,
		},
		{
			SubmissionResult{
				CompileSuccess: false,
				RunCorrect:     false,
			},
			0,
		},
	}

	for _, test := range tests {
		t.Run("TestCalculateScore", func(t *testing.T) {
			if got := CalculateScore(test.result); got != test.want {
				t.Errorf("CalculateScore(%v) = %v, want %v", test.result, got, test.want)
			}
		})
	}
}

func TestThrow(t *testing.T) {
	var tests = []struct {
		e    error
		want bool
	}{
		{
			nil,
			false,
		},
		{
			&os.PathError{Op: "open", Path: "test", Err: errors.New("test error")},
			true,
		},
	}

	for _, test := range tests {
		t.Run("TestThrow", func(t *testing.T) {
			defer func() {
				if r := recover(); r == nil && test.want {
					t.Errorf("Throw(%v) did not throw", test.e)
				}
			}()
			Throw(test.e)
		})
	}
}

func TestGetFile(t *testing.T) {
	var tests = []struct {
		fp   string
		want string
	}{
		{
			"test.txt",
			"test",
		},
		{
			"test2.txt",
			"test2",
		},
	}

	for _, test := range tests {
		t.Run("TestGetFile", func(t *testing.T) {
			target, _ := os.CreateTemp("", test.fp)
			defer os.Remove(target.Name())

			os.WriteFile(target.Name(), []byte(test.want), os.ModeAppend)

			if got := GetFile(target.Name()); got != test.want {
				t.Errorf("GetFile(%v) = %v, want %v", test.fp, got, test.want)
			}
		})
	}
}

func TestParseOgInfo(t *testing.T) {
	var tests = []struct {
		path string
		want AssignmentInfo
	}{
		{
			"test.json",
			AssignmentInfo{
				AssignmentId: 1,
			},
		},
		{
			"test2.json",
			AssignmentInfo{
				AssignmentId: 2,
			},
		},
	}

	for _, test := range tests {
		t.Run("TestParseOgInfo", func(t *testing.T) {
			target, _ := os.CreateTemp("", test.path)
			defer os.Remove(target.Name())

			os.WriteFile(target.Name(), []byte(fmt.Sprintf(`{"assignmentId": %d}`, test.want.AssignmentId)), os.ModeAppend)

			if got := ParseOgInfo(target.Name()); got != test.want {
				t.Errorf("ParseOgInfo(%v) = %v, want %v", test.path, got, test.want)
			}
		})
	}
}
