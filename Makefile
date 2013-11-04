test: test-local
	@echo "Run remote test"
	@echo "================"
	@ssh azk-agent "cd /vagrant; make test-local"

test-local:
	@echo "Shell tests"
	@bash ./test/bin/azk_test.sh
	@echo "Mix tests"
	@mix test

.PHONY: test test-local
