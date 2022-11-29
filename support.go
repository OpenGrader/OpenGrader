package main

import (
	"strconv"
	"strings"
)

// Returns the Syntax Dictionary that maps keywords to functions that handle the processing of their output.
// The functions will each accept a string, a string slice, and an integer
// The string will be the line from out.txt that calls the custom syntax, this is so any necessary parameters can be extracted out.
// The string slice is the slice containing all of the lines output to stdout
// The integer will be the current position in the above slice that the grader is in
// Furthermore, the functions will return two integer values.
// The first integer represents the result score, which will hold either 1 or 0.
// The second integer will be the new position in the slice containing stdout
func initSyntaxDictionary() map[string]func(string, []string, int) (string, int, []string) {
	SyntaxDictionary := make(map[string]func(string, []string, int) (string, int, []string))

	SyntaxDictionary["menu"] = func(menuCall string, StdOutput []string, startPos int) (string, int, []string) {
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
			string
			string leading with 2
			string leading with 1
			string leading with 3
			string ending with :
		*/
		// Declare return variables
		var feedback string = ""
		var newPos int
		modifiedStdout := StdOutput

		// First, extract the value of x CONVERT
		x_value, err := extractXValue(menuCall)

		if err != nil || x_value < 1 {
			return "Invalid menu parameter", startPos, StdOutput
		}
		// Get current position in stdout
		curr := startPos

		// Now, evaluate the menu shape.
		// Check for title
		if StdOutput[curr] == "" {
			feedback = "No title" // Check failed
		}

		curr++

		if feedback != "" {
			var additionalFeedback string
			curr, additionalFeedback = hasOptions(StdOutput, x_value, curr)
			feedback += additionalFeedback
		} else {
			curr, feedback = hasOptions(StdOutput, x_value, curr)
		}

		// Check to see if curr exceeds bounds again
		if curr > len(StdOutput)-1 {
			feedback += "Position exceeds bounds"
			curr-- // Move curr back if it exceeds the bounds of StdOutput
			newPos = curr
			return feedback, newPos, modifiedStdout
		}

		var promptPassed bool
		promptPassed, modifiedStdout = hasPrompt(StdOutput, curr)

		if !promptPassed {
			feedback += " No prompt"
			curr--
		}

		// Finally, update new position with current
		newPos = curr

		return feedback, newPos, modifiedStdout
	}

	SyntaxDictionary["ignore"] = func(ignoreCall string, StdOutput []string, startPos int) (string, int, []string) {
		var feedback string = "Output ignored"
		// Core functionality of ignore.... just skip da line

		return feedback, startPos, StdOutput
	}
	return SyntaxDictionary
}

func extractXValue(s string) (int, error) {
	startIndex := strings.Index(s, "(") + 1
	endIndex := strings.Index(s, ")")
	x, err := strconv.Atoi(s[startIndex:endIndex])
	return x, err
}

func hasOptions(output []string, x_value, currPos int) (pos int, pass string) {
	pass = " Good menu"
	if len(output) == 1 {
		pass = " Not a valid menu! Contains only 1 string."
		return 0, pass
	}
	for i := 1; i <= x_value; i++ {
		if currPos > len(output)-1 {
			currPos-- // Move curr back if it exceeds the bounds of StdOutput
			pass = " No more output remaining"
			return currPos, pass
		}

		var earlyPromptFound bool
		earlyPromptFound, _ = hasPrompt(output, currPos)

		if earlyPromptFound {
			// fmt.Println("Early prompt")
			pass = " Not enough menu options"
			break
		}

		currPos++
	}
	return currPos, pass
}

func findTrailingPrompt(s string) (bool) {
	if strings.HasSuffix(strings.TrimSpace(s), ":") || strings.HasSuffix(strings.TrimSpace(s), "?") {
		return true
	} else {
		return false
	}
}

// Split a given string within a slice in two around a given character. First half of split remains in original slice position,
// while the second half is inserted after
func splitStringInSlice(slice []string, pos int, char string)  ([]string) {
	tempSlice := strings.SplitAfter(slice[pos], char) 
	slice[pos] = tempSlice[0]
	return insertIntoStringSlice(slice, strings.TrimSpace(tempSlice[1]), pos + 1)
}

// Insert a string into a string slice at position i
// following me implementation from https://github.com/golang/go/wiki/SliceTricks#Insert 
func insertIntoStringSlice(slice []string, val string, i int) ([]string) {
	slice = append(slice, "") // append empty value at end of string to make room for one more value
	copy(slice[i+1:], slice[i:])
	slice[i] = val
	return slice
}

func hasPrompt(Stdout []string, pos int) ( bool, []string) {
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

// Function that initializes the syntax dictionary and calls the menu function w given parameters.
// Solely for unit tests.
func menuWrapper(menuCall string, StdOutput []string, startPos int) (string, int, []string) {
	SyntaxDictionary := initSyntaxDictionary()
	return SyntaxDictionary["menu"](menuCall, StdOutput, startPos)
}

// Function that initializes the syntax dictionary and calls the ignore function w given parameters
// Solely for unit tests.
func ignoreWrapper(ignoreCall string, StdOutput []string, startPos int) (string, int, []string) {
	SyntaxDictionary := initSyntaxDictionary()
	return SyntaxDictionary["ignore"](ignoreCall, StdOutput, startPos)
}
