package main

import (
// TODO: implement tests in native Go instead of using external curl :)
//  "fmt"
//  "net/http"
//  "net/http/httptest"
  "os/exec"

  "github.com/cucumber/godog"
  "github.com/cucumber/godog/gherkin"
)

func iSendRequestTo(arg1, arg2 string) error {
  cmd := exec.Command("curl", "-O", url)
  cmd.Run()
	return godog.ErrPending
}

func isRFCCompliant(arg1 string, arg2, arg3, arg4 int) error {
	return godog.ErrPending
}

func theResponseCodeShouldBeOK(arg1 int) error {
	return godog.ErrPending
}

func theResponseShouldMatch(arg1 string) error {
	return godog.ErrPending
}

func isNOTCompliant(arg1 string, arg2, arg3, arg4 int) error {
	return godog.ErrPending
}

func theResponseCodeShouldBeBadRequest(arg1 int) error {
	return godog.ErrPending
}

func theResponseShouldMatch(arg1 *gherkin.DocString) error {
	return godog.ErrPending
}

func theResponseCodeShouldBe(arg1 int) error {
	return godog.ErrPending
}

func theResponseShouldMatch(arg1 *gherkin.DocString) error {
	return godog.ErrPending
}

func FeatureContext(s *godog.Suite) {
	s.Step(`^I send "([^"]*)" request to "([^"]*)"$`, iSendRequestTo)
	s.Step(`^"([^"]*)" is RFC \((\d+), (\d+) (\d+)\) compliant$`, isRFCCompliant)
	s.Step(`^the response code should be (\d+) OK$`, theResponseCodeShouldBeOK)
	s.Step(`^the response should match "([^"]*)"$`, theResponseShouldMatch)
	s.Step(`^"([^"]*)" is NOT \((\d+), (\d+) (\d+)\) compliant$`, isNOTCompliant)
	s.Step(`^the response code should be (\d+) Bad Request$`, theResponseCodeShouldBeBadRequest)
	s.Step(`^the response should match$`, theResponseShouldMatch)
	s.Step(`^the response code should be (\d+)$`, theResponseCodeShouldBe)
	s.Step(`^the response should match:$`, theResponseShouldMatch)
}
