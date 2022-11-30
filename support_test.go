package main

import (
	"fmt"
	"testing"
)

func TestExtractXValueTableDriven(t *testing.T) {
	var Tests = []struct {
		syntaxString string
		want         int
	}{
		{"!menu(1)", 1},
		{"!menu(23091)", 23091},
		{"!menu(3)", 3},
		{"!menu(14)", 14},
		{"!menu(52)", 52},
	}

	for _, tt := range Tests {
		testname := fmt.Sprintf("%s,%d", tt.syntaxString, tt.want)
		t.Run(testname, func(t *testing.T) {
			ans, _ := extractXValue(tt.syntaxString)
			if ans != tt.want {
				t.Errorf("got %d want %d", ans, tt.want)
			}
		})
	}
}

func TestHasMenuOptions(t *testing.T) {
	var TestInput = []struct {
		stdout  []string
		pos     int
		x_value int
	}{
		{[]string{"Option 1", "Option 2", "Option 3", "Nonsense"}, 0, 3},
		{[]string{"Menu Title", "Enter 'D'", "Enter 'C'", "Enter 'B'", "Enter 'A'", "Prompt:"}, 1, 4},
		{[]string{"The only option!"}, 0, 2},
		{[]string{"Output", "Output", "OUTPUT", "Option 1", "Option 2", "Prompt?"}, 3, 3},
	}

	var WantedResults = []struct {
		position int
		result   string
	}{
		{3, " Good menu"},
		{5, " Good menu"},
		{0, " Not a valid menu! Contains only 1 string."},
		{5, " Not enough menu options"},
	}

	for i, ti := range TestInput {
		testname := fmt.Sprintf("hasOptionsTest%d", (i + 1))
		t.Run(testname, func(t *testing.T) {
			actualPos, actualResult := hasMenuOptions(ti.stdout, ti.pos, ti.x_value)
			if actualPos != WantedResults[i].position {
				t.Errorf("Incorrect position. Wanted position %d and got %d", WantedResults[i].position, actualPos)
			}
			if actualResult != WantedResults[i].result {
				t.Errorf("Incorrect result. Wanted result \"%s\" and got \"%s\"", WantedResults[i].result, actualResult)
			}
		})
	}
}

func TestHasPrompt(t *testing.T) {
	var Tests = []struct {
		stdout             []string
		startPos           int
		wantResult         bool
		wantModifiedStdout []string
	}{
		{
			[]string{"A string", "Another string", "Menu Title", "1", "2", "3", "Prompt:", "Output after"},
			6,
			true,
			[]string{"A string", "Another string", "Menu Title", "1", "2", "3", "Prompt:", "Output after"},
		},
		{
			[]string{"1", "2", "3"},
			2,
			false,
			[]string{"1", "2", "3"},
		},
		{
			[]string{"Prompt? ", "Following", "3"},
			0,
			true,
			[]string{"Prompt? ", "Following", "3"},
		},
		{
			[]string{"Prompt:Output that was appended!", "Following"},
			0,
			true,
			[]string{"Prompt:", "Output that was appended!", "Following"},
		},
	}

	for i, tt := range Tests {
		testname := fmt.Sprintf("TestHasPrompt#%d", i+1)
		t.Run(testname, func(t *testing.T) {
			result, modifiedStdout := hasPrompt(tt.stdout, tt.startPos)

			if result != tt.wantResult {
				t.Errorf("Wanted result of %v got %v", tt.wantResult, result)
			}

			if len(modifiedStdout) != len(tt.wantModifiedStdout) {
				t.Errorf("Wanted %v got %v", tt.wantModifiedStdout, modifiedStdout)
			}

			// Compare values of slices
			for i, v := range modifiedStdout {
				if v != tt.wantModifiedStdout[i] {
					t.Errorf("Wanted %v got %v", tt.wantModifiedStdout, modifiedStdout)
				}
			}
		})
	}
}

func TestMenuWrapper(t *testing.T) {
	var Tests = []struct {
		// (menuCall string, StdOutput []string, startPos int) (string, int, []string)
		menuCall      string
		Stdout        []string
		startPos      int
		wantFeedback  string
		wantEndPos    int
		wantModStdout []string
	}{
		{ // Test 1
			"!menu(3)",
			[]string{
				"Title",
				"Op1",
				"Op2",
				"Prompt:",
				"more output",
			},
			0,
			" Not enough menu options",
			3,
			[]string{
				"Title",
				"Op1",
				"Op2",
				"Prompt:",
				"more output",
			},
		},
		{ // Test 2
			"!menu(0)",
			[]string{
				"string",
				"string",
				"string",
			},
			1,
			"Invalid menu parameter",
			1,
			[]string{
				"string",
				"string",
				"string",
			},
		},
		{ // Test 3
			"!menu(2)",
			[]string{
				"",
				"O1",
				"O2",
				"P:",
				"more",
			},
			0,
			"No title Good menu",
			3,
			[]string{
				"",
				"O1",
				"O2",
				"P:",
				"more",
			},
		},
		{ // Test 4
			"!menu(2)",
			[]string{
				"Output before the menu",
				"Menu title",
				"Op 1",
				"Op 2",
				"Prompt?Output got printed here!",
				"more extraneous output",
			},
			1,
			" Good menu",
			4,
			[]string{
				"Output before the menu",
				"Menu title",
				"Op 1",
				"Op 2",
				"Prompt?",
				"Output got printed here!",
				"more extraneous output",
			},
		},
	}

	for i, tt := range Tests {
		testname := fmt.Sprintf("menuWrapperTest%d", i)

		t.Run(testname, func(t *testing.T) {
			feedback, endPos, modifiedStdout := menuWrapper(tt.menuCall, tt.Stdout, tt.startPos)

			if feedback != tt.wantFeedback {
				t.Errorf("Wanted feedback of %v got %v", tt.wantFeedback, feedback)
			}

			if endPos != tt.wantEndPos {
				t.Errorf("Wanted endPos of %v got %v", tt.wantEndPos, endPos)
			}

			for i, v := range modifiedStdout {
				if v != tt.wantModStdout[i] {
					t.Errorf("Wanted %v got %v", tt.wantModStdout, modifiedStdout)
				}
			}
		})
	}
}

func TestIgnoreWrapper(t *testing.T) {
	var Tests = []struct {
		// (menuCall string, StdOutput []string, startPos int) (string, int, []string)
		ignoreCall    string
		Stdout        []string
		startPos      int
		wantFeedback  string
		wantEndPos    int
		wantModStdout []string
	}{
		{ // Test 1
			"!ignore",
			[]string{
				"Hello",
				"!ignore",
				"1",
				"2",
			},
			1,
			"Output ignored",
			1,
			[]string{
				"Hello",
				"!ignore",
				"1",
				"2",
			},
		},
		{ // Test 2
			"!ignore",
			[]string{
				"!ignore",
				"Hello",
			},
			0,
			"Output ignored",
			0,
			[]string{
				"!ignore",
				"Hello",
			},
		},
	}

	for i, tt := range Tests {
		testname := fmt.Sprintf("ignoreWrapperTest%d", i)

		t.Run(testname, func(t *testing.T) {
			feedback, endPos, modifiedStdout := ignoreWrapper(tt.ignoreCall, tt.Stdout, tt.startPos)

			if feedback != tt.wantFeedback {
				t.Errorf("Wanted feedback of %v got %v", tt.wantFeedback, feedback)
			}

			if endPos != tt.wantEndPos {
				t.Errorf("Wanted endPos of %v got %v", tt.wantEndPos, endPos)
			}

			for i, v := range modifiedStdout {
				if v != tt.wantModStdout[i] {
					t.Errorf("Wanted %v got %v", tt.wantModStdout, modifiedStdout)
				}
			}
		})
	}

}

func TestInsertIntoStringSlice(t *testing.T) {
	var Tests = []struct {
		// (slice []string, val string, i int) ([]string)
		slice []string
		val   string
		i     int
		want  []string
	}{
		{
			[]string{
				"test",
				"test",
				"test",
			},
			"taste",
			1,
			[]string{
				"test",
				"taste",
				"test",
				"test",
			},
		},
		{
			[]string{
				"0",
				"1",
				"2",
				"3",
				"5",
			},
			"4",
			4,
			[]string{
				"0",
				"1",
				"2",
				"3",
				"4",
				"5",
			},
		},
		{
			[]string{
				"Fizz",
				"Ah",
			},
			"Buzz",
			1,
			[]string{
				"Fizz",
				"Buzz",
				"Ah",
			},
		},
	}

	for i, tt := range Tests {
		testname := fmt.Sprintf("insertIntoStringTest%d", i)

		t.Run(testname, func(t *testing.T) {
			actual := insertIntoStringSlice(tt.slice, tt.val, tt.i)
			for i, v := range actual {
				if v != tt.want[i] {
					t.Errorf("Wanted %v got %v", tt.want, actual)
				}
			}
		})
	}
}

func TestSplitStringInSlice(t *testing.T) {
	var Tests = []struct {
		// (slice []string, pos int, char string) ([]string )
		slice []string
		pos   int
		char  string
		want  []string
	}{
		{
			[]string{
				"test",
				"test",
				"test",
			},
			2,
			"e",
			[]string{
				"test",
				"test",
				"te",
				"st",
			},
		},
		{
			[]string{
				"Output",
				"Menu",
				"Op1",
				"Op2",
				"Prompt:AHHH BAD OUTPUT",
				"More output",
			},
			4,
			":",
			[]string{
				"Output",
				"Menu",
				"Op1",
				"Op2",
				"Prompt:",
				"AHHH BAD OUTPUT",
				"More output",
			},
		},
		{
			[]string{
				"Output",
				"Menu",
				"Op1",
				"Op2",
				"Op3",
				"Prompt?AHHH BAD OUTPUT",
			},
			5,
			"?",
			[]string{
				"Output",
				"Menu",
				"Op1",
				"Op2",
				"Op3",
				"Prompt?",
				"AHHH BAD OUTPUT",
			},
		},
	}

	for i, tt := range Tests {
		testname := fmt.Sprintf("splitStringInSliceTest%d", i)

		t.Run(testname, func(t *testing.T) {
			actual := splitStringInSlice(tt.slice, tt.pos, tt.char)
			for i, v := range actual {
				if v != tt.want[i] {
					t.Errorf("Wanted %v got %v", tt.want, actual)
				}
			}
		})
	}
}
