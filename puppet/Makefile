
LOCALENV=docker/05_localenv.docker
CONTAINER=puppetmaster
REPOSITORY=cmminc/puppetmaster


.PHONY: bump_revision build


Dockerfile: Dockerfile.in docker/* ${LOCALENV}
	perl -MFile::Slurp -ne 'print /^INCLUDE\s*(.*)/ ? read_file("$$1") : $$_' $< >$@

build: Dockerfile
	docker build --rm -t ${CONTAINER} .
	docker images | perl -ne'print if 1==$$. or /${CONTAINER}/'

commit: bump_revision
	docker build --rm -t ${REPOSITORY}:r$$(cat revision) .
	docker images | perl -ne'print if 1==$$. or /${REPOSITORY}/'

${LOCALENV}:
	touch ${LOCALENV}

revision:
	echo 0 > revision

bump_revision: revision
	expr 1 + $$(cat revision) > revision
