package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
)

type Spec struct {
	Input_file  string `json:"input_file"`
	Output_file string `json:"output_file"`
}

func Server() {

	http.HandleFunc("/grade", func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case "POST":

			// calling this function parses the request body and fills the req.MultipartForm field
			// err := req.ParseMultipartForm(32 << 20) // 32 << 20 = 32 MB for max memory to hold the files
			// if err != nil {
			// 	wWriteHeader(http.StatusBadRequest + 21)
			// 	return
			// }

			// Extract args + assignment ID from URL using req.URL object
			// This will assignment ID will be used to grab the spec/out.txt + spec/in.txt
			assignmentId := r.URL.Query().Get("assignment")
			if assignmentId != "" {
				fmt.Printf("Assigment ID is: %s\n", assignmentId)
			} else {
				fmt.Println("No assignment ID is passed")
			}

			// Load environment Variables
			err := godotenv.Load(".env")
			throw(err)
			supabaseKey := os.Getenv("SUPABASE_SERVICE_ROLE_KEY")
			

			// Get spec file based on assignment ID
			// Initialize request object
			req, err := http.NewRequest("GET", "https://kasxttiggmakvprevgrp.supabase.co/rest/v1/assignment?select=input_file,output_file&id=eq."+assignmentId, nil)
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
			var specificationFiles []Spec
			err = json.NewDecoder(resp.Body).Decode(&specificationFiles)
			throw(err)

			fmt.Fprint(w, specificationFiles[0])

		default:
			w.WriteHeader(http.StatusMethodNotAllowed)
		}
	})

	log.Fatal(http.ListenAndServe(":4200", nil))
}
