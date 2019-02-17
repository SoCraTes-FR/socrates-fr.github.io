.PHONY: clean hugo-build hugo

default: clean hugo-build

clean:
	rm -rf public/

hugo-build: clean
	hugo --enableGitInfo --source .

hugo:
	hugo server --enableGitInfo --watch --source .
