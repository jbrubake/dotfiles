.PHONY: install notes todo fixme xxx

install:
	./install.sh -V

notes: todo fixme xxx
	@# Prints out all TODO, FIXME and XXX comments

todo:
	-@grep 'TODO:[[:blank:]]'  $$(find . -not -path './.*' -type f) | sed -e 's/:.*TODO/: TODO/' -e 's@^./@@'
fixme:
	-@grep 'FIXME:[[:blank:]]' $$(find . -not -path './.*' -type f) | sed -e 's/:.*TODO/: TODO/' -e 's@^./@@'
xxx:
	-@grep 'XXX:[[:blank:]]'   $$(find . -not -path './.*' -type f) | sed -e 's/:.*TODO/: TODO/' -e 's@^./@@'
