test:
	docker build --target test -t tests . && docker run --rm tests -v
