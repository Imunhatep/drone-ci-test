FROM golang:alpine AS build-env

ENV GO111MODULE=on \
    CGO_ENABLED=1

WORKDIR /build

# Let's cache modules retrieval - those don't change so often
#COPY go.mod .
#COPY go.sum .
#RUN go mod download

# Copy the code necessary to build the application
# You may want to change this to copy only what you actually need.
COPY . .

ADD . /build

# Build the application
RUN go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o app .

# Let's create a /dist folder containing just the files necessary for runtime.
# Later, it will be copied as the / (root) of the output image.
WORKDIR /dist
RUN cp /build/my-awesome-go-program ./my-awesome-go-program


FROM scratch
WORKDIR /app
COPY --from=build-env /go/src/app/app .
ENTRYPOINT [ "./app" ]
