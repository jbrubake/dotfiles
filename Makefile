.PHONY: install notes todo fixme xxx

install:
	./install.sh -V

notes: todo fixme xxx
	@# Prints out all TODO, FIXME and XXX comments

todo:
	-@grep -r -H 'TODO:[[:blank:]]' | sed -e 's/:.*TODO/: TODO/'
fixme:
	-@grep -r -H 'FIXME:[[:blank:]]' | sed -e 's/:.*TODO/: TODO/'
xxx:
	-@grep -r -H 'XXX:[[:blank:]]' | sed -e 's/:.*TODO/: TODO/'
