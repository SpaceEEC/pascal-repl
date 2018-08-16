build:
	fpc -gs -MDelphi repl.pas
	rm repl.o

clean:
	-rm repl.exe
	-rm tmp.pas
	-rm tmp.o
	-rm tmp.exe