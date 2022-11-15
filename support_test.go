package main

import (
	"fmt"
	// "strings"
	"testing"
)

func TestExtractXValueTableDriven(t *testing.T) {
	var tests = []struct {
		syntaxString string
		want int

	}{
		{"!menu(1)", 1},
		{"!menu(2)", 2},
		{"!menu(3)", 3},
		{"!menu(4)", 4},
		{"!menu(5)", 5},
	}

	for _, tt := range tests {
		testname := fmt.Sprintf("%s,%d", tt.syntaxString, tt.want)
		t.Run(testname, func(t *testing.T) {
			ans := extractXValue(tt.syntaxString)
			if ans != tt.want {
				t.Errorf("got %d want %d", ans, tt.want)
			}
		})
	}
}