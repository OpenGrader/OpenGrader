package db

import (
	"fmt"

	"github.com/OpenGrader/OpenGrader/util"
	"github.com/nedpals/supabase-go"
)

type DbAssignment struct {
	Id          int8   `json:"id"`
	Section     int8   `json:"section"`
	Title       string `json:"title"`
	Description string `json:"description"`
	InputFile   string `json:"input_file"`
	OutputFile  string `json:"output_file"`
	Language    string `json:"language"`
	Args        string `json:"args"`
}

type DbSubmission struct {
	Assignment    int8     `json:"assignment"`
	Student       int8     `json:"student"`
	IsLate        bool     `json:"is_late"`
	Score         int8     `json:"score"`
	Flags         []string `json:"flags"`
	SubmissionLoc string   `json:"submission_loc"`
	Feedback      string   `json:"feedback"`
}

type DbStudent struct {
	Id         int8   `json:"id"`
	GivenName  string `json:"given_name"`
	FamilyName string `json:"family_name"`
	Email      string `json:"email"`
	Euid       string `json:"euid"`
}

type insertableUser struct {
	GivenName  string `json:"given_name"`
	FamilyName string `json:"family_name"`
	Email      string `json:"email"`
	Euid       string `json:"euid"`
}

func toDbAssignment(assignment util.SubmissionResult) DbSubmission {
	return DbSubmission{
		Assignment:    assignment.AssignmentId,
		Student:       assignment.StudentId,
		IsLate:        false,
		Score:         assignment.Score,
		Flags:         []string{},
		SubmissionLoc: "UNDEF",
		Feedback:      util.StringSliceToPrettyString(assignment.Feedback),
	}
}

func SaveResult(sb *supabase.Client, result *util.SubmissionResult) {
	dbAssignment := toDbAssignment(*result)

	fmt.Printf("%+v\n", dbAssignment)

	err := sb.DB.From("submission").Insert(dbAssignment).Execute(nil)
	util.Throw(err)
}

func GetResult(sb *supabase.Client, resultId int) (result DbSubmission) {
	err := sb.DB.From("submission").Select("*").Eq("id", fmt.Sprint(resultId)).Execute(&result)
	util.Throw(err)
	return
}

func GetAssignment(sb *supabase.Client, assignmentId string) (result DbAssignment) {
	var container []DbAssignment
	err := sb.DB.From("assignment").Select("*").Eq("id", assignmentId).Execute(&container)
	util.Throw(err)

	if len(container) != 0 {
		result = container[0]
	} else {
		fmt.Println("Assignment not found")
	}
	return
}

func GetStudentById(sb *supabase.Client, studentId int8) (result DbStudent) {
	var container []DbStudent
	err := sb.DB.From("user").Select("*").Limit(1).Eq("id", fmt.Sprint(studentId)).Execute(&container)
	util.Throw(err)

	// handle not found case
	if len(container) != 0 {
		result = container[0]
	}
	return
}

func GetStudentByEuid(sb *supabase.Client, euid string) (result DbStudent) {
	var container []DbStudent
	err := sb.DB.From("user").Select("*").Limit(1).Eq("euid", euid).Execute(&container)
	util.Throw(err)

	fmt.Printf("Student Information: %+v\n", container)

	// handle not found case
	if len(container) != 0 {
		result = container[0]
	}
	return
}

func (s *DbStudent) Save(sb *supabase.Client) {
	var container []DbStudent

	// is not the default unset value
	if s.Id != 0 {
		err := sb.DB.From("user").Update(s).Eq("id", fmt.Sprint(s.Id)).Execute(&container)
		util.Throw(err)

		if len(container) != 0 {
			s.Id = container[0].Id
		}
		return
	} else {
		// probably insert
		if s.Euid == "" {
			panic("Cannot save student without euid")
		}

		// check if student exists
		foundStudent := GetStudentByEuid(sb, s.Euid)
		// does exist, update
		if foundStudent.Id != 0 {
			s.Id = foundStudent.Id
			err := sb.DB.From("user").Update(s).Eq("id", fmt.Sprint(s.Id)).Execute(&container)
			util.Throw(err)

			if len(container) != 0 {
				s.Id = container[0].Id
			}
			return
		}

		// does not exist, insert
		toInsert := s.MakeInsertable()
		err := sb.DB.From("user").Insert(toInsert).Execute(&container)
		util.Throw(err)

		if len(container) != 0 {
			s.Id = container[0].Id
		}
		return
	}
}

// Strip user ID from student struct to allow PostgREST to use the IDENTITY function
func (s *DbStudent) MakeInsertable() insertableUser {
	return insertableUser{
		GivenName:  s.GivenName,
		FamilyName: s.FamilyName,
		Email:      s.Email,
		Euid:       s.Euid,
	}
}
