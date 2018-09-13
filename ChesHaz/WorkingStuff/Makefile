DB=../Databases

DBS=ergdb wikidb classesdb # placarddb # nfpadb 

all:	${DBS}

fetcherg::
	rm -f ergdb
	make ergdb

fetchwiki::
	rm -f wikidb
	make wikidb

fetchclasses::
	rm -f classesdb
	make classesdb

fetchnfpa::
	rm -f nfpadb
	make nfpadb

fetchplacstuff::
	rm -f placarddb
	rm -f Placards/*

fetchall::	fetcherg fetchwiki fetchclasses \
		fetchnfpa fetchplacstuff

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
	# processnfpa <ergdb >$@
	wc -l $@


placarddb:	ergdb
	# fetchplacardinfo <ergdb >$@
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

${DB}/Placards:
	rsync -av Placards ${DB}/Placards

clean::
	rm *.core

clobber::	clean
	rm -f ${DBS}

