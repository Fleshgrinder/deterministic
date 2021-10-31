MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables
MAKEFLAGS += --no-print-directory
MAKEFLAGS += --warn-undefined-variables

.DELETE_ON_ERROR:
.SILENT:

export LC_ALL := C

PROTO_VERSIONS ?= $(shell bin/get-proto-versions)
PROTO_LANGUAGES ?= java

check: build/proto/report.txt
	cat build/proto/report.txt

clean::
	rm -fr build/

jdk: build/jdk
build/jdk: JDK_VERSION ?= 11
build/jdk:
	bin/get-jdk '$(JDK_VERSION)'

proto-compilers: $(foreach PROTO_VERSION,$(PROTO_VERSIONS),build/proto/$(PROTO_VERSION)/protoc)
build/proto/%/protoc:
	bin/get-proto-compiler '$(*F)'

proto-jars: $(foreach PROTO_VERSION,$(PROTO_VERSIONS),build/proto/$(PROTO_VERSION)/proto.jar)
build/proto/%/proto.jar:
	bin/get-jar 'com.google.protobuf' 'protobuf-java' '$(*F)'

proto-code: $(foreach PROTO_VERSION,$(PROTO_VERSIONS),build/proto/$(PROTO_VERSION)/code)
build/proto/%/code: build/proto/%/protoc
	bin/gen-proto-code '$(*F)' $(PROTO_LANGUAGES)

proto-compile: $(foreach PROTO_VERSION,$(PROTO_VERSIONS),$(foreach PROTO_LANGUAGE,$(PROTO_LANGUAGES),build/proto/$(PROTO_VERSION)/target/$(PROTO_LANGUAGE)))
build/proto/%/target/java: build/jdk build/proto/%/protoc build/proto/%/proto.jar build/proto/%/code
	bin/compile-proto-java '$(*F)'

proto-run: $(foreach PROTO_VERSION,$(PROTO_VERSIONS),$(foreach PROTO_LANGUAGE,$(PROTO_LANGUAGES),build/proto/$(PROTO_VERSION)/$(PROTO_LANGUAGE).bin))
build/proto/%/java.bin: build/proto/%/target/java
	bin/run-proto-java '$(*F)'

build/proto/report.txt: $(foreach PROTO_VERSION,$(PROTO_VERSIONS),$(foreach PROTO_LANGUAGE,$(PROTO_LANGUAGES),build/proto/$(PROTO_VERSION)/$(PROTO_LANGUAGE).bin))
	bin/test-proto >'$(@)'
