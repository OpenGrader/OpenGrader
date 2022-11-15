package main

import (
	"fmt"
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

	SyntaxDictionary["menu"] = func(expectedOutputLine string, StdOutputLines []string, startingPosInStdOuput int) (result string, newPositionInStdOutput int, modifiedStdout []string) {
		// Menu keyword comes in the form of !menu(x), where x is a digit representing the number of options the menu should display.
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

		// Set modifiedStdout equal to StdOutputLines
		modifiedStdout = StdOutputLines

		// Initially give result a passing value of 1, will be changed to 0 if it fails any of the following checks.
		result = "good menu...for now"

		// First, extract the value of x CONVERT
		x_value := extractXValue(expectedOutputLine)

		// Get current position in stdout
		curr := startingPosInStdOuput

		// Now, evaluate the menu shape.
		// Check for title
		if StdOutputLines[curr] == "" {
			fmt.Println("Check for title failed")
			result = "No title" // Check failed
		}

		curr++

		curr, result = hasOptions(StdOutputLines, x_value, curr)

		// Check to see if curr exceeds bounds again
		if curr > len(StdOutputLines)-1 {
			result = "Position exceeds bounds"
			curr-- // Move curr back if it exceeds the bounds of StdOutputLines
			newPositionInStdOutput = curr
			return
		}

		var promptPassed bool
		promptPassed, modifiedStdout = hasPrompt(StdOutputLines, curr)

		if !promptPassed {
			result = " No prompt"
			curr--
		}

		// Finally, update new position with current
		newPositionInStdOutput = curr

		return result, newPositionInStdOutput, modifiedStdout
	}

	SyntaxDictionary["ignore"] = func(expectedOutputLine string, StdOutputLines []string, startingPosInStdOuput int) (result string, newPositionInStdOutput int, modifiedStdout []string) {
		result = ""
		newPositionInStdOutput = startingPosInStdOuput + 1 // Core functionality of ignore.... just skip da line
		modifiedStdout = StdOutputLines

		return result, newPositionInStdOutput, modifiedStdout
	}
	return SyntaxDictionary
}

func extractXValue(s string) int {
	x_index := strings.Index(s, "(") + 1
	x_value := int(s[x_index]) - 48 // Ascii subtract
	return x_value
}

func hasOptions(sl []string, x_value, currPos int) (pos int, pass string) {
	pass = " Good menu"
	for i := 1; i <= x_value; i++ {
		if currPos > len(sl)-1 {
			currPos-- // Move curr back if it exceeds the bounds of StdOutputLines
			pass = "No more output remaining"
			return currPos, pass
		}

		var earlyPromptFound bool
		earlyPromptFound, _ = hasPrompt(sl, currPos)

		if earlyPromptFound {
			// fmt.Println("Early prompt")
			pass = " Not enough menu options"
			break
		}

		currPos++
	}
	return currPos, pass
}

func hasPrompt(Stdout []string, pos int) (result bool, modifiedStdout []string) {
	modifiedStdout = Stdout
	result = true
	if strings.HasSuffix(strings.TrimSpace(Stdout[pos]), ":") || strings.HasSuffix(strings.TrimSpace(Stdout[pos]), "?") {
		return result, modifiedStdout
	}

	if !strings.HasSuffix(strings.TrimSpace(Stdout[pos]), ":") && !strings.HasSuffix(strings.TrimSpace(Stdout[pos]), "?") {
		// Search for that : or ? in there!
		// If there is no newline after the : stdout will begin printing right after the colon instead of on the next line
		if strings.Contains(strings.TrimSpace(Stdout[pos]), ":") {
			// Split line into two strings, the prompt and the output that was appended to it
			tempSlice := strings.SplitAfter(Stdout[pos], ":") // temp slice to extract values out of...
			modifiedStdout[pos] = tempSlice[0]
			misplacedOutput := strings.TrimSpace(tempSlice[1])
			modifiedStdout = append(modifiedStdout[:pos+2], modifiedStdout[pos+1:]...)
			modifiedStdout[pos+1] = misplacedOutput
		} else if strings.Contains(strings.TrimSpace(Stdout[pos]), "?") {
			// Split line into two strings, the prompt and the output that was appended to it
			tempSlice := strings.SplitAfter(Stdout[pos], "?") // temp slice to extract values out of...
			modifiedStdout[pos] = tempSlice[0]
			misplacedOutput := strings.TrimSpace(tempSlice[1])
			modifiedStdout = append(modifiedStdout[:pos+2], modifiedStdout[pos+1:]...)
			modifiedStdout[pos+1] = misplacedOutput
		} else {
			result = false
		}

	}
	return result, modifiedStdout
}
