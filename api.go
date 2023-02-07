package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
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

			// calling this function parses the request body and fills the req.MultipartForm field
			// err := req.ParseMultipartForm(32 << 20) // 32 << 20 = 32 MB for max memory to hold the files
			// if err != nil {
			// 	w.WriteHeader(http.StatusBadRequest + 21)
			// 	return
			// }

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

			// bodyBytes, err := io.ReadAll(resp.Body) CALLING THIS FUNCTION MEANS U CANT READ THE BODY LATER !!!! BAD LANGUAGE
			// defer resp.Body.Close()
			// util.Throw(err)
			// bodyString := string(bodyBytes)

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

			// Convert to strings as originally in []byte form, each byte being a unicode numeric representatin of each character in the string
			inFileContent := string(inFileByteContent)
			outFileContent := string(outFileByteContent)

			fmt.Printf("Input File Content: %s\n\nOutput File Content: %s\n", inFileContent, outFileContent)
			fmt.Printf("Language: %s, Args: %s\n", queryResults[0].Language, queryResults[0].Args)

			//

			fmt.Fprint(w, "Still POSTed up! o7")

		default:
			w.WriteHeader(http.StatusMethodNotAllowed)
		}
	})

	log.Fatal(http.ListenAndServe(":4200", nil))
}
