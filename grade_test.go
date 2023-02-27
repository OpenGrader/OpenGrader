package main

import (
	"errors"
	"fmt"
	"os"
	"path"
	"path/filepath"
	"reflect"
	"strings"
	"testing"

	"github.com/OpenGrader/OpenGrader/util"
	"github.com/vulpine-io/io-test/v1/pkg/iotest"
)

func TestCmdOutputWrite(t *testing.T) {
	var out CmdOutput
	out.Write([]byte{48})
	out.Write([]byte{59})

	expected := []byte{48, 59}

	if l := len(out.savedOutput); l != len(expected) {
		t.Fatalf("Length of out.savedOutput incorrect [l=%d]", l)
	}

	if !reflect.DeepEqual(out.savedOutput, expected) {
		t.Fatalf("out.savedOutput does not deeply equal expected output [48, 59]: [savedOutput=%v]", out.savedOutput)
	}
}

func TestThrow(t *testing.T) {
	sampleErr := errors.New("Sample error")

	defer func() {
		if r := recover(); r == nil {
			t.Fatalf("The code did not panic")
		}
	}()

	util.Throw(sampleErr)
}

func TestGetFile(t *testing.T) {
	tmpFile, _ := os.CreateTemp("", "*")

	expected := "writing a string to test\nand another line of stuff\n"
	tmpFile.WriteString(expected)

	actual := util.GetFile(tmpFile.Name())

	if actual != expected {
		t.Errorf("String returned by util.GetFile did not match input string. [expected=%s] [actual=%s]", expected, actual)
	}

	os.Remove(tmpFile.Name())
}

func TestEvaluateDiffNoChanges(t *testing.T) {
	diff := " line 1\n line 2"

	if !evaluateDiff(diff) {
		t.Fatalf("evaluateDiff returned false, expected true")
	}
}

func TestEvaluateDiffChanges(t *testing.T) {
	diff := "+line 1\n-line 2"

	if evaluateDiff(diff) {
		t.Fatalf("evaluateDiff returned true, expected false")
	}
}

func TestCompareSameStringDiffWhitespace(t *testing.T) {
	expectedInput := "this is a string\nwith two lines " // add trailing whitespace
	actualInput := "this is a string\nwith two lines "   // no trailing whitespace, should still return equal

	res, diff := compare(expectedInput, actualInput)

	if !res {
		t.Fatalf("compare returned false, expected true [diff=%s]", diff)
	}
}

func TestCompareSameStringDiffNewline(t *testing.T) {
	expectedInput := "this is a string\nwith two lines\n" // add trailing newline
	actualInput := "this is a string\nwith two lines"     // no trailing newline, should still return equal

	res, diff := compare(expectedInput, actualInput)

	if !res {
		t.Fatalf("compare returned false, expected true [diff=%s]", diff)
	}
}

func TestCompareSameString(t *testing.T) {
	expectedInput := "this is a string\nwith two lines"
	actualInput := expectedInput // exact same string

	res, diff := compare(expectedInput, actualInput)

	if !res {
		t.Fatalf("compare returned false, expected true [diff=%s]", diff)
	}
}

func TestCompareDifferentStrings(t *testing.T) {
	expectedInput := "this is a string\nwith two lines"
	actualInput := "this is NOT a string\nwith three lines" // different string

	res, diff := compare(expectedInput, actualInput)

	if res {
		t.Fatalf("compare returned true, expected false [diff=%s]", diff)
	}
}

func TestBtoaFalse(t *testing.T) {
	if r := btoa(false); r != "false" {
		t.Fatalf("expected false, [r=%s]", r)
	}
}

func TestBtoaTrue(t *testing.T) {
	if r := btoa(true); r != "true" {
		t.Fatalf("expected true, [r=%s]", r)
	}
}

func TestCreateCsv(t *testing.T) {
	var res util.SubmissionResults
	res.Results = make(map[string]*util.SubmissionResult)

	res.Results["aaa0001"] = &util.SubmissionResult{Student: "aaa0001", CompileSuccess: true, RunCorrect: false, Feedback: "<diff1>", AssignmentId: int8(1), StudentId: int8(1)}
	res.Results["bbb0002"] = &util.SubmissionResult{Student: "bbb0002", CompileSuccess: true, RunCorrect: true, Feedback: "<diff2>", AssignmentId: 1, StudentId: 1}
	res.Results["ccc0003"] = &util.SubmissionResult{Student: "ccc0003", CompileSuccess: false, RunCorrect: false, Feedback: "<diff3>", AssignmentId: 1, StudentId: 1}
	res.Order = []string{"aaa0001", "bbb0002", "ccc0003"}

	tmp, _ := os.CreateTemp("", "*")
	defer os.Remove(tmp.Name())
	tmp.Close()

	createCsv(res, tmp.Name())

	expected := `student,compiled,ran correctly,feedback
aaa0001,true,false,<diff1>
bbb0002,true,true,<diff2>
ccc0003,false,false,<diff3>
`

	if actual := util.GetFile(tmp.Name()); actual != expected {
		t.Error("Output of createCsv does not match expected.")
		t.Errorf("Expected\n========\n%s\n========\n\n", expected)
		t.Errorf("Actual\n======\n%s\n======", actual)
	}
}

func TestCompile(t *testing.T) {
	cpp := `#include <iostream>
	int main() { std::cout << "Hello world!" << std::endl; }`

	tmp, _ := os.CreateTemp("", "*.cpp")
	// Removes the created temp file, this will always run
	defer os.Remove(tmp.Name())

	tmp.WriteString(cpp)

	parts := strings.Split(tmp.Name(), "/")
	parts = parts[:len(parts)-1]

	dir := strings.Join(parts, "/")
	dir, _ = filepath.Abs(dir)
	result := compile(dir, "c++", false)
	if !result {
		t.Error("Compile returned false, expected true.")
	}
	defer os.Remove(path.Join(dir, "a.out"))

	_, err := os.Open(path.Join(dir, "a.out"))
	if err != nil {
		t.Errorf("Failed to open the compiled file: [err=%e]", err)
	}
}

func TestCompileWallSuccess(t *testing.T) {
	cpp := `#include <iostream>
	int main() { std::cout << "Hello world!" << std::endl;
	return 0; }`

	tmp, _ := os.CreateTemp("", "*.cpp")
	// Removes the created temp file, this will always run
	defer os.Remove(tmp.Name())

	tmp.WriteString(cpp)

	parts := strings.Split(tmp.Name(), "/")
	parts = parts[:len(parts)-1]

	dir := strings.Join(parts, "/")
	result := compile(dir, "c++", true)
	if !result {
		t.Error("Compile returned false, expected true.")
	}

	defer os.Remove(path.Join(dir, "a.out"))

	_, err := os.Open(path.Join(dir, "a.out"))
	if err != nil {
		t.Errorf("Failed to open the compiled file: [err=%e]", err)
	}
}
func TestCompileWallFailure(t *testing.T) {
	cpp := `int main() { int tst; tst += 1 }`

	tmp, _ := os.CreateTemp("", "*.cpp")
	// Removes the created temp file, this will always run
	defer os.Remove(tmp.Name())

	tmp.WriteString(cpp)

	parts := strings.Split(tmp.Name(), "/")
	parts = parts[:len(parts)-1]

	dir := strings.Join(parts, "/")

	result := compile(dir, "c++", true)
	if result {
		t.Error("Compile returned true, expected false.")
	}

	compiled, err := os.Open(path.Join(dir, "a.out"))
	if err == nil {
		t.Errorf("Found a compiled file when compilation should have failed: %s", compiled.Name())
	}
}

func TestRunCompiled(t *testing.T) {
	cpp := `
	#include <iostream>
	using namespace std;
		int main(int argc, char** argv) {
    	cout << "Hello, C Plus Plus!" << endl;
    	return 0;
	}
	`

	tmp, _ := os.CreateTemp("", "*.cpp")
	// Removes the created temp file, this will always run
	defer os.Remove(tmp.Name())

	tmp.WriteString(cpp)
	parts := strings.Split(tmp.Name(), "/")
	parts = parts[:len(parts)-1]
	dir := strings.Join(parts, "/")

	result := compile(dir, "c++", false)
	if !result {
		t.Error("Compile returned false, expected true.")
	}

	defer os.Remove(path.Join(dir, "a.out"))

	_, err := os.Open(path.Join(dir, "a.out"))
	if err != nil {
		t.Errorf("Failed to open the compiled file: [err=%e]", err)
	}

	expected := "Hello, C Plus Plus!\n"
	actual := runCompiled(dir, tmp.Name(), "c++", []string{"Hello, C Plus Plus\n"})

	if expected != actual {
		t.Errorf("Expected text did not match actual [expected=%#v] [actual=%#v]", expected, actual)
	}
}

func TestRunInterpreted(t *testing.T) {
	js := `console.log("Hello, World!");`
	tmp, _ := os.CreateTemp("", "*.js")
	// Removes the created temp file, this will always run
	defer os.Remove(tmp.Name())

	tmp.WriteString(js)
	parts := strings.Split(tmp.Name(), "/")
	parts = parts[:len(parts)-1]

	dir := strings.Join(parts, "/")
	expected := "Hello, World!\n"
	actual := runInterpreted(dir, tmp.Name(), "javascript", []string{"Hello, World!"})
	if expected != actual {
		t.Errorf("Expected text did not match actual [expected=%#v] [actual=%#v]", expected, actual)
	}
}

func TestProcessInput(t *testing.T) {
	stdio := new(iotest.WriteCloser)

	input := []string{"hello", "world", "again"}
	processInput(stdio, input)

	expected := "hello\nworld\nagain\n"
	if actual := string(stdio.WrittenBytes[:]); actual != expected {
		t.Fatalf("Mismatched output. [expected=%#v] [actual=%#v]", expected, actual)
	}
}

func TestParseFlags(t *testing.T) {
	expectedWorkDir := "my/directory"
	expectedRunArgs := "--test --args -f"
	expectedOutFile := "my-outfile"
	expectedInFile := "my-infile"
	expectedWall := false
	expectedDryRun := false
	expectedServer := false
	expectedAssignmentId := 93

	os.Args = []string{"test", "--out", expectedOutFile, "--in", expectedInFile, "--Wall=false", "--directory", expectedWorkDir, "--args", expectedRunArgs, "--assignment-id", fmt.Sprint(expectedAssignmentId)}

	workDir, runArgs, outFile, inFile, _, wall, isDryRun, server, assignmentId := parseFlags()

	if workDir != expectedWorkDir {
		t.Errorf("Mismatched workDir [expected=%#v] [actual=%#v]", expectedWorkDir, workDir)
	}

	if runArgs != expectedRunArgs {
		t.Errorf("Mismatched runArgs [expected=%#v] [actual=%#v]", expectedRunArgs, runArgs)
	}

	if outFile != expectedOutFile {
		t.Errorf("Mismatched outFile [expected=%#v] [actual=%#v]", expectedOutFile, outFile)
	}

	if inFile != expectedInFile {
		t.Errorf("Mismatched inFile [expected=%#v] [actual=%#v]", expectedInFile, inFile)
	}

	if wall != expectedWall {
		t.Errorf("Mismatched wall [expected=%#v] [actual=%#v]", expectedWall, wall)
	}

	if isDryRun != expectedDryRun {
		t.Errorf("Mismatched isDryRun [expected=%#v] [actual=%#v]", expectedDryRun, isDryRun)
	}

	if server != expectedServer {
		t.Errorf("Mismatched server [expected=%#v] [actual=%#v]", expectedServer, server)
	}

	if assignmentId != expectedAssignmentId {
		t.Errorf("Mismatched assignmentId [expected=%#v] [actual=%#v]", expectedAssignmentId, assignmentId)
	}
}

func TestParseInFileWithInput(t *testing.T) {
	tmp, _ := os.CreateTemp("", "*.cpp")
	defer os.Remove(tmp.Name())

	tmp.Write([]byte("test\nmultiline \ninput\nfor\nprogram\n"))

	actual := parseInFile(tmp.Name())
	expected := []string{"test", "multiline ", "input", "for", "program", ""}
	defer os.Remove(tmp.Name())
	if len(expected) != len(actual) {
		t.Fatalf("len(expected) != len(actual). Received %d, want %d", len(actual), len(expected))
	}

	for i, received := range actual {
		if want := expected[i]; want != received {
			t.Errorf("Received %#v, want %#v", received, want)
		}
	}
}

func TestParseInFileWithoutInput(t *testing.T) {
	actual := parseInFile("")

	if len(actual) != 0 {
		t.Fatalf("len(actual) != 0, received %d (%#v)", len(actual), actual)
	}
}

// func TestGradeSubmission(t *testing.T) {
// 	// create temp directory in temp directory
// 	dir, err := os.MkdirTemp(os.TempDir(), "*")
// 	dirList := strings.Split(dir, "/")
// 	dir = dirList[len(dirList)-1]
// 	workDir := os.TempDir()

// 	// create c++ file
// 	os.Create(dir + "/main.cpp")
// 	p := path.Join(workDir, dir, "main.cpp")
// 	os.WriteFile(p, []byte(`#include <iostream>
// 	int main() { std::cout << "Hello World!"; return 0;}`), 0666)

// 	if err != nil {
// 		t.Fatalf("Failed to make temp dir %#v", err)
// 	}

// 	// run and validate
// 	runArgs := ""
// 	expected := "Hello World!\n"
// 	language := "c++"
// 	input := []string{""}
// 	wall := false
// 	result := util.SubmissionResult{Student: "jgg0144", CompileSuccess: false, RunCorrect: false, Feedback: "", AssignmentId: 1, StudentId: 1}

// 	gradeSubmission(&result, dir, workDir, runArgs, expected, language, input, wall)

// 	if !result.CompileSuccess {
// 		t.Fatalf("Compile error")
// 	}

// 	if result.Feedback != expected {
// 		t.Errorf("actual.diff mismatch, received %#v, want %#v", result., expected)
// 	}

// 	if !result.RunCorrect {
// 		t.Errorf("actual.runCorrect is false, want true")
// 	}

// 	if result.Student != dir {
// 		t.Errorf("actual.student mismatch, received %#v, want %#v", result.Student, dir)
// 	}
// }
