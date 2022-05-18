.PHONY: install notes todo fixme xxx

install:
	./install.sh -V

notes: todo fixme xxx
	@# Prints out all TODO, FIXME and XXX comments

note:
	-@grep -r -H NOTE: | sed -e 's/:.*NOTE/: NOTE/'
todo:
	-@grep -r -H TODO: | sed -e 's/:.*TODO/: TODO/'
fixme:
	-@grep -r -H FIXME: | sed -e 's/:.*TODO/: TODO/'
xxx:
	-@grep -r -H XXX: | sed -e 's/:.*TODO/: TODO/'
