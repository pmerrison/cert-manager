# Copyright 2023 The cert-manager Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

RELEASE_VERSION := $(shell git describe --tags --match='v*' --abbrev=14)

GITCOMMIT := $(shell git rev-parse HEAD)

IS_TAGGED_RELEASE := $(shell git describe --exact-match HEAD >/dev/null 2>&1 && echo "true" || echo "false")

IS_PRERELEASE := $(shell echo $(RELEASE_VERSION) | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+$$' - && echo "false" || echo "true")

.PHONY: gitver
gitver:
	@echo "Release version:   \"$(RELEASE_VERSION)\""
	@echo "Is tagged release: \"$(IS_TAGGED_RELEASE)\""
	@echo "Is prerelease:     \"$(IS_PRERELEASE)\""
	@echo "Git commit hash:   \"$(GITCOMMIT)\""

.PHONY: release-version
release-version:
	@echo "$(RELEASE_VERSION)"

# The file "release-version" gets updated whenever git describe --tags changes.
# This is used by the $(BINDIR)/containers/*.tar.gz targets to make sure that the
# containers, which use the output of "git describe --tags" as their tag, get
# rebuilt whenever you check out a different commit. If we didn't do this, the
# Helm chart $(BINDIR)/cert-manager-*.tgz would refer to an image tag that doesn't
# exist in $(BINDIR)/containers/*.tar.gz.
#
# We use FORCE instead of .PHONY because this is a real file that can be used as
# a prerequisite. If we were to use .PHONY, then the file's timestamp would not
# be used to check whether targets should be rebuilt, and they would get
# constantly rebuilt.
$(BINDIR)/release-version: FORCE | $(BINDIR)
	@test "$(RELEASE_VERSION)" == "$(shell cat $@ 2>/dev/null)" || echo $(RELEASE_VERSION) > $@

$(BINDIR)/scratch/git:
	@mkdir -p $@
