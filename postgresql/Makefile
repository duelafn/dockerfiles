
LOCALENV=../_includes/05_localenv.docker
CONTAINER=postgresql
REPOSITORY=cmminc/postgresql


.PHONY: bump_revision build


Dockerfile: Dockerfile.in ../_includes/* ${LOCALENV}
	perl -MFile::Slurp -ne 'print /^INCLUDE\s*(.*)/ ? read_file("$$1") : $$_' $< >$@

build: Dockerfile
	docker build --rm -t ${CONTAINER} .
	docker images | perl -ne'print if 1==$$. or m#${CONTAINER}#'

commit: build bump_revision
	docker tag -f ${CONTAINER} ${REPOSITORY}:latest
	docker tag -f ${CONTAINER} ${REPOSITORY}:r$$(cat revision)
	docker images | perl -ne'print if 1==$$. or m#${REPOSITORY}#'

${LOCALENV}:
	touch ${LOCALENV}

revision:
	echo 0 > revision

bump_revision: revision
	expr 1 + $$(cat revision) > revision
