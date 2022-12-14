package main

import (
	"strconv"
	"strings"
)

// Defining type of functions that will be used in the global syntax dictionary
type SDFunc func(string, []string, int) ([]string, int, []string)

// Global Syntax Dictionary that can be called in other functions
var SyntaxDictionary = map[string]SDFunc{
	"menu":   menuHandler,
	"ignore": ignoreHandler,
}

// Handler for !menu(x) keyword in spec file
func menuHandler(menuCall string, StdOutput []string, startPos int) ([]string, int, []string) {
	// Menu keyword comes in the form of !menu(x),
	// where x is a digit representing the number of options the menu should display.
	// Menus should resemble the following form (using x = 3):
	/*
		Title of the menu \n
		1. Option \n
		2. Option \n
		3. Option \n
		Prompt:
	*/
	// This shape can be simplified to following:
	/*
		title string
		x option strings between
		prompt string
	*/
	// Declare return variables
	var feedback []string
	var newPos int
	modifiedStdout := StdOutput

	// First, extract the value of x CONVERT
	x_value, err := extractXValue(menuCall)

	if err != nil || x_value < 1 {
		feedback = append(feedback, "Invalid menu parameter")
		return feedback, startPos, StdOutput
	}
	// Get current position in stdout
	curr := startPos

	// Now, evaluate the menu shape.
	// Check for title
	if StdOutput[curr] == "" {
		feedback = append(feedback, "No menu title") // Check failed
	}

	curr++

	var additionalFeedback string
	curr, additionalFeedback = hasMenuOptions(StdOutput, x_value, curr)
	if additionalFeedback != "" {
		feedback = append(feedback, additionalFeedback) // If there is feedback, append
	}

	// Check to see if curr exceeds bounds again
	if curr > len(StdOutput)-1 {
		feedback = append(feedback, "Position exceeds bounds")
		curr-- // Move curr back if it exceeds the bounds of StdOutput
		newPos = curr
		return feedback, newPos, modifiedStdout
	}

	var promptPassed bool
	promptPassed, modifiedStdout = hasPrompt(StdOutput, curr)

	if !promptPassed {
		feedback = append(feedback, "No prompt")
		curr--
	}

	// Finally, update new position with current
	newPos = curr

	return feedback, newPos, modifiedStdout
}

// Handler for !ignore keyword
func ignoreHandler(ignoreCall string, StdOutput []string, startPos int) ([]string, int, []string) {
	feedback := make([]string, 0)
	// Core functionality of ignore.... just skip da line

	return feedback, startPos, StdOutput
}

func extractXValue(s string) (int, error) {
	startIndex := strings.Index(s, "(") + 1        // index value of the first digit
	endIndex := strings.Index(s, ")")              // Index value of the right parantheses
	x, err := strconv.Atoi(s[startIndex:endIndex]) // substring from 1st digit to last digit
	return x, err
}

func hasMenuOptions(output []string, x_value, currPos int) (pos int, feedback string) {
	feedback = ""
	if len(output) == 1 {
		feedback = "Not a valid menu! Contains only 1 string."
		return 0, feedback
	}
	for i := 1; i <= x_value; i++ {
		if currPos > len(output)-1 {
			currPos-- // Move curr back if it exceeds the bounds of StdOutput
			feedback = "No more output remaining"
			return currPos, feedback
		}

		var earlyPromptFound bool
		earlyPromptFound, _ = hasPrompt(output, currPos)

		if earlyPromptFound {
			// fmt.Println("Early prompt")
			feedback = "Not enough menu options"
			break
		}

		currPos++
	}
	return currPos, feedback
}

func findTrailingPrompt(s string) bool {
	if strings.HasSuffix(strings.TrimSpace(s), ":") || strings.HasSuffix(strings.TrimSpace(s), "?") {
		return true
	} else {
		return false
	}
}

// Split a given string within a slice in two around a given character. First half of split remains in original slice position,
// while the second half is inserted after
func splitStringInSlice(slice []string, pos int, char string) []string {
	tempSlice := strings.SplitAfter(slice[pos], char)
	slice[pos] = tempSlice[0]
	return insertIntoStringSlice(slice, strings.TrimSpace(tempSlice[1]), pos+1)
}

// Insert a string into a string slice at position i
// following me implementation from https://github.com/golang/go/wiki/SliceTricks#Insert
func insertIntoStringSlice(slice []string, val string, i int) []string {
	slice = append(slice, "") // append empty value at end of string to make room for one more value
	copy(slice[i+1:], slice[i:])
	slice[i] = val
	return slice
}

func hasPrompt(Stdout []string, pos int) (bool, []string) {
	if findTrailingPrompt(Stdout[pos]) {
		return true, Stdout
	} else {
		// Search for that : or ? in there!
		// If there is no newline after the : stdout will begin printing right after the colon instead of on the next line
		if strings.Contains(strings.TrimSpace(Stdout[pos]), ":") {
			// Split the value that contains the prompt and r
			modifiedStdout := splitStringInSlice(Stdout, pos, ":")
			return true, modifiedStdout
		} else if strings.Contains(strings.TrimSpace(Stdout[pos]), "?") {
			modifiedStdout := splitStringInSlice(Stdout, pos, "?")
			return true, modifiedStdout
		} else {
			return false, Stdout
		}
	}
}
