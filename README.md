# OpenGrader

This repo currently includes C++ compilation and grading functionality. It compiles each submission mounted in the `code/` directory of the Docker container and writes a `report.txt` file indicating how the program performed.

## Usage - Docker+Bash

Start by building the docker container:

```sh
docker build -t opengrader .
```

By default, the container will just call `./a.out`, but you can customize this:

```sh
docker build -t opengrader --build-arg RUN_COMMAND="./a.out other args here"
```

Write some code in a directory on your machine. It should be formatted like so:

```txt
submissions/
├── .spec/
│   └── out.txt
├── student1/
│   ├── main.cpp
│   └── README.md
├── student2/
│   ├── my-program.cpp
│   └── README.md
├── student3/
│   ├── cool_app.cpp
│   ├── README.md
│   └── Makefile
└── ...
```

Each subdirectory within submissions **must** contain exactly one `int main()` function.

`.spec/out.txt` should contain the expected output of the program. Your output will look nicer with a trailing newline, but the grading results will remain the same.

Then, run the docker container:

```sh
docker run -v /absolute/path/to/submissions:/code opengrader
```

Two files `out.txt` and `report.txt` will be added to each submission folder describing the results.

## Usage - Golang

Install [golang](//go.dev).

Start by grabbing the project's dependencies:

```sh
go mod init
```

Then, you can either build or run the project directly:

```sh
go build grade.go
./grade -h  # show help docs

go run grade.go -h  # show help docs
```
