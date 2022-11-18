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
		{"!menu(2)", 2},
		{"!menu(3)", 3},
		{"!menu(4)", 4},
		{"!menu(5)", 5},
	}

	for _, tt := range Tests {
		testname := fmt.Sprintf("%s,%d", tt.syntaxString, tt.want)
		t.Run(testname, func(t *testing.T) {
			ans := extractXValue(tt.syntaxString)
			if ans != tt.want {
				t.Errorf("got %d want %d", ans, tt.want)
			}
		})
	}
}

func TestHasOptions(t *testing.T) {
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
			actualPos, actualResult := hasOptions(ti.stdout, ti.pos, ti.x_value)
			if actualPos != WantedResults[i].position {
				t.Errorf("Incorrect position. Wanted position %d and got %d", WantedResults[i].position, actualPos)
			}
			if actualResult != WantedResults[i].result {
				t.Errorf("Incorrect result. Wanted result \"%s\" and got \"%s\"", WantedResults[i].result, actualResult)
			}
		})
	}
}

func TestHasPrompt (t *testing.T) {
	var Tests = []struct {
		stdout 							[]string
		startPos						int
		wantResult					bool
		wantModifiedStdout	[]string
	}{
		{
			[]string{"A string","Another string","Menu Title","1","2","3","Prompt:","Output after"},
			6,
			true,
			[]string{"A string","Another string","Menu Title","1","2","3","Prompt:","Output after"},
		},
		{
			[]string{"1","2","3"},
			2,
			false,
			[]string{"1","2","3"},
		},
		{
			[]string{"Prompt? ","Following","3"},
			0,
			true,
			[]string{"Prompt? ","Following","3"},
		},
		{
			[]string{"Prompt:Output that was appended!","Following",},
			0,
			true,
			[]string{"Prompt:","Output that was appended!","Following",},
		},
	}

	for i, tt := range Tests {
		testname := fmt.Sprintf("TestHasPrompt#%d", i+1)
		t.Run(testname, func (t *testing.T)  {
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
