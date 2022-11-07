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
func initSyntaxDictionary() map[string]func(string, []string, int) (int, int, []string) {
	SyntaxDictionary := make(map[string]func(string, []string, int) (int, int, []string))

	SyntaxDictionary["menu"] = func(expectedOutputLine string, StdOutputLines []string, startingPosInStdOuput int) (result, newPositionInStdOutput int, modifiedStdout []string) {
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
			string leading with 1
			string leading with 2
			string leading with 3
			string ending with :
		*/

		// Set modifiedStdout equal to StdOutputLines
		modifiedStdout = StdOutputLines

		// Initially give result a passing value of 1, will be changed to 0 if it fails any of the following checks.
		result = 1

		// First, extract the value of x CONVERT
		x_index := strings.Index(expectedOutputLine, "(") + 1
		x_value := int(expectedOutputLine[x_index]) - 48 // Ascii subtract

		// Get current position in stdout
		curr := startingPosInStdOuput

		// Now, evaluate the menu shape.
		// Check for title
		if StdOutputLines[curr] == "" {
			fmt.Println("Check for title failed")
			result = 0 // Check failed
		}

		curr++

		// Check for options leading with a digit
		for i := 1; i <= x_value; i++ {
			if curr > len(StdOutputLines)-1 {
				result = 0
				curr-- // Move curr back if it exceeds the bounds of StdOutputLines
				newPositionInStdOutput = curr
				return
			}

			if !strings.HasPrefix(StdOutputLines[curr], fmt.Sprint(i)) {
				fmt.Printf("Check for option #%d leading digit failed\n", i)
				result = 0 // if no leading digit, check failed
			}
			curr++
		}

		// Check to see if curr exceeds bounds again
		if curr > len(StdOutputLines)-1 {
			result = 0
			curr-- // Move curr back if it exceeds the bounds of StdOutputLines
			newPositionInStdOutput = curr
			return
		}

		// Trim possible trailing whitespace and check for ending with :
		if !strings.HasSuffix(strings.TrimSpace(StdOutputLines[curr]), ":") {
			// Search for that : in there!
			// If there is no newline after the : stdout will begin printing right after the colon instead of on the next line
			if strings.Contains(strings.TrimSpace(StdOutputLines[curr]), ":") {

				// Split line into two strings, the prompt and the output that was appended to it
				tempSlice := strings.SplitAfter(StdOutputLines[curr], ":") // temp slice to extract values out of...
				modifiedStdout[curr] = tempSlice[0]
				misplacedOutput := strings.TrimSpace(tempSlice[1])
				modifiedStdout = append(modifiedStdout[:curr+2], modifiedStdout[curr+1:]...)
				modifiedStdout[curr+1] = misplacedOutput
				result = 1
			} else {
				fmt.Println("Check for trailing : failed on prompt line")
				result = 0
			}
		}

		// Finally, update new position with current
		newPositionInStdOutput = curr

		return
	}

	return SyntaxDictionary
}
