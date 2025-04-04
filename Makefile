IMAGE_NAME=daleyarborough/pops

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run -it -p 8888:8888 -p 8000:8000 $(IMAGE_NAME)

scan:
	trivy image $(IMAGE_NAME)

push:
	docker push $(IMAGE_NAME)
