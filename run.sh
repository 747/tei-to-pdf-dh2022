#!/bin/bash

if [[ -f 'config/config.sh' ]]; then
    source config/config.sh
fi

java -jar "${sax_jar}" "${init_xml}" "${tei_xsl}" > "${final_xml}" && \
java -jar "${sax_jar}" "${final_xml}" "${xslfo_xsl}" > "${fo_obj}" && \
FOP_OPTS="${fop_opts}" "${fop_bin}" -c "${fop_conf}" "${fo_obj}" "${pdf_obj}"

if "$cleanup"; then
    rm -f "${fo_obj}"
    rm -f "${final_xml}"
fi
