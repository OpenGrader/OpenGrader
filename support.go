package main


// Returns the Syntax Dictionary that maps keywords to functions that handle the processing of their output. 
func initSyntaxDictionary() map[string]func(string, string) int {
	SyntaxDictionary := make(map[string]func(string, string) int)
	
	SyntaxDictionary["menu"] = func(s1, s2 string) int {


		return 1
	}

	return SyntaxDictionary
}