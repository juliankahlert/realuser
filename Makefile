VERSION := $(shell ruby -e "puts Gem::Specification.load('realuser.gemspec').version")

all: realuser-$(VERSION).gem

clean:
	rm --force realuser-*.gem

install: realuser-$(VERSION).gem
	gem install --local $<

uninstall:
	gem uninstall realuser

realuser-$(VERSION).gem: realuser.gemspec lib/realuser.rb Gemfile.lock
	gem build $<

test: lib/realuser.rb Gemfile.lock
	rufo -c lib/
	yard
	rspec

.PHONY: all clean install uninstall test
