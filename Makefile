MAKEFLAGS = -j1

export NODE_ENV = test

.PHONY: clean test test-only test-cov test-clean test-travis publish build bootstrap publish-core publish-runtime build-website build-core watch-core build-core-test clean-core prepublish

build: clean
	./node_modules/.bin/gulp build

build-dist: build
	cd packages/babel-polyfill; \
	scripts/build-dist.sh
	cd packages/babel-runtime; \
	node scripts/build-dist.js

watch: clean
	./node_modules/.bin/gulp watch

lint:
	./node_modules/.bin/kcheck

clean: test-clean
	rm -rf packages/babel-polyfill/browser*
	rm -rf coverage
	rm -rf packages/*/npm-debug*

test-clean:
	rm -rf packages/*/test/tmp
	rm -rf packages/*/test-fixtures.json

test-only:
	./scripts/test.sh
	make test-clean

test: lint test-only

test-cov: clean
	# rebuild with test
	rm -rf packages/*/lib
	BABEL_ENV=test; ./node_modules/.bin/gulp build
	./scripts/test-cov.sh

test-ci:
	make lint
	NODE_ENV=test make bootstrap
	./scripts/test-cov.sh
	cat ./coverage/coverage.json | ./node_modules/codecov.io/bin/codecov.io.js

publish:
	git pull --rebase
	rm -rf packages/*/lib
	make build-dist
	make test
	./node_modules/.bin/lerna publish
	make clean
	#./scripts/build-website.sh

bootstrap:
	npm install
	./node_modules/.bin/lerna bootstrap
	# remove all existing babel-runtimes and use the top-level babel-runtime
	rm -rf packages/*/node_modules/babel-runtime
	make build
	cd packages/babel-runtime; \
	node scripts/build-dist.js
