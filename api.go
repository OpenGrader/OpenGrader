package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"


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
			studentId := "12354"

			// Load environment Variables
			err := godotenv.Load(".env")
			throw(err)
			supabaseKey := os.Getenv("SUPABASE_SERVICE_ROLE_KEY")

			// Get spec file based on assignment ID
			// Initialize request object
			req, err := http.NewRequest(
				"GET",
				"https://kasxttiggmakvprevgrp.supabase.co/rest/v1/assignment?select=input_file,output_file,language,args&id=eq."+assignmentId,
				nil,
			)
			throw(err)
			req.Header.Add("apikey", supabaseKey)
			req.Header.Add("Authorization", "Bearer "+supabaseKey)

			// Initialize http client object
			client := &http.Client{}

			// Get response
			resp, err := client.Do(req)
			throw(err)

			// Read response
			if resp.StatusCode != http.StatusOK {
				fmt.Fprintf(w, "Failure to fetch assignment information")
			}

			// bodyBytes, err := io.ReadAll(resp.Body) CALLING THIS FUNCTION MEANS U CANT READ THE BODY LATER !!!! BAD LANGUAGE
			// defer resp.Body.Close()
			// throw(err)
			// bodyString := string(bodyBytes)

			// Decode JSON in a confusing way
			var queryResults []AssigmentTableQuery
			err = json.NewDecoder(resp.Body).Decode(&queryResults)
			throw(err)

			// Get spec file contents located at the links retrieved from supabase
			inFileResp, err := http.Get(queryResults[0].Input_file)
			throw(err)
			inFileByteContent, err := io.ReadAll(inFileResp.Body)
			defer inFileResp.Body.Close()
			throw(err)

			outFileResp, err := http.Get(queryResults[0].Output_file)
			throw(err)
			outFileByteContent, err := io.ReadAll(outFileResp.Body)
			defer outFileResp.Body.Close()
			throw(err)

			// Prepare local directory
			err = os.MkdirAll("./submissions/"+assignmentId+"/.spec/", 0766)
			if err != nil {
				log.Fatalf("Error:\t%v\n", err)
			}

			err = os.MkdirAll("./submissions/"+assignmentId+"/"+studentId+"/", 0766)
			if err != nil {
				log.Fatalf("Error:\t%v\n", err)
			}

			// Create local spec files
			err = os.WriteFile("./submissions/"+assignmentId+"/.spec/in.txt", inFileByteContent, 0666)
			if err != nil {
				log.Fatalf("Error:\t%v\n", err)
			}

			err = os.WriteFile("./submissions/"+assignmentId+"/.spec/out.txt", outFileByteContent, 0666)
			if err != nil {
				log.Fatalf("Error:\t%v\n", err)
			}

			// Parse Mutlipart form time D:
			// calling this function parses the request body and fills the req.MultipartForm field
			err = r.ParseMultipartForm(32 << 20) // 32 << 20 = 32 MB for max memory to hold the files
			if err != nil {
				w.WriteHeader(http.StatusBadRequest + 21)
				return
			}

			// Prepare request object to send files from form to bucket
			bucketUrl := "https://kasxttiggmakvprevgrp.supabase.co/storage/v1/object/assignments/"
			// Iterate over multipart form files with name="code" and build local submissions directory
			for _, header := range r.MultipartForm.File["code"] {
				file, err := header.Open()
				throw(err)
				// Save locally
				localFile, err := os.Create("./submissions/" + assignmentId + "/" + studentId + "/" + header.Filename)
				throw(err)
				io.Copy(localFile, file)

				// Gather file bytes for bucket upload body
				fileBytes, err := io.ReadAll(file)
				throw(err)

				bucketReq, err := http.NewRequest(
					http.MethodPost, 
					bucketUrl+studentId+"_"+header.Filename, 
					bytes.NewReader(fileBytes),
				)
				throw(err)
				bucketReq.Header.Add("apikey", supabaseKey)
				bucketReq.Header.Add("Authorization", "Bearer "+supabaseKey)

				// Send to bucket
				storageResponse, err := client.Do(bucketReq)
				throw(err)
				if storageResponse.StatusCode != http.StatusOK {
					fmt.Fprintf(w, "Failure to upload file to bucket")
				}
				file.Close()
			}

			// All pieces to forge the great weapon acquired. Assemble.
			

			// Clean up

			fmt.Fprint(w, "Still POSTed up! o7")

		default:
			w.WriteHeader(http.StatusMethodNotAllowed)
		}
	})

	log.Fatal(http.ListenAndServe(":4200", nil))
}
