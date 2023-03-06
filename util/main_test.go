package util

import (
	"errors"
	"os"
	"testing"
)

// Write unit tests for the util package.

func TestCalculateScore(t *testing.T) {
	// Test cases for CalculateScore
	var tests = []struct {
		result SubmissionResult
		tests  []Test
		want   int
	}{
		{
			SubmissionResult{
				Student:        "test",
				CompileSuccess: true,
				Score:          0,
				Feedback:       []string{"", ""},
				AssignmentId:   1,
				StudentId:      1,
			},
			[]Test{
				{
					Expected: "test",
					Input:    "test",
					Weight:   1,
				},
				{
					Expected: "test",
					Input:    "test",
					Weight:   1,
				},
			},
			100,
		},
		{
			SubmissionResult{
				Student:        "test",
				CompileSuccess: true,
				Score:        0,	
				Feedback:     []string{"", "test"},
				AssignmentId: 1,
				StudentId:    1,
			},
			[]Test{	
				{
					Expected: "test",
					Input:    "test",
					Weight:   1,
				},
				{
					Expected: "test",
					Input:    "test",
					Weight:   1,
				},
			},
			50,
		},
	}

	for _, test := range tests {
		t.Run("TestCalculateScore", func(t *testing.T) {
			if got := CalculateScore(test.result, test.tests); got != test.want {
				t.Errorf("CalculateScore(%v, %v) = %v, want %v", test.result, test.tests, got, test.want)
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

func TestParseAssignmentOgInfo(t *testing.T) {

	var want = AssignmentInfo{
		AssignmentId: 1,
		Args: "",
		DryRun: true,
		Language: "c++",
		OutputFile: "Report1.csv",
		Wall: false,
		Tests: []Test{
			{
				Expected: "test1/out.txt",
				Input: "test1/in.txt",
				Weight: 50,
				Open: true,
			},
			{
				Expected: "test2/out.txt",
				Input: "test2/in.txt",
				Weight: 10,
				Open: false,
			},
			{
				Expected: "test3/out.txt",
				Input: "test3/in.txt",
				Weight: 15,
				Open: false,
			},
			{
				Expected: "test4/out.txt",
				Input: "test4/in.txt",
				Weight: 25,
				Open: true,
			},
		},
	}

	oginfo := `{
		"AssignmentId": 1,
		"Args": "",
		"DryRun": true,
		"Language": "c++",
		"OutputFile": "Report1.csv",
		"Wall": false,
		"Tests": [
			{
				"Expected": "test1/out.txt",
				"Input": "test1/in.txt",
				"Weight": 50,
				"Open": true
			},
			{
				"Expected": "test2/out.txt",
				"Input": "test2/in.txt",
				"Weight": 10,
				"Open": false
			},
			{
				"Expected": "test3/out.txt",
				"Input": "test3/in.txt",
				"Weight": 15,
				"Open": false
			},
			{
				"Expected": "test4/out.txt",
				"Input": "test4/in.txt",
				"Weight": 25,
				"Open": true
			} 
		]
	}`

	tmp, _ := os.CreateTemp("", "test.json")
	defer os.Remove(tmp.Name())

	os.WriteFile(tmp.Name(), []byte(oginfo), os.ModeAppend)
	
	got := ParseAssignmentOgInfo(tmp.Name())

	if got.AssignmentId != want.AssignmentId {
		t.Errorf("ParseOgInfo(%v) = %v, want %v", tmp.Name(), got, want)
	}

	if got.DryRun != want.DryRun {
		t.Errorf("ParseOgInfo(%v) = %v, want %v", tmp.Name(), got, want)
	}

	if got.Args != want.Args {
		t.Errorf("ParseOgInfo(%v) = %v, want %v", tmp.Name(), got, want)
	}

	if got.Language != want.Language {
		t.Errorf("ParseOgInfo(%v) = %v, want %v", tmp.Name(), got, want)
	}

	if got.OutputFile != want.OutputFile {
		t.Errorf("ParseOgInfo(%v) = %v, want %v", tmp.Name(), got, want)
	}

	if got.Wall != want.Wall {
		t.Errorf("ParseOgInfo(%v) = %v, want %v", tmp.Name(), got, want)
	}

	for i := range got.Tests {
		if got.Tests[i].Expected != want.Tests[i].Expected {
			t.Errorf("ParseOgInfo(%v) = %v, want %v", tmp.Name(), got, want)
		}
		if got.Tests[i].Input != want.Tests[i].Input {
			t.Errorf("ParseOgInfo(%v) = %v, want %v", tmp.Name(), got, want)
		}
		if got.Tests[i].Weight != want.Tests[i].Weight {
			t.Errorf("ParseOgInfo(%v) = %v, want %v", tmp.Name(), got, want)
		}
		if got.Tests[i].Open != want.Tests[i].Open {
			t.Errorf("ParseOgInfo(%v) = %v, want %v", tmp.Name(), got, want)
		}
	}

}

func TestParseStudentInfo(t *testing.T) {
	var want = StudentInfo{
		StudentEuid: "jjd1234",
		StudentName: "John Doe",
		StudentEmail: "JohnDoe@my.unt.edu",
	}

	studentinfo := `{
		"StudentEuid": "jjd1234",
		"StudentName": "John Doe",
		"StudentEmail": "JohnDoe@my.unt.edu"
	}`

	tmp, _ := os.CreateTemp("", "test.json")
	defer os.Remove(tmp.Name())

	os.WriteFile(tmp.Name(), []byte(studentinfo), os.ModeAppend)

	got := ParseStudentOgInfo(tmp.Name())

	if got.StudentEuid != want.StudentEuid {
		t.Errorf("ParseOgInfo(%v) = %v, want %v", tmp.Name(), got, want)
	}

	if got.StudentName != want.StudentName {
		t.Errorf("ParseOgInfo(%v) = %v, want %v", tmp.Name(), got, want)
	}

	if got.StudentEmail != want.StudentEmail {
		t.Errorf("ParseOgInfo(%v) = %v, want %v", tmp.Name(), got, want)
	}

}