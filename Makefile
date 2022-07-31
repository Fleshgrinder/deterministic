export LC_ALL := C
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables
MAKEFLAGS += --no-print-directory
MAKEFLAGS += --warn-undefined-variables
.DELETE_ON_ERROR:
.SILENT:

check: avro-report proto-report

clean::
	rm -f build/*/report.txt

cleaner::
	rm -fr build/

jdk: build/jdk
clean-jdk::
	rm -fr build/jdk
build/jdk: JDK_VERSION ?= 11
build/jdk:
	bin/get-jdk '$(JDK_VERSION)'

# ------------------------------------------------------------------------------ avro

AVRO_VERSIONS ?= $(shell bin/avro-versions)
AVRO_LANGUAGES ?= java

avro-compilers: $(foreach AVRO_VERSION,$(AVRO_VERSIONS),$(foreach AVRO_LANGUAGE,$(AVRO_LANGUAGES),build/avro/$(AVRO_VERSION)/compiler/$(AVRO_LANGUAGE)))
clean-avro-compilers:
	rm -fr build/avro/*/compiler
build/avro/%/compiler/java:
	bin/get-jar 'org.apache.avro' 'avro-tools' '$(*F)' '$(@)/tools.jar'

avro-jars: $(foreach AVRO_VERSION,$(AVRO_VERSIONS),build/avro/$(AVRO_VERSION)/avro.jar)
clean-avro-jars::
	rm -f build/avro/*/avro.jar
build/avro/%/avro.jar: build/avro/jackson.jar
	bin/get-jar 'org.apache.avro' 'avro' '$(*F)' '$(@)'
build/avro/jackson.jar:
	bin/get-jar '' '' '' '$(@)'

avro-code: $(foreach AVRO_VERSION,$(AVRO_VERSIONS),$(foreach AVRO_LANGUAGE,$(AVRO_LANGUAGES),build/avro/$(AVRO_VERSION)/code/$(AVRO_LANGUAGE)))
clean-avro-code::
	rm -fr build/avro/*/code
build/avro/%/code/java: build/avro/%/compiler/java
	bin/avro-gen-java '$(*F)'

avro-compile: $(foreach AVRO_VERSION,$(AVRO_VERSIONS),$(foreach AVRO_LANGUAGE,$(AVRO_LANGUAGES),build/avro/$(AVRO_VERSION)/target/$(AVRO_LANGUAGE)))
clean-avro-compile::
	rm -fr build/avro/*/target
build/avro/%/target/java: build/jdk build/avro/%/code/java build/avro/%/avro.jar
	bin/java-compile avro '$(*F)'

AVRO_BINS := $(foreach AVRO_VERSION,$(AVRO_VERSIONS),$(foreach AVRO_LANGUAGE,$(AVRO_LANGUAGES),build/avro/$(AVRO_VERSION)/$(AVRO_LANGUAGE).bin))

avro-run: $(AVRO_BINS)
clean-avro-run::
	rm -f build/avro/*/*.bin
build/avro/%/java.bin: build/avro/%/target/java
	bin/java-run avro '$(*F)'

avro-report: build/avro/report.txt
	cat '$(<)'
clean-avro-report::
	rm -f build/avro/report.txt
build/avro/report.txt: $(AVRO_BINS)
	bin/report avro >'$(@)'

clean-avro:: clean-avro-code clean-avro-compile clean-avro-run clean-avro-report
cleaner-avro:: clean-avro clean-avro-compilers clean-avro-jars

# ------------------------------------------------------------------------------ proto

PROTO_VERSIONS ?= $(shell bin/proto-versions)
PROTO_LANGUAGES ?= java

proto-compilers: $(foreach PROTO_VERSION,$(PROTO_VERSIONS),build/proto/$(PROTO_VERSION)/protoc)
clean-proto-compilers::
	rm -f build/proto/*/protoc
build/proto/%/protoc:
	bin/proto-compiler '$(*F)'

proto-jars: $(foreach PROTO_VERSION,$(PROTO_VERSIONS),build/proto/$(PROTO_VERSION)/proto.jar)
clean-proto-jars::
	rm -f build/proto/*/proto.jar
build/proto/%/proto.jar:
	bin/get-jar 'com.google.protobuf' 'protobuf-java' '$(*F)' '$(@)'

proto-code: $(foreach PROTO_VERSION,$(PROTO_VERSIONS),build/proto/$(PROTO_VERSION)/code)
clean-proto-code::
	rm -fr build/proto/*/code
build/proto/%/code: build/proto/%/protoc
	bin/proto-gen-code '$(*F)' $(PROTO_LANGUAGES)

proto-compile: $(foreach PROTO_VERSION,$(PROTO_VERSIONS),$(foreach PROTO_LANGUAGE,$(PROTO_LANGUAGES),build/proto/$(PROTO_VERSION)/target/$(PROTO_LANGUAGE)))
clean-proto-compile::
	rm -fr build/proto/*/target
build/proto/%/target/java: build/jdk build/proto/%/protoc build/proto/%/proto.jar build/proto/%/code
	bin/java-compile proto '$(*F)'

PROTO_BINS := $(foreach PROTO_VERSION,$(PROTO_VERSIONS),$(foreach PROTO_LANGUAGE,$(PROTO_LANGUAGES),build/proto/$(PROTO_VERSION)/$(PROTO_LANGUAGE).bin))

proto-run: $(PROTO_BINS)
clean-proto-run::
	rm -f build/proto/*/*.bin
build/proto/%/java.bin: build/proto/%/target/java
	bin/java-run proto '$(*F)'

proto-report: build/proto/report.txt
	cat '$(<)'
clean-proto-report::
	rm -f build/proto/report.txt
build/proto/report.txt: $(PROTO_BINS)
	bin/report proto >'$(@)'

clean-proto:: clean-proto-code clean-proto-compile clean-proto-report clean-proto-run
cleaner-proto:: clean-proto clean-proto-compilers clean-proto-jars
