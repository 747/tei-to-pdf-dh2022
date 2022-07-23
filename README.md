TEI to PDF book creator
==================

About: This set of scripts will take TEI encoded XML files and process them into a PDF. The scripts were originally created for the Digital Humanities 2013 conference book of abstracts, which can be downloaded from: http://dh2013.unl.edu/abstracts/. Some sample XML has been included for testing, but all contents are the property of the respective authors. 

Much more work needs to be done to generalize this to other TEI book projects, but it is a start!

These scripts have been tested on Apple computers running OSX v 10.6-10.9 with at least 4 GB of memory. 

Step 0: Check out or download files from github
===============================================

You'll get a folder with a name like "TEI-to-PDF-master." All other instructions refer to this folder as the starting place.

Step 1: Set up your environment
=======================

1a: Download Saxon
-------------------------

Download Saxon HE from [The Saxon Sourceforge page](http://saxon.sourceforge.net/) and place it in the PDF maker folder. Code has been tested with Saxon 8 B and Saxon 9.5 HE. 

Change name of saxon jar file to "saxon.jar," or change in the code below to match your download (it will be something like "saxon9he.jar")

Place saxon.jar in the root of your TEI-to-PDF folder, or change the commands below to reference where you keep Saxon.

1b: Download and configure the FO processor
----------------------------------------

Download the FOP Binary files from [The Apache FOP Page](http://xmlgraphics.apache.org/fop/). Rename extracted folder "fop" and place inside the "lib" folder, or change the commands below to reference where you keep the FO processor. Scripts have been tested with FOP 1.0 and 1.1.

#### Change the conf file

The conf file can be found in /lib/fop/conf/fop.xconf

This change will let you register all the fonts on your system or in a particular directory so you don't have to specify each one.

Place the following inside the &lt;renderer mime="application/pdf">/&lt;fonts> tags:

	<directory recursive="true">/Library/Fonts</directory>
	<auto-detect/>
	
(This was at line 81 in the version 1.1 conf file.)

#### Increase memory

If you are creating a large book, you may need to increase the memory FOP uses to process the book. For the Digital Humanities 2013 conference book, which was 575 pages, I needed to increase it as below:

in the fop script located at /lib/fop/fop, find the line that looks like this:

	fop_exec_command="exec \"$JAVACMD\" $java_exec_args $LOGCHOICE $LOGLEVEL -classpath \"$LOCALCLASSPATH\" $FOP_OPTS org.apache.fop.cli.Main $fop_exec_args"
	
(line 251 in FOP 1.1) 

and replace it with this

	fop_exec_command="exec \"$JAVACMD\" -d64 -Xmx3000m $LOGCHOICE $LOGLEVEL -classpath \"$LOCALCLASSPATH\" $FOP_OPTS org.apache.fop.cli.Main $fop_exec_args"
	
(replace $java_exec_args with -d64 -Xmx3000m)

See [The FOP section on memory usage](http://xmlgraphics.apache.org/fop/1.1/running.html#memory)  for more information. Optimization of this code would probably make it unnecessary to increase memory.

1c: File structure
--------------------

The final file structure before you run anything should look like this: 

* empty.xml
* input (folder)
    * images (folder)
    * xml (folder)
* lib (folder)
	* fop (folder)
    * saxon.jar
* README.txt
* run.sh
* saxon.jar
* TEIcorpus_producer.xsl
* xsl-fo-producer.xsl

1d: Prepare your Files
--------------------------

#### TEI

All the TEI must be P5 and categorized into Paper, Panel, or Poster so the book can generate the proper headings. 

Example code (to be placed inside the teiHeader): 

	<profileDesc>
		<textClass>
			<keywords scheme="original" n="category">
				<term>Poster</term>
			</keywords>
			<keywords scheme="original" n="subcategory">
				<term></term>
			</keywords>
			<keywords scheme="original" n="topic">
				<term></term>
			</keywords>
			<keywords scheme="original" n="keywords">
				<term></term>
			</keywords>
		</textClass>
	</profileDesc>

Some of the panel papers were done as TEI Corpus files, so the code reflects that. The code should still work if the panels are done as regular TEI files.

Make sure the xml:id matches the document name and is unique! E.G. ab-002.xml must have an xml:id of ab-002. 

TEI Filenames are not used for categorization, the code uses the category in the header file (as above) to place the content in the correct category.

#### Images

Change all file paths to local, and leave out the extension (.jpg is added by default in the xsl, this can be modified to .png or whatever your image file format is.)

E.G. "path/to/image/image001.jpg" should be simply "image001"

1e: Set your configuration options
-----------------------------------------

In the /xsl-fo-producer.xsl file are several options for setting up how you would like your book to look. 

#### Print or web?

The variable

	<xsl:variable name="output">
	
will let you set whether you intend to create a PDF for printing (print) or for electronic distribution (pdf). Some of the differences include:

* Color: The print version does not use color for headings, etc., and will pull a black and white optimized version of the logo. We left the paper illustrations in color and they simply printed in grayscale.
* Margins: The print version of the book has different margins for left and right to accommodate the gutter. The PDF version has the same margins on both sides to make it easier to read. Note: you should make sure all margins add up to the same between print and PDF versions so the page count will remain the same.
* Cover: The PDF/web distributed version includes the covers for aesthetic purposes. For the print version, we prepared cover designs as illustrator files and gave them to the printer. 

#### Print paper ID's?

The variable

	<xsl:variable name="id">
	
is used to display or not display the paper ID's (pulled from the xml:id). This should be "no" for final preparation of files, but having it on  (yes) during the proofing process is very handy.

#### Other Options

All other options, including header colors, font color, size, and decoration, page and margin sizes, etc. should be set near the top in the "Attribute sets" portion of the file. 

Some notes: 

* We used special coding for different languages and math formulas in order to render them in certain fonts. In the TEI, this looked like this: &lt;hi rend="Hebrew">
* All sizes are currently in inches, so will need to be reconfigured for metric use.
* The ISBN is set in this file, because it will be different for print or ebook.

The file TEIcorpus_producer.xsl should also be  altered with your information, especially in the template "TEICorpusHeader."

Step 2: Run Files
============

Command line instructions are below. 

1: Place all files and images in input/xml and input/images, respectively

1b. Open a terminal and change directory (cd command) to the book creator root folder. 

2: Create the Book_Corpus.xml corpus file with the TEIcorpus_producer.xsl XSL with this command:

	 java -jar saxon.jar empty.xml TEIcorpus_producer.xsl > Book_Corpus.xml

This uses the saxon engine to transform all the XML in the final_xml folder into a TEI Corpus file called "Book_Corpus.xml"


3: Create the .fo file

	 java -jar saxon.jar Book_Corpus.xml xsl-fo-producer.xsl > pdf.fo

This creates a file called pdf.fo. Any errors (missing images, etc) will be exported to the screen. You may get a notice about missing fonts - this means either your font name is incorrect, or you have not set FOP to use your system fonts in the conf file (detailed above).


4: Create PDF

	 ./lib/fop/fop -c ./lib/fop/conf/fop.xconf pdf.fo pdf.pdf

If you get an out of memory error, see section on configuring FOP above.

You will likely get a bunch of font errors, but these may or may not matter. Check your final file to make sure all characters display correctly. 

This will create the final PDF. 

#### Script

For your convenience, we have created a script to run everything at once, you can run this by typing ./run.sh. If this fails, running each step individually will give better error reporting.

