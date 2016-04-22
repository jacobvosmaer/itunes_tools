all:
	xcodebuild -alltargets

clean:
	rm -rf build

install:	all
	cp $(shell find build/Release/ -maxdepth 1 -type f) /usr/local/bin/
