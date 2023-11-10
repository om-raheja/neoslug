#!/bin/sh

usage() {
    printf "./gensite.sh [-h] BUILD-DIRECTORY\n"
    exit
}

write_header() {
    if [ ! -e "$OUTFILE" ]; then
	mkdir -p $(dirname "$OUTFILE")
    fi
    
    sed -E "s,IMAGES_DIR,$IMAGES,g" ../templates/header.html | \
	sed -E "s,RESOURCES_DIR,$RESOURCES,g" | \
	sed -E "s,ROOT,$REL_PATH,g" > $OUTFILE
}

write_doc() {
    cat $INFILE >> $OUTFILE
}

write_footer() {
    sed -E "s,IMAGES_DIR,$IMAGES,g" ../templates/footer.html | \
	sed -E "s,RESOURCES_DIR,$RESOURCES,g" >> $OUTFILE
}

relative() {
    if [ $DEPTH -eq 1 ]; then
	REL_PATH=""
    else
	REL_PATH=$(jot -b "../" -s "" $((DEPTH-1)))
    fi
}

BUILD_DIR="../slug"
SOURCE_DIR="../drafts"

while getopts b:d:h opt; do
    case $opt in
	b) BUILD_DIR="$OPTARG";;
	d) SOURCE_DIR="$OPTARG";;
	h) usage;;
      esac
done

if [ ! -d "$SOURCE_DIR" ]; then
    printf "Source directory not found!\n"
    exit 1
fi

if [ ! -e "$BUILD_DIR" ]; then
    mkdir "$BUILD_DIR"
elif [ ! -d "$BUILD_DIR" ]; then
  printf "Specified build directory is not a directory. Exiting.\n"
  exit 1
fi

cd "$SOURCE_DIR"

for i in $(find . -type f); do
    DEPTH=$(echo $i | grep -o '/' | grep -c .)
    relative
    IMAGES="$REL_PATH"images
    RESOURCES="$REL_PATH"resources
    INFILE="$i"
    OUTFILE="$BUILD_DIR/$i"
    
    write_header
    write_doc
    write_footer
done

cp -rp "../resources" "$BUILD_DIR"
cp -rp "../images" "$BUILD_DIR"
