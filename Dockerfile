FROM alpine:3.14

RUN apk add g++ vim bash

COPY grade.sh /bin/grade

ARG RUN_COMMAND=./a.out
ENV RUN_COMMAND=$RUN_COMMAND

ENTRYPOINT ["/bin/grade"]
