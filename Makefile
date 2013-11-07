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

ifeq ($(agent),true)
	LOCAL := ""
else
	LOCAL := "\x1b[30;43;5;82m%${LOCAL_PRE_BANNER}s${LOCAL_BANNER} %${LOCAL_PRE_BANNER}s\n\x1b[0m\n"
endif

test: test-local
	@printf "\n\n\x1b[30;44;5;82m%${REMOTE_PRE_BANNER}s${REMOTE_BANNER} %${REMOTE_PRE_BANNER}s"
	@echo "\n\x1b[0m"
	@ssh azk-agent "cd /vagrant; make agent=true test-local"

test-local:
	@printf ${LOCAL}
	@echo "Shell tests\n"
	@bash ./test/bin/azk_test.sh
	@echo "\nMix tests"
	@mix test

.PHONY: test test-local
