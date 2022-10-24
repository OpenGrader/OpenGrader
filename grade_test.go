package main

import (
	"errors"
	"os"
	"path"
	"reflect"
	"strings"
	"testing"
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

	throw(sampleErr)
}

func TestGetFile(t *testing.T) {
	tmpFile, _ := os.CreateTemp("", "*")

	expected := "writing a string to test\nand another line of stuff\n"
	tmpFile.WriteString(expected)

	actual := getFile(tmpFile.Name())

	if actual != expected {
		t.Errorf("String returned by getFile did not match input string. [expected=%s] [actual=%s]", expected, actual)
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
	var res SubmissionResults
	res.results = make(map[string]*SubmissionResult)

	res.results["aaa0001"] = &SubmissionResult{"aaa0001", true, false, "<diff1>"}
	res.results["bbb0002"] = &SubmissionResult{"bbb0002", true, true, "<diff2>"}
	res.results["ccc0003"] = &SubmissionResult{"ccc0003", false, false, "<diff3>"}
	res.order = []string{"aaa0001", "bbb0002", "ccc0003"}

	tmp, _ := os.CreateTemp("", "*")
	tmp.Close()

	createCsv(res, tmp.Name())

	expected := `student,compiled,ran correctly,diff
aaa0001,true,false,<diff1>
bbb0002,true,true,<diff2>
ccc0003,false,false,<diff3>
`

	if actual := getFile(tmp.Name()); actual != expected {
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

	result := compile(dir, false)
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
	int main() { std::cout << "Hello world!" << std::endl; }`

	tmp, _ := os.CreateTemp("", "*.cpp")
	// Removes the created temp file, this will always run
	defer os.Remove(tmp.Name())

	tmp.WriteString(cpp)

	parts := strings.Split(tmp.Name(), "/")
	parts = parts[:len(parts)-1]

	dir := strings.Join(parts, "/")

	result := compile(dir, true)
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

	result := compile(dir, true)
	if result {
		t.Error("Compile returned true, expected false.")
	}

	compiled, err := os.Open(path.Join(dir, "a.out"))
	if err == nil {
		t.Errorf("Found a compiled file when compilation should have failed: %s", compiled.Name())
	}
}

func TestRunCompiled(t *testing.T) {
	cpp := `#include <iostream>
	int main() { std::cout << "Hello world!" << std::endl; }`

	tmp, _ := os.CreateTemp("", "*.cpp")
	// Removes the created temp file, this will always run
	defer os.Remove(tmp.Name())

	tmp.WriteString(cpp)

	parts := strings.Split(tmp.Name(), "/")
	parts = parts[:len(parts)-1]

	dir := strings.Join(parts, "/")

	result := compile(dir, true)
	if !result {
		t.Error("Compile returned false, expected true.")
	}

	defer os.Remove(path.Join(dir, "a.out"))

	_, err := os.Open(path.Join(dir, "a.out"))
	if err != nil {
		t.Errorf("Failed to open the compiled file: [err=%e]", err)
	}

	expected := "Hello world!\n"
	actual := runCompiled(dir, "")

	if expected != actual {
		t.Errorf("Expected text did not match actual [expected=%#v] [actual=%#v]", expected, actual)
	}
}
