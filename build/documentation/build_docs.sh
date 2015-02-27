#!/bin/sh

# See cat << HEREDOC for file description.


# Set this to the complete path of the tidy for which you want to generate
# documentation. Relative path is okay. You shouldn't have to change this
# too often if your compiler always puts tidy in the same place.

TIDY_PATH="./tidy5"         # Current directory.


cat << HEREDOC

  Build 'tidy.1', which is a man page suitable for installation
  in all Unix-like operating systems. This script will build
  it, but not install it.
  
  Build 'quickref.html'. This is distributed with the
  the Tidy source code and also used on Tidy's website.
  Be sure to distribute it with 'quickref.css' as well.

  Build the 'tidylib_api' directory, which contains a website
  with the documentation for TidyLib’s headers.
  
  These files will be built into '{current_dir}/temp'.
  
HEREDOC


# Output and flags' declarations.
DOXY_CFG="doxygen.cfg"
OUTP_DIR="temp"
BUILD_XSLT=1
BUILD_API=1


##
# Ensure the output dir exists.
##
if [ ! -d "$OUTP_DIR" ]; then
	mkdir $OUTP_DIR
fi


##
# Preflight
##

# Check for a valid tidy.
if [ ! -x "$TIDY_PATH" ]; then
  BUILD_XSLT=0
  echo "- '$TIDY_PATH' not found. You should set TIDY_PATH in this script."
fi

# Check for xsltproc dependency.
hash xsltproc 2>/dev/null || { echo "- xsltproc not found. You require an XSLT processor."; BUILD_XSLT=0; }


##
# Build 'quickref.html' and 'tidy.1'.
##

if [ "$BUILD_XSLT" -eq 1 ]; then
	# Use the designated tidy to get its config and help.
	# These temporary files will be cleaned up later.
	$TIDY_PATH -xml-config > "tidy-config.xml"
	$TIDY_PATH -xml-help > "tidy-help.xml"

	# 'quickref.html'
	xsltproc "quickref.xsl" "tidy-config.xml" > "$OUTP_DIR/quickref.html"

	# 'tidy.1'
	xsltproc "tidy1.xsl" "$tidy-help.xml" > "$OUTP_DIR/tidy.1"

	# Cleanup - Note: to avoid issues with the tidy1.xsl finding the tidy-config.xml
	# document, they are created and read from the source directory instead of temp.
	rm "tidy-config.xml"
	rm "tidy-help.xml"
	
	echo "'quickref.html' and 'tidy.1' have been built.\n"
else
  echo "* tidy.1 was skipped because not all dependencies were satisfied."
fi


##
# Preflight
##

# Check for the doxygen.cfg file.
if [ ! -f "$DOXY_CFG" ]; then
  BUILD_API=0
  echo "- 'DOXY_CFG' not found. It is required to configure doxygen."
fi

# Check for doxygen dependency.
hash doxygen 2>/dev/null || { echo "- doxygen not found. This script requires doxygen."; BUILD_XSLT=0; }


##
# Build the doxygen project.
##

if [ "$BUILD_API" -eq 1 ]; then
  echo "The following is doxygen's stderr output. It doesn't indicate errors with this script:\n"
  doxygen "$DOXY_CFG" > /dev/null
  echo "\nTidyLib API documentation has been built."
else
  echo "* $OUTP_DIR/tidylib_api/ was skipped because not all dependencies were satisfied."
fi


##
# Done
##

echo "\nDone.\n"

