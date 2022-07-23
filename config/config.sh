#!/bin/bash

# locate saxon jar file
# sax_jar=lib/saxon9he.jar
sax_jar=~/TEI-to-PDF-1.1.1/lib/saxon.jar # DH2022 Ubuntu 20.04 env

# locate FOP base directory
# fop_lib=lib/fop-1.1
fop_lib=~/TEI-to-PDF-1.1.1/lib/fop # DH2022 Ubuntu 20.04 env

# additional options for FOP processing (sent to the java process)
#   -d64: optimization for 64 bit processor
#   -Xmx3000m: sets the maximum available memory allocation pool to 3000 MB
# Note: It's safe to leave this variable blank
# fop_opts="-d64 -Xmx3000m"
fop_opts="-Xmx3000m" # DH2022 Ubuntu 20.04 env (Unrecognized option: -d64)

# these variables shouldn't need to be changed, they are relative to fop_lib
fop_bin=${fop_lib}/fop
fop_conf=tei2pdf/fop.xconf # DH2022 Ubuntu 20.04 env

fo_obj=output/pdf.fo
pdf_obj=output/pdf.pdf

tei_xsl=tei2pdf/TEIcorpus_producer.xsl # DH2022 Ubuntu 20.04 env
xslfo_xsl=tei2pdf/xsl-fo-producer.xsl # DH2022 Ubuntu 20.04 env
init_xml=tei2pdf/empty.xml # DH2022 Ubuntu 20.04 env
final_xml=output/Book_Corpus.xml

# further options that may be useful

# cleanup transitional files when finished
cleanup=false
