ogen = ${Overture}/bin/ogen



bubble:
	$(ogen) -noplot freeSurfaceDropGrid -interp=e -radx=1. -rady=1.25 -factor=2 
	$(ogen) -noplot freeSurfaceDropGrid -interp=e -radx=1. -rady=1.25 -factor=4
	$(ogen) -noplot freeSurfaceDropGrid -interp=e -radx=1. -rady=1. -prefix=oscillatingBubbleGrid -factor=2 
	$(ogen) -noplot freeSurfaceDropGrid -interp=e -radx=1. -rady=1. -prefix=oscillatingBubbleGrid -factor=4
	$(ogen) -noplot freeSurfaceDropGrid -interp=e -radx=1. -rady=1. -prefix=oscillatingBubbleGrid -factor=8
	$(ogen) -noplot freeSurfaceDropGrid -interp=e -radx=1. -rady=1. -prefix=oscillatingBubbleGrid -factor=16

ins:
	cd ../../; \
	make
