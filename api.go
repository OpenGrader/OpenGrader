package main

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
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

func Server() {

	http.HandleFunc("/grade", func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case "POST":
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
			if assignmentId != "" {
				fmt.Printf("Student ID is: %s\n", studentId)
			} else {
				fmt.Println("No student ID is passed")
				w.WriteHeader(http.StatusBadRequest + 21)
				return
			}
			// Load environment variables
			err := godotenv.Load(".env")
			util.Throw(err)
			supabaseKey := os.Getenv("SUPABASE_KEY")

			// Init supabase client
			supabase := initSupabase()

			// Get spec file based on assignment ID
			assignment := db.GetAssignment(supabase, assignmentId)

			// Get spec file contents located at the links retrieved from supabase
			inFileContent := getFileContentFromURL(assignment.InputFile)
			outFileContent := getFileContentFromURL(assignment.OutputFile)

			// Prepare local directory
			rootPathToDir, err := os.Getwd()
			util.Throw(err)
			workDir := rootPathToDir + "/submissions/" + assignmentId
			err = os.MkdirAll(workDir+"/.spec/", 0766)
			if err != nil {
				log.Fatalf("Error:\t%v\n", err)
			}

			err = os.MkdirAll(workDir+"/"+studentId+"/", 0766)
			if err != nil {
				log.Fatalf("Error:\t%v\n", err)
			}

			// Create local spec files
			err = os.WriteFile(workDir+"/.spec/in.txt", inFileContent, 0666)
			if err != nil {
				log.Fatalf("Error:\t%v\n", err)
			}

			err = os.WriteFile(workDir+"/.spec/out.txt", outFileContent, 0666)
			if err != nil {
				log.Fatalf("Error:\t%v\n", err)
			}

			// calling this function parses the request body and fills the req.MultipartForm field
			err = r.ParseMultipartForm(32 << 20) // 32 << 20 = 32 MB for max memory to hold the files
			if err != nil {
				log.Fatalf("Error:\t%v\n", err)
				w.WriteHeader(http.StatusBadRequest + 21)
				return
			}

			// Prepare request object to send files from form to bucket
			bucketUrl := supabase.BaseURL + "/storage/v1/object/assignments/" + assignmentId + "/"
			client := &http.Client{}
			// Iterate over multipart form files with name="code" and build local submissions directory
			for _, header := range r.MultipartForm.File["code"] {
				file, openErr := header.Open()
				util.Throw(openErr)
				// Save locally
				localFile, createErr := os.Create("./submissions/" + assignmentId + "/" + studentId + "/" + header.Filename)
				util.Throw(createErr)

				_, copyErr := io.Copy(localFile, file)
				util.Throw(copyErr)

				// Gather file bytes for bucket upload body
				// Rewind file pointer to start
				_, seekErr := file.Seek(0, io.SeekStart)
				util.Throw(seekErr)

				fileBytes, readErr := io.ReadAll(file)
				util.Throw(readErr)

				bucketReq, reqErr := http.NewRequest(
					http.MethodPost,
					bucketUrl+studentId+"_"+header.Filename,
					bytes.NewReader(fileBytes),
				)
				util.Throw(reqErr)
				bucketReq.Header.Add("apikey", supabaseKey)
				bucketReq.Header.Add("Authorization", "Bearer "+supabaseKey)

				// Send to bucket
				storageResponse, doErr := client.Do(bucketReq)
				util.Throw(doErr)
				if storageResponse.StatusCode != http.StatusOK {
					fmt.Println("Upload status code: ", storageResponse.StatusCode)
					fmt.Printf("Upload error: %v\n", storageResponse.Body)
				}

				file.Close()
			}

			// All pieces to forge the great weapon acquired. Assemble.
			// Almost entirely copy and pasted from main(). Should refactor.
			cmd := exec.Command("ls")
			cmd.Dir = workDir

			out, _ := cmd.Output()
			dirs := strings.Fields(string(out[:]))

			input := parseInFile(workDir + "/.spec/in.txt")
			expected := util.GetFile(workDir + "/.spec/out.txt")

			intAssignmentId, err := strconv.Atoi(assignmentId)
			util.Throw(err)

			var results util.SubmissionResults
			results.Results = make(map[string]*util.SubmissionResult)
			resTable := ""
			for _, dir := range dirs {
				var result util.SubmissionResult
				results.Results[dir] = &result
				results.Order = append(results.Order, dir)

				result.Student = dir

				result.Feedback = make([]string, 1)
				// find hydratedStudent information from studentId (query param)
				intStudentId, err := strconv.Atoi(studentId)
				util.Throw(err)
				hydratedStudent := db.GetStudentById(supabase, int8(intStudentId))

				// if student doesn't exist, commit to db
				if hydratedStudent.Id == 0 {
					hydratedStudent.Euid = dir
					hydratedStudent.Email = fmt.Sprintf("%s@unt.edu", dir) // all students have euid@unt.edu

					fmt.Printf("%8s: ", dir)
					fmt.Printf("%+v\n", hydratedStudent)

				}
				result.StudentId = hydratedStudent.Id
				result.AssignmentId = int8(intAssignmentId)

				if assignment.Language == "python3" || assignment.Language == "python" {
					result.CompileSuccess = true

					stdout := runInterpreted(filepath.Join(workDir, dir), assignment.Args, assignment.Language, input)
					fmt.Printf("Output for %s: %s", result.Student, stdout)
					_, result.Feedback[0] = compare(expected, stdout)
				} else {
					result.CompileSuccess = compile(filepath.Join(workDir, dir), assignment.Language, false)
					if result.CompileSuccess {
						stdout := runCompiled(filepath.Join(workDir, dir), assignment.Args, assignment.Language, input)
						result.Feedback[0] = processOutput(expected, stdout)
					}
				}
			}

			for _, id := range results.Order {
				resTable = resTable + fmt.Sprintf("Student %s feedback: \n%s\n", id, results.Results[id].Feedback)
			}

			writeFullOutputToDb(supabase, results)

			// Clean up files and directories
			err = os.RemoveAll(rootPathToDir + "/submissions")
			util.Throw(err)

			// ALL DONE :D
			// Write response table to user
			fmt.Fprint(w, resTable)

		default:
			w.WriteHeader(http.StatusMethodNotAllowed)
		}
	})

	log.Fatal(http.ListenAndServe(":4200", nil))
}

func getFileContentFromURL(url string) []byte {
	fileResp, err := http.Get(url)
	util.Throw(err)
	fileContent, err := io.ReadAll(fileResp.Body)
	defer fileResp.Body.Close()
	util.Throw(err)

	return fileContent
}
