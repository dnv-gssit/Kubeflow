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

# Default labels
DEFAULT_REPO := kubeitglobalsvcauxacrwe.azurecr.io

DEFAULT_PORT := 8888
DEFAULT_NB_PREFIX := /notebook/username/notebookname

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


