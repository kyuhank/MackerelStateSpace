all: ModelFitted.RData

ModelFitted.RData: setup.R
	Rscript setup.R

docker:
	docker build -t $(IMAGE) .
	docker push $(IMAGE)

local:
	docker run -it --rm -w /work -v "$$PWD":/work \
    --net=host \
    -e DISPLAY=$$DISPLAY \
    -e RUN= \
    -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0 \
    -u $$(id -u):$$(id -g) ${IMAGE} bash
