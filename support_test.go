package main

import (
	"fmt"
	"testing"
)

func TestExtractXValueTableDriven(t *testing.T) {
	var Tests = []struct {
		syntaxString 	string
		want 			int

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
		stdout 		[]string
		pos 		int
		x_value 	int
	}{
		{[]string{"Option 1", "Option 2", "Option 3", "Nonsense"}, 0, 3},
		{[]string{"Menu Title", "Enter 'D'", "Enter 'C'", "Enter 'B'", "Enter 'A'", "Prompt:"}, 1, 4},
		{[]string{"The only option!", }, 0, 2},
		{[]string{"Output", "Output", "OUTPUT", "Option 1", "Option 2", "Prompt?"}, 3, 3},
	}
	
	var TestResults = []struct {
		position 	int
		result		string
	}{
		{3, " Good menu"},
		{5, " Good menu"},
		{0, " No more output remaining"},
		{5, " Not enough menu options"},
	}
}

func TestHasPrompt (*testing.T) {

}