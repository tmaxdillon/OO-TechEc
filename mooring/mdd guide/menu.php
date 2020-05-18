<HTML> <HEAD> <title>Mooring Design and Dynamics:  Files</title> </HEAD>

<BODY BACKGROUND="texture.bmp" TEXT="#000000" LINK="#0000FF" VLINK="#6600AA" ALINK="#FF0000"
BGCOLOR="#FFFFFF"  > <font face="Times Roman" size="+1">

<center><font size="+3"><b><font color="red">M</font>ooring <font color="red">D</font>esign
&#38 <font color="red">D</font>ynamics Files</font><br> <font size=+1>A <a
href="http://www.mathworks.com">Matlab&#174</a> Package for Designing and Analyzing Oceanographic
Moorings<br> <br><A HREF="/rkd/">Richard K. Dewey</a> <br>Centre for Earth
and Ocean Research <br>University of Victoria, BC, Canada <br><A
HREF="&#109;&#097;&#105;&#108;&#116;&#111;:rdewey&#064;&#117;&#118;&#105;&#099;&#046;&#099;&#097;">RDewey@UVic.CA</A> </b></font></center> <br> <hr>
<p align="justify">
<img src="mdd.gif" width="100" height="290" hspace=10 align="left">
<img src="tow.gif" width="233" height="293" hspace=10 align="right">
<a href="/rkd/mooring/moordyn.php">Mooring Design and Dynamics</a> is a set of
Matlab&#174 routines that
can be used to assist in the design and configuration of single point oceanographic moorings, the
evaluation of mooring tension and shape under the influence of wind and currents, and the simulation
of mooring component positions when forced by time dependant currents. Version 2.0 (June 9, 2000) also includes
the capability of predicting the shape (depth, wire length,...) associated with towed bodies. Version 2.1 included
"clamp-on" components that attached to the mooring wire/line. The <i>static</i>
model will predict the tension and tilt at each mooring component, including the anchor, for which the safe mass
will be evaluated in terms of the vertical and horizontal tensions. Predictions can be saved to
facilitate mooring motion correction. Time dependant currents can be entered to predict the
<i>dynamic</i> response of the mooring. For a towed body, the user can specify a fixed wire length and predict
the depth given a current profile and ship velocity, or request a desired depth, and have MD&D predict the
required wire length. The package includes a preliminary database of standard
mooring components which can be selected from pull down menus. Databases can be edited and
expanded to include user specific components, frequently used fasteners/wires etc., or unique
oceanographic instruments. Once designed and tested, a draft of the mooring components can be plotted
and a list of components, including fasteners can be printed.
<br><br>
Version 2.2 includes a completely re-done formulation of the form and lift drag calculations. The older versions are nearly correct,
but were not invariant to a rotation of the currents. Ugh! The re-formulated code (v2.2) is cleaner and more accurately represents
the lift force terms described in section 3-11 of Hoerner (1965), and is invariant to the direction of the currents!
The new formulation was updated in both moordyn.m and towdyn.m for both moorings and towed bodies.
Solutions/values are very slightly different than the older (published) values.
Version (2.1.2) includes a user contributed improved convergence algorithm to help sheared current simulations.
Many people have worked on this code since I released it in 1998. Some have found bugs, others made improvements/enhancements.
I would like to hear from all users as to the value of this program and/or any improvements you can
think of/contribute. However, I have long sinced moved on to other research projects (i.e. <a href="http://VENUS.uvic.ca/">VENUS</a>),
and have had little time to implement the many suggestions made with respect to MD&D. Although I may respond to emails, help get the code
working (corrected), even test certain mooring configurations, this software is provided "as is", without support.
</p><br clear="left"> <hr>

<h3>The FTP Files: Version 2.2, April 4, 2009</h3>
<li><a href="ftp://canuck.seos.uvic.ca/matlab/mooring/mdd.zip">MDD.ZIP</a> The complete PC zipped program file
including example mooring movies (V2.2) 1.8MB.</li>
<li><a href="ftp://canuck.seos.uvic.ca/matlab/mooring/mddlite.zip">MDDLite.ZIP</a> The PC zipped program file
without example movies (V2.2). 700KB</li>
<li><a href="ftp://canuck.seos.uvic.ca/matlab/mooring/mddlite.exe">MDDLite.EXE</a> The PC self extracting zipped
program file without example movies (V2.2). 700KB</li>
<li><a href="ftp://canuck.seos.uvic.ca/matlab/mooring/mdddoc.zip">MDDdoc.ZIP</a> The PC zipped Users Guide
file (V2.1). 800KB</li>
<li><a href="ftp://canuck.seos.uvic.ca/matlab/mooring/mdd.tar">MDD.tar</a> The UNIX/LINUX tar archive
program file (V2.2). 1MB (without example movies)</li>
<li><a href="ftp://canuck.seos.uvic.ca/matlab/mooring/mdd.tar.gz">MDD.tar.gz</a> The LINUX tarred and g-zipped
program file (V2.2). 700kB (without example movies)</li>
<li><a href="ftp://canuck.seos.uvic.ca/matlab/mooring/mdddoc.tar">MDDdoc.tar</a> The UNIX tarred Users Guide
file (V1.1). 1.1MB</li>
<li><a href="ftp://canuck.seos.uvic.ca/matlab/mooring/mdd.pdf">MDD.pdf</a> The PDF (printable) version of the
Users Guide (V1.1). 2.6MB</li>
</b></font>
<hr>
<h3>Installation</h3>
<p align="justify">
There are two archive files associated with MD&D. The program files are archived in <b>mdd.zip</b> (or
<b>mdd.tar.Z/gz</b> for Unix/LINUX systems). The <a href="/rkd/mooring/mdd/mdd.php"><font
size="+1">Users Guide</a></font> (documentation) is archived in <b>mdddoc.zip</b>
(or <b>mdddoc.tar</b>). These archives should be expanded into subdirectories under Matlab. The program files
should be expracted into:<br>
/matlab/toolbox/local/mdd/*.*<br>
Then this path needs to be added and saved to your Matlab path using the add/path functions from the menus
available from the top of the Matlab command window. MD&D can be started by typing "moordesign" at the MATLAB
command prompt.</p>

<p align="justify">
The <a href="/rkd/mooring/mdd/mdd.php"><font
size="+1">Users Guide</a></font> files (mdddoc.zip) should be extracted into:<br>
/matlab/help/local/mdd/*.*<br>
The Users Guide will then be accessible from within Matlab by typing "mdd".
</p>

<p align="justify">To start MD&D, type
"moordesign" at the Matlab command prompt. To view the Users Guide, load the "mdd.html" file into your web
browser (Internet Explorer works better than Netscape (keep re-loading until it looks right)), or type "mdd"
at the Matlab command prompt.</p>

Return to <a href="/rkd/mooring/moordyn.php">Mooring Design and Dynamics</a> Home
Page.<br>
Or go to the online <a href="/rkd/mooring/mdd/mdd.php">Users Guide</a> Page.<br>

</font><hr>
     <?php

	 //The file where number of hits will be saved;
	  $counterfile = "countermenu.txt";

	 // Opening the file; number of hit is stored in variable $hits
	  $fp = fopen($counterfile, "r");
	  $hits = fread($fp, 1024);
	  fclose($fp);

	 //increasing number of hits
	  $hits = $hits + 1;
     //saving number of hits
	  $fp = fopen($counterfile, "w");
	  fwrite($fp, $hits);
	  fclose($fp);

	 //display hits
	 echo "<p><center>You are visitor " .$hits. " since 1/12/98.</center></p>";

	 ?>

<I>Last modified April 4, 2009.<br> Questions and comments are welcome, <A
HREF="&#109;&#097;&#105;&#108;&#116;&#111;:rdewey&#064;&#117;&#118;&#105;&#099;&#046;&#099;&#097;">Richard Dewey</A> </I>
