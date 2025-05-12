.PHONY: install build server sh antora.build
BUILD=docker
CONTAINER_LABEL=local/antora:elixir-robotics

install i:
	${BUILD} build -t ${CONTAINER_LABEL} .

build b:
	@rm -rf docs/
	${BUILD} run -v .:/antora:z -t ${CONTAINER_LABEL} antora-playbook.yml --stacktrace
	@touch docs/.nojekyll

server s:
	@cd docs && python3 -m http.server

sh:
	${BUILD} run -it --entrypoint /bin/sh -v .:/antora:z -t ${CONTAINER_LABEL}

antora.build ab:
	antora antora-playbook.yml --stacktrace
