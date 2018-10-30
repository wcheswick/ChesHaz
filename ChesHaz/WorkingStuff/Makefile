DB=../Databases

DBS=ergdb wikidb nfpadb placarddb examplesdb # classesdb 

all::	${DBS}

fetcherg::
	rm -f ergdb
	make ergdb

fetchwiki::
	rm -f wikidb
	make wikidb

#not used
#fetchclasses::
#	rm -f classesdb
#	make classesdb

fetchnfpa::
	rm -f nfpadb
	make nfpadb

fetchplacstuff::
	rm -f placarddb
	rm -f Placards/*

fetchall::	fetcherg fetchwiki fetchnfpa fetchplacstuff # fetchclasses

# our basic list of chemicals
ergdb:	getergdb
	./getergdb >$@
	wc -l $@

wikidb:	getwikidb
	./getwikidb >$@
	wc -l $@

renewexamplesdb::
	./fetchallexamples -r ergdb >$@
	wc -l $@

examplesdb:
	./fetchallexamples ergdb >$@
	wc -l $@

# not used:
#classesdb:	getclasses
#	./getclasses >$@
#	wc -l $@

# This takes a long time:
nfpadb:	ergdb
	processnfpa <ergdb >$@
	wc -l $@

# This takes a long time
placarddb:	ergdb
	fetchplacardinfo <ergdb >$@
	wc -l $@

Placards:	placarddb
	fetchplacards <$@
	ls Placards/* | wc -l

install::	${DB}/ergdb ${DB}/wikidb ${DB}/classesdb ${DB}/nfpadb \
		${DB}/placarddb ${DB}/Placards ${DB}/examplesdb

${DB}/ergdb:	ergdb
	cp $> $@

${DB}/wikidb:	wikidb
	cp $> $@

#${DB}/classesdb:	classesdb
#	cp $> $@

${DB}/nfpadb:	nfpadb
	cp $> $@

${DB}/placarddb:	placarddb
	cp $> $@

${DB}/examplesdb:	examplesdb
	cp $> $@

${DB}/Placards:
	rsync -av Placards ${DB}/Placards

clean::
	rm *.core

clobber::	clean
	rm -f ${DBS}

