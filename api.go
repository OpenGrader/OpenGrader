package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strconv"
	"strings"

	"github.com/OpenGrader/OpenGrader/db"
	"github.com/OpenGrader/OpenGrader/util"

	"github.com/joho/godotenv"
)

type AssigmentTableQuery struct {
	Input_file  string `json:"input_file"`
	Output_file string `json:"output_file"`
	Language    string `json:"language"`
	Args        string `json:"args"`
}

type TestCase struct {
	Input_File  string `json:"input_file"`
	Output_File string `json:"output_file"`
	Weight      int8   `json:"weight"`
}

type StudentSubmission struct {
	FilePath string `json:"file_Path"`
	FileName string `json:"file_Name"`
}

func Server() {
	// Load environment variables
	err := godotenv.Load(".env")
	util.Throw(err)

	// Init supabase client
	supabase := initSupabase()

	http.HandleFunc("/grade", func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case "GET":

			// Read request body for assignmentId and studentId
			// Extract args + assignment ID from URL using req.URL object
			// This will assignment ID will be used to grab the spec/out.txt + spec/in.txt
			assignmentId := r.URL.Query().Get("assignment")
			if assignmentId != "" {
				fmt.Printf("Assigment ID is: %s\n", assignmentId)
			} else {
				fmt.Println("No assignment ID is passed")
				w.WriteHeader(http.StatusBadRequest + 20)
				return
			}

			// Get student ID. Repeat same functionality as above
			studentId := r.URL.Query().Get("student")
			if studentId != "" {
				fmt.Printf("Student ID is: %s\n", studentId)
			} else {
				fmt.Println("No student ID is passed")
				w.WriteHeader(http.StatusBadRequest + 21)
				return
			}

			// Get assignment tests for supabase
			var tests []TestCase
			err = supabase.DB.From("test_cases").Select("input_file, output_file, weight").Eq("assignment_id", assignmentId).Execute(&tests)
			util.Throw(err)

			// Prepare local directory
			rootPathToDir, err := os.Getwd()
			util.Throw(err)
			workDir := rootPathToDir + "/submissions/" + assignmentId
			err = os.MkdirAll(workDir+"/.spec/", 0766)
			if err != nil {
				log.Fatalf("Error:\t%v\n", err)
			}

			// Put tests cases in .spec folder
			testCaseBucket := supabase.BaseURL + "/storage/v1/object/spec-storage/"
			inputs := make([]string, len(tests))
			outputs := make([]string, len(tests))
			for i, test := range tests {
				err = os.WriteFile(fmt.Sprint(workDir, "/.spec/", i, "_in.txt"), getFileContentFromURL(testCaseBucket+test.Input_File), 0666)
				util.Throw(err)
				inputs[i] = fmt.Sprint(i, "_in.txt")
				err = os.WriteFile(fmt.Sprint(workDir, "/.spec/", i, "_out.txt"), getFileContentFromURL(testCaseBucket+test.Output_File), 0666)
				util.Throw(err)
				outputs[i] = fmt.Sprint(i, "_out.txt")
			}

			// Prepare student directory
			err = os.MkdirAll(workDir+"/"+studentId+"/", 0766)
			if err != nil {
				log.Fatalf("Error:\t%v\n", err)
			}

			// Get student submission from supabase
			var submission []StudentSubmission
			assignmentBucket := supabase.BaseURL + "/storage/v1/object/assignments/"
			err = supabase.DB.From("student_Submission").Select("file_Path, file_Name").Eq("user_ID", studentId).Eq("assignment_ID", assignmentId).Execute(&submission)
			util.Throw(err)
			for _, file := range submission {
				err = os.WriteFile(fmt.Sprint(workDir, "/", studentId, "/", file.FileName), getFileContentFromURL(assignmentBucket+file.FilePath), 0666)
				util.Throw(err)
			}

			// Directory setup, now grade
			cmd := exec.Command("ls")
			cmd.Dir = workDir

			out, _ := cmd.Output()
			dirs := strings.Fields(string(out[:]))

			// initialize AssignmentInfo
			var assignmentInfo util.AssignmentInfo

			// convert assignmentid string to int8
			intAssignmentId, err := strconv.Atoi(assignmentId)
			util.Throw(err)
			assignmentInfo.AssignmentId = int8(intAssignmentId)

			// get the rest of the assignment info from supabase (just the lang and args)
			var assignmentTableQuery []AssigmentTableQuery
			err = supabase.DB.From("assignment").Select("language, args").Eq("id", assignmentId).Execute(&assignmentTableQuery)
			util.Throw(err)
			// set the assignment info
			assignmentInfo.Language = assignmentTableQuery[0].Language
			assignmentInfo.Args = assignmentTableQuery[0].Args

			// no walls, only doors
			assignmentInfo.Wall = false

			for _, dir := range dirs {
				checkForZip(workDir, dir)

				var result util.SubmissionResult
				intStudentId, err := strconv.Atoi(studentId)
				util.Throw(err)
				studentInfo := db.GetStudentById(supabase, int8(intStudentId))
				result.Student = studentInfo.Euid

				result.AssignmentId = int8(intAssignmentId)
				result.StudentId = int8(intStudentId)
				result.Feedback = make([]string, len(tests))

				for i := range tests {
					expected := util.GetFile(workDir + "/.spec/" + outputs[i])

					fmt.Printf("Running test %d\nExpected Output: %s\n", i, expected)

					input := parseInFile(workDir + "/.spec/" + inputs[i])
					gradeSubmission(&result, dir, workDir, expected, input, i, assignmentInfo)
				}

				if result.CompileSuccess {
					result.Score = int8(calculateScoreMod(result, tests))
				} else {
					result.Score = 0
				}
				// Upload to DB
				db.SaveResult(supabase, &result)
			}

			// Delete the directory
			err = os.RemoveAll(rootPathToDir + "/submissions")
			util.Throw(err)

			fmt.Fprintf(w, "Grading complete.\n")
		default:
			w.WriteHeader(http.StatusMethodNotAllowed)
		}
	})

	log.Fatal(http.ListenAndServe(":4200", nil))
}

func getFileContentFromURL(url string) []byte {
	client := &http.Client{}
	req, err := http.NewRequest("GET", url, nil)
	util.Throw(err)
	supabaseKey := os.Getenv("SUPABASE_KEY")
	req.Header.Add("Authorization", "Bearer "+supabaseKey)
	req.Header.Add("apikey", supabaseKey)
	fileResp, err := client.Do(req)
	util.Throw(err)
	fileContent, err := io.ReadAll(fileResp.Body)
	defer fileResp.Body.Close()
	util.Throw(err)

	return fileContent
}

func calculateScoreMod(result util.SubmissionResult, tests []TestCase) (score int) {
	var scorePossible int = 0
	var scoreEarned int = 0
	for i, feedback := range result.Feedback {
		scorePossible += int(tests[i].Weight)
		if feedback == "" {
			scoreEarned += int(tests[i].Weight)
		}
	}

	score = int((float64(scoreEarned) / float64(scorePossible)) * 100)
	return
}
