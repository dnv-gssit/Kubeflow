# Dockerfile Builder
# ==================
# All the content is in `docker-bits`; this Makefile
# just builds target dockerfiles by combining the dockerbits.


# The docker-stacks tag
DOCKER-STACKS-UPSTREAM-TAG := ed2908bbb62e


CAT := awk '(FNR==1){print "\n\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\n\#\#\#  " FILENAME "\n\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\n"}1'
SRC := docker-bits
RESOURCES := resources
OUT := output
TMP := .tmp
TESTS_DIR := ./tests
MAKE_HELPERS := ./make_helpers/
PYTHON_VENV := .venv
POST_BUILD_HOOK := post-build-hook.sh

# Default labels
DEFAULT_REPO := kubeitglobalsvcauxacrwe.azurecr.io
GIT_SHA := $(shell git rev-parse HEAD)

DEFAULT_PORT := 8888
DEFAULT_NB_PREFIX := /notebook/username/notebookname


DEFAULT_TAG := $(shell ./make_helpers/get_branch_name.sh)
BRANCH_NAME := $(shell ./make_helpers/get_branch_name.sh)

.PHONY: clean .output generate-dockerfiles

clean:
	rm -rf $(OUT) $(TMP)

.output:
	mkdir -p $(OUT)/ $(TMP)/


get-docker-stacks-upstream-tag:
	@echo $(DOCKER-STACKS-UPSTREAM-TAG)

generate-dockerfiles: clean remote-desktop



# Remote Desktop

remote-desktop:
	mkdir -p $(OUT)/$@
	echo "REMOTE DESKTOP"
	cp -r scripts/remote-desktop $(OUT)/$@
	cp -r resources/common/. $(OUT)/$@
	cp -r resources/remote-desktop/. $(OUT)/$@

	$(CAT) \
		$(SRC)/0_Rocker.Dockerfile \
		$(SRC)/3_Kubeflow.Dockerfile \
		$(SRC)/4_CLI.Dockerfile \
		$(SRC)/6_remote-desktop.Dockerfile \
		$(SRC)/7_remove_vulnerabilities.Dockerfile \
		$(SRC)/∞_CMD_remote-desktop.Dockerfile \
	>   $(OUT)/$@/Dockerfile

# create directories for current images
# jupyterlab: cpu

# 	for type in $^; do \
# 		mkdir -p $(OUT)/$@-$${type}; \
# 		cp -r resources/common/. $(OUT)/$@-$${type}/; \
# 		$(CAT) \
# 			$(TMP)/$${type}.Dockerfile \
# 			$(SRC)/3_Kubeflow.Dockerfile \
# 			$(SRC)/4_CLI.Dockerfile \
# 			$(SRC)/5_DB-Drivers.Dockerfile \
# 			$(SRC)/6_$(@).Dockerfile \
# 			$(SRC)/7_remove_vulnerabilities.Dockerfile \
# 			$(SRC)/8_platform.Dockerfile \
# 			$(SRC)/∞_CMD.Dockerfile \
# 		>   $(OUT)/$@-$${type}/Dockerfile; \
# 	done


###################################
######    Docker helpers     ######
###################################
pull/%: DARGS?=
pull/%: REPO?=$(DEFAULT_REPO)
pull/%: TAG?=$(DEFAULT_TAG)
pull/%:
	# End repo with a single slash and start tag with a single colon, if they exist
	REPO=$$(echo "$(REPO)" | sed 's:/*$$:/:' | sed 's:^\s*/*\s*$$::') &&\
	TAG=$$(echo "$(TAG)" | sed 's~^:*~:~' | sed 's~^\s*:*\s*$$~~') &&\
	echo "Pulling $${REPO}$(notdir $@)$${TAG}" &&\
	docker pull $(DARGS) "$${REPO}$(notdir $@)$${TAG}"

build/%: DARGS?=
build/%: REPO?=$(DEFAULT_REPO)
build/%: TAG?=$(DEFAULT_TAG)
build/%: ## build the latest image
	# End repo with exactly one trailing slash, unless it is empty
	REPO=$$(echo "$(REPO)" | sed 's:/*$$:/:' | sed 's:^\s*/*\s*$$::') &&\
	IMAGE_NAME="$${REPO}$(notdir $@):$(TAG)" && \
	docker build $(DARGS) --rm --force-rm -t $$IMAGE_NAME ./output/$(notdir $@) && \
	echo -n "Built image $$IMAGE_NAME of size: " && \
	docker images $$IMAGE_NAME --format "{{.Size}}" && \
	echo "full_image_name=$$IMAGE_NAME" >> $(GITHUB_OUTPUT) && \
	echo "image_tag=$(TAG)" >> $(GITHUB_OUTPUT) && \
	echo "image_repo=$${REPO}" >> $(GITHUB_OUTPUT)

post-build/%: export REPO?=$(DEFAULT_REPO)
post-build/%: export TAG?=$(DEFAULT_TAG)s
post-build/%: export SOURCE_FULL_IMAGE_NAME?=
post-build/%: export IMAGE_VERSION?=
post-build/%: export IS_LATEST?=
post-build/%:
	# TODO: could check for custom hook in the build's directory
	IMAGE_NAME="$(notdir $@)" \
	GIT_SHA=$(GIT_SHA) \
	BRANCH_NAME=$(BRANCH_NAME) \
	bash "$(MAKE_HELPERS)/$(POST_BUILD_HOOK)"

push/%: DARGS?=
push/%: REPO?=$(DEFAULT_REPO)
push/%:
	REPO=$$(echo "$(REPO)" | sed 's:/*$$:/:' | sed 's:^\s*/*\s*$$::') &&\
	echo "Pushing the following tags for $${REPO}$(notdir $@) (all tags)" &&\
	docker images $${REPO}$(notdir $@) --format="{{ .Tag }}" &&\
	docker push --all-tags $(DARGS) "$${REPO}"$(notdir $@)
