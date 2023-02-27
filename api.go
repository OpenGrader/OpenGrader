package main

import (
	"bytes"
	"encoding/json"
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
			// Load environment Variables
			err := godotenv.Load(".env")
			util.Throw(err)
			supabaseKey := os.Getenv("SUPABASE_SERVICE_ROLE_KEY")

			// Get spec file based on assignment ID
			// Initialize request object
			req, err := http.NewRequest(
				"GET",
				"https://kasxttiggmakvprevgrp.supabase.co/rest/v1/assignment?select=input_file,output_file,language,args&id=eq."+assignmentId,
				nil,
			)
			util.Throw(err)
			req.Header.Add("apikey", supabaseKey)
			req.Header.Add("Authorization", "Bearer "+supabaseKey)

			// Initialize http client object
			client := &http.Client{}
			// Get response
			resp, err := client.Do(req)
			util.Throw(err)
			// Read response
			if resp.StatusCode != http.StatusOK {
				fmt.Fprintf(w, "Failure to fetch assignment information")
			}
			// Decode JSON in a confusing way
			var queryResults []AssigmentTableQuery
			err = json.NewDecoder(resp.Body).Decode(&queryResults)
			util.Throw(err)
			// Get spec file contents located at the links retrieved from supabase
			inFileResp, err := http.Get(queryResults[0].Input_file)
			util.Throw(err)
			inFileByteContent, err := io.ReadAll(inFileResp.Body)
			defer inFileResp.Body.Close()
			util.Throw(err)

			outFileResp, err := http.Get(queryResults[0].Output_file)
			util.Throw(err)
			outFileByteContent, err := io.ReadAll(outFileResp.Body)
			defer outFileResp.Body.Close()
			util.Throw(err)
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
			err = os.WriteFile(workDir+"/.spec/in.txt", inFileByteContent, 0666)
			if err != nil {
				log.Fatalf("Error:\t%v\n", err)
			}

			err = os.WriteFile(workDir+"/.spec/out.txt", outFileByteContent, 0666)
			if err != nil {
				log.Fatalf("Error:\t%v\n", err)
			}

			// Parse Mutlipart form time D:
			// calling this function parses the request body and fills the req.MultipartForm field
			err = r.ParseMultipartForm(32 << 20) // 32 << 20 = 32 MB for max memory to hold the files
			if err != nil {
				log.Fatalf("Error:\t%v\n", err)
				w.WriteHeader(http.StatusBadRequest + 21)
				return
			}

			// Prepare request object to send files from form to bucket
			bucketUrl := "https://kasxttiggmakvprevgrp.supabase.co/storage/v1/object/assignments/" + assignmentId + "/"

			// Iterate over multipart form files with name="code" and build local submissions directory
			for _, header := range r.MultipartForm.File["code"] {
				file, err := header.Open()
				util.Throw(err)
				// Save locally
				localFile, err := os.Create("./submissions/" + assignmentId + "/" + studentId + "/" + header.Filename)
				util.Throw(err)
				io.Copy(localFile, file)

				// Gather file bytes for bucket upload body
				// Rewind file pointer to start
				file.Seek(0, io.SeekStart)
				fileBytes, err := io.ReadAll(file)
				util.Throw(err)

				bucketReq, err := http.NewRequest(
					http.MethodPost,
					bucketUrl+studentId+"_"+header.Filename,
					bytes.NewReader(fileBytes),
				)
				util.Throw(err)
				bucketReq.Header.Add("apikey", supabaseKey)
				bucketReq.Header.Add("Authorization", "Bearer "+supabaseKey)

				// Send to bucket
				storageResponse, err := client.Do(bucketReq)
				util.Throw(err)
				if storageResponse.StatusCode != http.StatusOK {
					fmt.Println("Upload status code: ", storageResponse.StatusCode)
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

			supabase := initSupabase()

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

				intStudentId, err := strconv.Atoi(studentId)
				util.Throw(err)
				// find hydratedStudent information from EUID (dirname)
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

				if queryResults[0].Language == "python3" || queryResults[0].Language == "python" {
					result.CompileSuccess = true

					stdout := runInterpreted(filepath.Join(workDir, dir), queryResults[0].Args, queryResults[0].Language, input)
					fmt.Printf("Output for %s: %s", result.Student, stdout)
					result.RunCorrect, result.Feedback = compare(expected, stdout)
				} else {
					result.CompileSuccess = compile(filepath.Join(workDir, dir), queryResults[0].Language, false)
					if result.CompileSuccess {
						stdout := runCompiled(filepath.Join(workDir, dir), queryResults[0].Args, queryResults[0].Language, input)
						result.RunCorrect, result.Feedback = processOutput(expected, stdout)
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