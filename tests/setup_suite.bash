setup_suite() {
    export FIXFOLDER="${BATS_TEST_DIRNAME}/../fixfolder.sh"
    export TEST_DIR="${BATS_TEST_DIRNAME}/fixtures"
    export SFO_DRY_RUN="false"

    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"

    touch "$TEST_DIR"/photo.jpg
    touch "$TEST_DIR"/report.pdf
    touch "$TEST_DIR"/video.mp4
    touch "$TEST_DIR"/song.mp3
    touch "$TEST_DIR"/archive.zip
    touch "$TEST_DIR"/script.sh
    touch "$TEST_DIR"/notes.txt
    touch "$TEST_DIR"/data.csv
    touch "$TEST_DIR"/config.json
    touch "$TEST_DIR"/readme.md
    touch "$TEST_DIR"/page.html
    touch "$TEST_DIR"/logo.svg
    touch "$TEST_DIR"/font.ttf
    touch "$TEST_DIR"/backup.bak
    touch "$TEST_DIR"/torrent.torrent
    touch "$TEST_DIR"/unknown.xyz
    touch "$TEST_DIR"/Makefile
}

teardown_suite() {
    rm -rf "$TEST_DIR"
}
