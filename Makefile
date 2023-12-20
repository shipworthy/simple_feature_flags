.PHONY: \
	all \
	build \
	format \
	format-check \
	hex-publish \
	lint \
	test


all: build format format-check lint test


build:
	mix compile --warnings-as-errors --force
	mix docs --proglang elixir


format:
	mix format


format-check:
	mix format --check-formatted


lint:
	mix credo


hex-publish:
	mix hex.publish --organization shipworthy


test:
	mix test --warnings-as-errors --cover --trace
