DB=../Databases

DBS=ergdb wikidb classesdb nfpadb

all:	${DBS}

ergdb:	getergdb
	./getergdb >$@
	wc -l $@

wikidb:	getwikidb
	./getwikidb >$@
	wc -l $@

classesdb:	getclasses
	./getclasses >$@
	wc -l $@

nfpadb:	ergdb
	processnfpa <ergdb >$@
	wc -l $@


install::	${DB}/ergdb ${DB}/wikidb ${DB}/classesdb ${DB}/nfpadb

${DB}/ergdb:	ergdb
	cp $> $@

${DB}/wikidb:	wikidb
	cp $> $@

${DB}/classesdb:	classesdb
	cp $> $@

${DB}/nfpadb:	nfpadb
	cp $> $@


clean::
	rm *.core

clobber::	clean
	rm -f ${DBS}

