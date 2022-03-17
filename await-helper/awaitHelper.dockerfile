FROM alpine:3.14

RUN apk update; apk add curl

ADD awaitHelper.sh .

ENTRYPOINT [ "./awaitHelper.sh" ]
