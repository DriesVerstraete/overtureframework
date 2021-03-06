#
#   Makefile for dielectric bodies
#


# ogen = /home/henshw/Overture.g/bin/ogen
ogen = $(Overture)/bin/ogen

# Make the documentation:
doc:
	pdflatex cgmxOpt
	bibtex cgmxOpt


getBib:
#	cp /Users/henshaw/papers/common/{henshaw.bib,henshawPapers.bib,fsi.bib} .
	cp /Users/henshaw/papers/common/{henshaw.bib,henshawPapers.bib} .
	bibClean henshawPapers.bib

# generate some grids
grids : grids2d grids3d

# 2D grids: 
grids2d: disk ellipse rod cross rectangle dielectricBlockGrid2d multiblock 

# 3D grids: 
grids3d: sphere pillbox


# Make a 2D rectangular region with no body (extra ghost needed for sosup)
rectangle:
	 $(ogen) -noplot rectangleArg -prefix=rect -order=2 -xa=-2 -xb=2 -ya=-.75 -yb=.75 -periodic=np -factor=4
	 $(ogen) -noplot rectangleArg -prefix=rect -order=2 -xa=-2 -xb=2 -ya=-.75 -yb=.75 -periodic=np -factor=8
	 $(ogen) -noplot rectangleArg -prefix=rect -order=4 -xa=-2 -xb=2 -ya=-.75 -yb=.75 -periodic=np -factor=4
	 $(ogen) -noplot rectangleArg -prefix=rect -order=4 -xa=-2 -xb=2 -ya=-.75 -yb=.75 -periodic=np -factor=8
	 $(ogen) -noplot rectangleArg -prefix=rect -order=2 -xa=-8 -xb=2 -ya=-.75 -yb=.75 -periodic=np -factor=4
	 $(ogen) -noplot rectangleArg -prefix=airSlabGrid -order=4 -xa=-4 -xb=4 -ya=-2 -yb=2 -periodic=np -factor=2
	 $(ogen) -noplot rectangleArg -prefix=airSlabGrid -order=4 -xa=-4 -xb=4 -ya=-2 -yb=2 -periodic=np -factor=4
	 $(ogen) -noplot rectangleArg -prefix=airSlabGrid -order=4 -xa=-4 -xb=4 -ya=-2 -yb=2 -periodic=np -factor=8
	 $(ogen) -noplot rectangleArg -prefix=channel -order=2 -xa=-3 -xb=3 -ya=-.5 -yb=.5 -periodic=np -factor=2
	 $(ogen) -noplot rectangleArg -prefix=channel -order=2 -xa=-3 -xb=3 -ya=-.5 -yb=.5 -periodic=np -factor=4
	 $(ogen) -noplot rectangleArg -prefix=channel -order=2 -xa=-3 -xb=3 -ya=-.5 -yb=.5 -periodic=np -factor=4
	 $(ogen) -noplot rectangleArg -prefix=noPecDisk -order=4 -xa=-3 -xb=3 -ya=-1.25 -yb=1.25 -periodic=np -factor=2
	 $(ogen) -noplot rectangleArg -prefix=noPecDisk -order=4 -xa=-3 -xb=3 -ya=-1.25 -yb=1.25 -periodic=np -factor=4
	 $(ogen) -noplot rectangleArg -prefix=noPecDisk -order=4 -xa=-3 -xb=3 -ya=-1.25 -yb=1.25 -periodic=np -factor=8


dielectricBlockGrid2d:
	 $(ogen) -noplot dielectricBlockGrid2d -interp=e -order=2 -periodic=np -factor=2
	 $(ogen) -noplot dielectricBlockGrid2d -interp=e -order=2 -periodic=np -factor=4
	 $(ogen) -noplot dielectricBlockGrid2d -interp=e -order=2 -periodic=np -factor=8
	 $(ogen) -noplot dielectricBlockGrid2d -interp=e -order=4 -periodic=np -factor=2 
	 $(ogen) -noplot dielectricBlockGrid2d -interp=e -order=4 -periodic=np -factor=4 
	 $(ogen) -noplot dielectricBlockGrid2d -interp=e -order=4 -periodic=np -factor=8 
	 $(ogen) -noplot dielectricBlockGrid2d -interp=e -order=4 -periodic=np -factor=2 -numGhost=3
	 $(ogen) -noplot dielectricBlockGrid2d -interp=e -order=4 -periodic=np -factor=4 -numGhost=3
	 $(ogen) -noplot dielectricBlockGrid2d -interp=e -order=4 -periodic=np -factor=8 -numGhost=3

# Multiple dielectric blocs
multiblock:
	$(ogen) -noplot dielectricMultiBlockGrid2d -numBlocks=2 -x1=-.25 -x2=.0 -x3=.25 -order=4 -interp=e -factor=2
	$(ogen) -noplot dielectricMultiBlockGrid2d -numBlocks=2 -x1=-.25 -x2=.0 -x3=.25 -order=4 -interp=e -factor=4
	$(ogen) -noplot dielectricMultiBlockGrid2d -numBlocks=2 -x1=-.25 -x2=.0 -x3=.25 -order=4 -interp=e -factor=8
	$(ogen) -noplot dielectricMultiBlockGrid2d -numBlocks=2 -x1=-.25 -x2=.0 -x3=.25 -order=4 -interp=e -factor=16


# LENS - curved dielectric block 
curvedBlock:
	$(ogen) -noplot curvedBlockGrid2d -prefix=convexBlockGrid -order=2 -interp=e -width=.25 -dxLeft=0 0 0 -.2 0 0 0 -dxRight=0 0 0 .2 0 0 0 -interfaceGridWidth=.4 -factor=2
	$(ogen) -noplot curvedBlockGrid2d -prefix=convexBlockGrid -order=2 -interp=e -width=.25 -dxLeft=0 0 0 -.2 0 0 0 -dxRight=0 0 0 .2 0 0 0 -interfaceGridWidth=.4 -factor=4
	$(ogen) -noplot curvedBlockGrid2d -prefix=convexBlockGrid -order=2 -interp=e -width=.25 -dxLeft=0 0 0 -.2 0 0 0 -dxRight=0 0 0 .2 0 0 0 -interfaceGridWidth=.4 -factor=8
	$(ogen) -noplot curvedBlockGrid2d -prefix=convexBlockGrid -order=4 -interp=e -width=.25 -dxLeft=0 0 0 -.2 0 0 0 -dxRight=0 0 0 .2 0 0 0 -interfaceGridWidth=.4 -factor=2
	$(ogen) -noplot curvedBlockGrid2d -prefix=convexBlockGrid -order=4 -interp=e -width=.25 -dxLeft=0 0 0 -.2 0 0 0 -dxRight=0 0 0 .2 0 0 0 -interfaceGridWidth=.4 -factor=4
	$(ogen) -noplot curvedBlockGrid2d -prefix=convexBlockGrid -order=4 -interp=e -width=.25 -dxLeft=0 0 0 -.2 0 0 0 -dxRight=0 0 0 .2 0 0 0 -interfaceGridWidth=.4 -factor=8

pecDisk:
	$(ogen) -noplot diskInAChannelGrid -xa=-3 -xb=3. -interp=e -order=2 -factor=2
	$(ogen) -noplot diskInAChannelGrid -xa=-3 -xb=3. -interp=e -order=2 -factor=4
	$(ogen) -noplot diskInAChannelGrid -xa=-3 -xb=3. -interp=e -order=2 -factor=8
	$(ogen) -noplot diskInAChannelGrid -xa=-3 -xb=3. -interp=e -order=4 -factor=2
	$(ogen) -noplot diskInAChannelGrid -xa=-3 -xb=3. -interp=e -order=4 -factor=4
	$(ogen) -noplot diskInAChannelGrid -xa=-3 -xb=3. -interp=e -order=4 -factor=8


disk:
	$(ogen) -noplot io -prefix=diskInBox -order=2 -interp=e -xa=-5.5 -xb=5.5 -ya=-.75 -yb=.75 -outerBC=yPeriodic -factor=4
	$(ogen) -noplot io -prefix=diskInBox -order=2 -interp=e -xa=-5.5 -xb=5.5 -ya=-.75 -yb=.75 -outerBC=yPeriodic -fact	$(ogen) -noplot io -prefix=diskInBox -order=4 -interp=e -xa=-5.5 -xb=5.5 -ya=-.75 -yb=.75 -outerBC=yPeriodic -factor=4
	$(ogen) -noplot io -prefix=diskInBox -order=4 -interp=e -xa=-5.5 -xb=5.5 -ya=-.75 -yb=.75 -outerBC=yPeriodic -factor=8
	$(ogen) -noplot io -prefix=diskInBox -order=2 -interp=e -xa=-5.5 -xb=5.5 -ya=-.75 -yb=.75 -outerBC=yPeriodic -fact	$(ogen) -noplot io -prefix=diskInBox -order=4 -interp=e -xa=-5.5 -xb=5.5 -ya=-.75 -yb=.75 -outerBC=yPeriodic -factor=4 -numGhost=3
	$(ogen) -noplot io -prefix=diskInBox -order=2 -interp=e -xa=-5.5 -xb=5.5 -ya=-.75 -yb=.75 -outerBC=yPeriodic -fact	$(ogen) -noplot io -prefix=diskInBox -order=4 -interp=e -xa=-5.5 -xb=5.5 -ya=-.75 -yb=.75 -outerBC=yPeriodic -factor=8 -numGhost=3

ellipse:
	$(ogen) -noplot shapedDiskGrid -shape=ellipse -prefix=ellipticalGrid -interp=e -factor=4
	$(ogen) -noplot shapedDiskGrid -shape=ellipse -prefix=ellipticalGrid -interp=e -factor=8
	$(ogen) -noplot shapedDiskGrid -shape=ellipse -prefix=ellipticalGrid -interp=e -order=4 -factor=8

rod:
	$(ogen) -noplot rodGrid2d -order=2 -interp=e -factor=4
	$(ogen) -noplot rodGrid2d -order=2 -interp=e -factor=8
	$(ogen) -noplot rodGrid2d -order=2 -interp=e -factor=16
	$(ogen) -noplot rodGrid2d -order=4 -interp=e -factor=8
	$(ogen) -noplot rodGrid2d -order=4 -interp=e -factor=16

cross:
	$(ogen) -noplot shapedDiskGrid -shape=cross -prefix=crossGrid -interp=e -order=2 -factor=16
	$(ogen) -noplot shapedDiskGrid -shape=cross -prefix=crossGrid -interp=i -order=4 -factor=16

sphere:
	$(ogen) -noplot solidSphereInABox -prefix=dielectricSphereGrid -xa=-3 -xb=3 -ya=-1.5 -yb=1.5 -za=-1.5 -zb=1.5 -outerBC=yzPeriodic -order=2 -interp=e -factor=2
	$(ogen) -noplot solidSphereInABox -prefix=dielectricSphereGrid -xa=-3 -xb=3 -ya=-1.5 -yb=1.5 -za=-1.5 -zb=1.5 -outerBC=yzPeriodic -order=2 -interp=e -factor=4
	$(ogen) -noplot solidSphereInABox -prefix=dielectricSphereGrid -xa=-3 -xb=3 -ya=-1.5 -yb=1.5 -za=-1.5 -zb=1.5 -outerBC=yzPeriodic -order=2 -interp=e -factor=8

pillbox:
	$(ogen) -noplot solidPillBoxGrid.cmd -interp=e -factor=4 


