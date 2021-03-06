#
# Use rerun: COLUMNS=$COLUMNS rerun -c --no-growl --pattern "{Makefile,bin/azk,**/*.sh,**/*.exs,**/*.ex,**/*.proto,**/*.json}" "make test"
#

COLUMNS ?= 50

REMOTE_BANNER     := Run test in azk-agent
REMOTE_BANNER_SIZE:= $(shell echo ${REMOTE_BANNER} | wc | awk '{print $$3}')
REMOTE_PRE_BANNER := $$(( (${COLUMNS} - ${REMOTE_BANNER_SIZE}) / 2 ))

LOCAL_BANNER := Run test in local
LOCAL_BANNER_SIZE:= $(shell echo ${LOCAL_BANNER} | wc | awk '{print $$3}')
LOCAL_PRE_BANNER := $$(( (${COLUMNS} - ${LOCAL_BANNER_SIZE}) / 2 ))

TEST_FILES := $(shell find test -name '*.bats' | xargs)
RERUN_PATTERN := "{Makefile,bin/azk,**/*.bash,**/*.bats,private/**/*,libexec/**/*,test/**/*azkfile.json}"

ifeq ($(agent),true)
	LOCAL := ""
else
	LOCAL := "\x1b[30;43;5;82m%${LOCAL_PRE_BANNER}s${LOCAL_BANNER} %${LOCAL_PRE_BANNER}s\n\x1b[0m\n"
endif

# install azk
install: vagrant
	@vagrant up
	@bash ./bin/azk admin install

vagrant:
	@echo "Check for vagrant..."
	@vagrant -v &>/dev/null || echo "Vagrant this actually installed?"

test: test-local
	@printf "\n\n\x1b[30;44;5;82m%${REMOTE_PRE_BANNER}s${REMOTE_BANNER} %${REMOTE_PRE_BANNER}s"
	@echo "\n\x1b[0m"
	@./libexec/azk agent-ssh azk-agent "cd /home/core/azk; ./deps/bats/bin/bats ${TEST_FILES}"

test-local: deps/bats/bin/bats
	@printf ${LOCAL}
	@echo "Shell tests\n"
	@bash ./deps/bats/bin/bats ${TEST_FILES}

get-deps:
	@mkdir -p deps
	@cd deps; git clone https://github.com/sstephenson/bats; echo

# auto run test in development
rerun:
	@which rerun &>/dev/null || (echo "Rerun not found, install: gem install rerun" && exit 1)
	@rerun -c --no-growl --pattern $(RERUN_PATTERN) "./deps/bats/bin/bats $(TEST_FILES)"

.PHONY: install test test-local get-deps rerun
