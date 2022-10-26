package service

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"ssssserver/pkg/session"
	"ssssserver/pkg/venom"

	"google.golang.org/protobuf/proto"
	"github.com/CAFxX/httpcompression"
)

func FileServiceListen(dataFolder string, sessBook *session.SessionBook) {
	compress, err := httpcompression.DefaultAdapter()
	if err != nil {
		log.Fatal("httpcompression.DefaultAdapter: ", err)
	}
	httpHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		handler(w, r, dataFolder, sessBook)
	})
	http.Handle("/", compress(httpHandler))
	err = http.ListenAndServe(":8008", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}

func handler(_ http.ResponseWriter, r *http.Request, dataFolder string, sessBook *session.SessionBook) {
	authTokenString, err := url.QueryUnescape(r.URL.Query()["authToken"][0])
	if err != nil {
		log.Printf("Failed to decode authToken: %s\n", err)
		return
	}
	authToken := &venom.AuthToken{}
	err = proto.Unmarshal([]byte(authTokenString), authToken)
	if err != nil {
		log.Printf("Failed to decode authToken: %s\n", err)
		return
	}
	sess, err := sessBook.Get(authToken)
	if err != nil {
		log.Printf("Invalid session: %s\n", err)
		return
	}

	fileId := r.URL.Query()["fileId"][0]
	if !sess.VerifyNewFileId(fileId) {
		log.Printf("Invalid fileId")
		return
	}
	f, err := os.OpenFile(fmt.Sprintf("%s/%s", dataFolder, fileId), os.O_RDWR|os.O_CREATE|os.O_EXCL, 0600)
	if err != nil {
		log.Printf("Failed to create file %s/%s\n", dataFolder, fileId)
		return
	}
	defer f.Close()
	shouldContinue := true
	for shouldContinue {
		bytes := make([]byte, 4096)
		count, err := r.Body.Read(bytes)
		if err != nil && err != io.EOF {
			log.Printf("An unexpected error occurred during a file upload%s\n", err)
			return
		}
		if err != nil && err == io.EOF {
			shouldContinue = false
		} else {
			shouldContinue = true
		}
		_, err = f.Write(bytes[0:count])
		if err != nil {
			log.Printf("Unexpected error writing to file")
			return
		}
	}
}
