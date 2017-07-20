# Docker Image of GAE/Go Standard Environment + Node.js for Circle CI 2.0

[docker hub](https://hub.docker.com/r/vvakame/circleci-gaego/)

[example project](https://github.com/vvakame/ucon-todo)

## Motivation

I'm using GAE/Go & Angular for building web app.
Circle CI 2.0 official image are only for 1 language.

## What environment include to this images

* Google Cloud SDK
* GAE/Go Standard Environment SDK
* Go environment
* Node.js environment via [nodebrew](https://github.com/hokaccha/nodebrew)
* Browser
  * Google Chrome (stable)

## Path structure

* GOPATH `/go`
* Work space of tools setup `/work`
