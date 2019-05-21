README for Spec_preproc_v5

Rachel Cavill 2007

To install
==========

* Copy this directory onto your computer.
* Add this directory to your matlab path (file/set path)

To Test
=======

* I have included a directory called test.
* Navigate to this directory in matlab (so that directory name appears in the
current directory bar at the top of the window.
* type: edit options.txt
* Change the bruker path file to match the current directory
* Go back to the matlab prompt and type: spec_preproc_v5
* It should run and complete fine, whilst displaying a warning message about
spectrum number 939.
* It will have created the file rz_media2.mat - type: load('rz_media2.mat') to
load this file and view the contents.

To Run on your data
===================

* Copy options.txt from the test directory into the directory with your data.
* Navigate to that directory in Matlab
* type: edit options.txt
* Change the options as needed for the processing you want to do
* type: spec_preproc_v5

FAQ
===

* Why are all the files ending in .p rather than .m?
	Compiling matlab code to .p files is an easy way of making sure other users
	don't accidentally change the matlab code, as well as giving those of us who
	wrote the code more control over who sees the algorithms.  If you are
	interested in seeing the matlab code, or developping the program further
	yourself, contact me (Rachel: r.cavill@imperial.ac.uk).

* I've found a bug, what should I do?
	Email me! (Rachel: r.cavill@imperial.ac.uk), if possible also provide me with
	the spectrum which is causing the problem.
	
* There's a feature I'd like to see...
	If you already have matlab code for the feature, send me the code along with a
	description of how you normally run it, and I'll try to add it in to the next
	version.  Otherwise, email me (Rachel: r.cavill@imperial.ac.uk) with the 
	feature you'd like to see and I'll see what I can do! 
	
