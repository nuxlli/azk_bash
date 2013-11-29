#!/usr/bin/env bats

load ../test_helper

export AZK_DOCKER_SOCKET="${AZK_TEST_DIR}/socket/docker.sock"

mock_docker() {
  socket="${AZK_DOCKER_SOCKET}"
  mkdir -p "$(dirname "$socket")"
  socat -T 2 UNIX-LISTEN:"${socket}" SYSTEM:"'fake-docker $1'" &
}

@test "$test_label requires exec in agent" {
  exec() { echo "$@"; return 1; }
  export -f exec

  run azk-dcli GET /images/json
  assert_failure
  assert_output "azk-agent-exec dcli GET /images/json"
}

@test "$test_label requires a docker socket" {
  run azk-dcli --final GET /images/json
  assert_failure
  assert_output "azk: requires docker socket is open"
}

@test "$test_label send request to socker with socat" {
  mock_file="${AZK_TEST_DIR}/mock_docker"
  mkdir -p $(dirname "${mock_file}")
  cat > "${mock_file}" <<'EOF'
    if [[ "${headers[0]}" == "GET /images/json HTTP/1.1" ]]; then
      echo -en "HTTP/1.1 200 OK\r\n\r\n[]"
      exit 0;
    else
      echo "Error"
      exit 1;
    fi
EOF
  mock_docker "${mock_file}"
  sleep 0.1;

  run azk-dcli --final /images/json
  assert_success '[]'
}

@test "$test_label support chucked encoding" {
  mock_file="${AZK_TEST_DIR}/mock_docker"
  mkdir -p $(dirname "${mock_file}")
  cat > "${mock_file}" <<'EOF'
    if [[ "${headers[0]}" == "GET /images/json HTTP/1.1" ]]; then
      echo -en "HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n2\r\n[]\r\n0\r\n\r\n"
      exit 0;
    else
      echo "Error"
      exit 1;
    fi
EOF
  mock_docker "${mock_file}"
  sleep 0.1;

  run azk-dcli --final /images/json
  assert_success '[]'
}

@test "$test_label docker response error" {
  mock_file="${AZK_TEST_DIR}/mock_docker"
  mkdir -p $(dirname "${mock_file}")
  echo 'echo -en "HTTP/1.1 404 Not Found\r\n\r\n[]"' > $mock_file
  mock_docker "${mock_file}"
  sleep 0.1;

  run azk-dcli --final /images
  assert_failure 'azk: error to request /images => 404 Not Found'
}
