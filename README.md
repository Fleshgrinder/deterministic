# Deterministic

This project aims to verify if either Avro or Protobuf is breaking binary
compatibility, and thus is dangerous or outright unusable in the context of
Kafka record keys (for both partitioning and compaction) as claimed by various
sources.

    make -j -O

This will run all included tests.

> 🔥 I wrote this on my MacBook and did not invest any time into other platforms
> yet. If you want to run this on anything other than an Intel x86_64 MacBook
> you might run into trouble.

> 💡 Mac users have to install GNU tools for things to work:
> 
>     brew install bash make
>     gmake -j -O
