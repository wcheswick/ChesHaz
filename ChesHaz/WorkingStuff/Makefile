DB=../Databases

DBS=ergdb wikidb classesdb nfpadb placarddb

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


placarddb:	ergdb
	fetchplacardinfo <ergdb >$@
	wc -l $@

Placards:	placarddb
	fetchplacards <$@
	ls Placards/* | wc -l

install::	${DB}/ergdb ${DB}/wikidb ${DB}/classesdb ${DB}/nfpadb \
		${DB}/placarddb ${DB}/Placards

${DB}/ergdb:	ergdb
	cp $> $@

${DB}/wikidb:	wikidb
	cp $> $@

${DB}/classesdb:	classesdb
	cp $> $@

${DB}/nfpadb:	nfpadb
	cp $> $@

${DB}/placarddb:	placarddb
	cp $> $@

${DB}/Placards:	Placards
	rsync -av Placards ${DB}/Placards

clean::
	rm *.core

clobber::	clean
	rm -f ${DBS}

