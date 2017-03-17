#!/bin/sh

######
# usage: dl_safari_f4f.sh <fragment start id> <fragment end id> <output filename> <base url>
######

CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

WGET_OPT='--quiet --tries=10 --timeout=30 --progress=bar:force:noscroll --show-progress'
WGET_TMPDIR='./~tmp/'

ID_START=$1
ID_END=$2
MERGED_OUTPUT_FILENAME=$3
URL_TEMPLATE=$4
# Sample URL:
# URL_TEMPLATE="http://kalhlspd-a.akamaihd.net/lhds/p/1926081/sp/192608100/serveFlavor/entryId/0_clivumvv/v/2/flavorId/0_,z4ahhhoo,8ts1np41,jq60wcx5,vvddzfjt,9axy3fln,/forceproxy/true/name/a.mp4.urlset/frag-f5-v1-a1-Seg1-Frag"

######
# Check required parameters
if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ] || [ "$4" == "" ]; then
    echo "Error: Insufficient parameters"
    echo "usage: dl_safari_f4f.sh <fragment start id> <fragment end id> <output filename> <base url>"
    exit 1
fi

######
# Trim URL
# If input URL is not trimmed proper,try to calculate the proper length and trim it
# URL original:   http://kalhlspd-a.akamaihd.net/lhds/p/1926081/sp/192608100/serveFlavor/entryId/0_xtwmf5cl/v/2/flavorId/0_,yfg1nmd3,xu1xl4zh,jxi2x8kh,syesyjcd,fov491pa,/forceproxy/true/name/a.mp4.urlset/frag-f5-v1-a1-Seg1-Frag131?als=0.53,1.34,6.79,4,245,2250,30,149,0,17,f,779.44,786.52,f,u,JHONPJCDIHCR,3.1.0,17&hdcore=3.1.0&plugin=aasp-3.1.0.43.124
# URL after trim: http://kalhlspd-a.akamaihd.net/lhds/p/1926081/sp/192608100/serveFlavor/entryId/0_xtwmf5cl/v/2/flavorId/0_,yfg1nmd3,xu1xl4zh,jxi2x8kh,syesyjcd,fov491pa,/forceproxy/true/name/a.mp4.urlset/frag-f5-v1-a1-Seg1-Frag
NUMBER_OFFSET_IN_URL=`expr "$URL_TEMPLATE" : ".*-Frag[0-9]"`
if [ "$NUMBER_OFFSET_IN_URL" != "0" ]; then
    #echo "Try to trim the URL"
    URL_PROPER_LENGTH=`expr ${NUMBER_OFFSET_IN_URL} - 1`
    #echo $URL_PROPER_LENGTH
    URL_TEMPLATE=${URL_TEMPLATE:0:$URL_PROPER_LENGTH}
#else
    #echo "No need to trim the URL."
fi
echo "URL after proper trim:"
echo $URL_TEMPLATE
#exit 0

######
# Make temporary download directory
WGET_TMPDIR="./~${MERGED_OUTPUT_FILENAME}/"
if [ -d "$WGET_TMPDIR" ]; then
    echo "Error: Temporary dir \"$WGET_TMPDIR\" exists.Please remove it before starting your new downloading task."
    exit 2
fi
mkdir -p "$WGET_TMPDIR"
#exit 0

######
# Fetch video fragments
for i in $(seq $ID_START $ID_END); do
    CONCAT_URL="$URL_TEMPLATE$i"
    DL_OUTPUT_FILENAME="$WGET_TMPDIR$i.f4f"

    #echo $CONCAT_URL

    # Download using wget and remove empty file if 404 error occurred
    wget $WGET_OPT -O "$DL_OUTPUT_FILENAME" "$CONCAT_URL" || rm -f "$DL_OUTPUT_FILENAME"

    # Download using curl
    #curl -f $CONCAT_URL -o $DL_OUTPUT_FILENAME
done
#exit 0

######
# Use AdobeHDS.php script to concat f4f files to flv video
cd "$WGET_TMPDIR"
php ../AdobeHDS.php --outfile "../$MERGED_OUTPUT_FILENAME"
cd "$CURR_DIR"
#exit 0

######
# Remove temporary dir
rm -rf "$WGET_TMPDIR"
#exit 0
