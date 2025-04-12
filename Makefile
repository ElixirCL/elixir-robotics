.PHONY: install build server watch
BUILD=docker
CONTAINER_LABEL=local/antora:elixir-robotics

install i:
	${BUILD} build -t ${CONTAINER_LABEL} .

build b:
	@rm -rf docs/
	${BUILD} run -v .:/antora:z --rm -t ${CONTAINER_LABEL} antora-playbook.yml
	@touch docs/.nojekyll

server s:
	@make build
	@cd docs && python3 -m http.server

# https://github.com/sachaos/viddy
watch w:
	@viddy ${BUILD} run -v .:/antora:z --rm -t ${CONTAINER_LABEL} antora-playbook.yml
