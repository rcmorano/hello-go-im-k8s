// Example - demonstrates REST API server implementation tests.
package main

import (
	"fmt"
	"net/http"
  "os"

  "github.com/asaskevich/govalidator"
//	"github.com/cucumber/godog"
)

func getPath(w http.ResponseWriter, r *http.Request) {

	if r.Method != "GET" {
		fail(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

  // TODO: dynamically determine scheme
  scheme := "http://"
  requestURL := scheme + r.Host + r.RequestURI
  validURL := govalidator.IsURL(requestURL)
	if validURL != true {
		fail(w, "Bad Request", http.StatusBadRequest)
		return
	}

	ok(w, r.URL.Path[1:])
}

func fail(w http.ResponseWriter, msg string, status int) {

	w.WriteHeader(status)

	fmt.Fprintf(w, msg)
}

func ok(w http.ResponseWriter, msg string) {

	fmt.Fprintf(w, msg)
}

func main() {
	http.HandleFunc("/", getPath)
	http.ListenAndServe(":"+os.Getenv("PORT"), nil)
}
