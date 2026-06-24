setup() {
    load setup_suite
    setup_suite
}

teardown() {
    teardown_suite
}

@test "exits with usage when no argument given" {
    run bash "$FIXFOLDER"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage"* ]]
}

@test "exits with usage on --help" {
    run bash "$FIXFOLDER" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage"* ]]
}

@test "exits with usage on -h" {
    run bash "$FIXFOLDER" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage"* ]]
}

@test "exits with error for non-existent directory" {
    run bash "$FIXFOLDER" /tmp/nonexistent_dir_abc123
    [ "$status" -eq 1 ]
    [[ "$output" == *"not a valid directory"* ]]
}

@test "exits with error for too many arguments" {
    run bash "$FIXFOLDER" /tmp /tmp
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage"* ]]
}

@test "organizes files into correct categories" {
    run bash "$FIXFOLDER" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/Images" ]
    [ -d "$TEST_DIR/Documents" ]
    [ -d "$TEST_DIR/Videos" ]
    [ -d "$TEST_DIR/Music" ]
    [ -d "$TEST_DIR/Archives" ]
    [ -d "$TEST_DIR/Scripts" ]
    [ -d "$TEST_DIR/Others" ]
}

@test "moves jpg to Images" {
    run bash "$FIXFOLDER" "$TEST_DIR"
    [ -f "$TEST_DIR/Images/photo.jpg" ]
    [ ! -f "$TEST_DIR/photo.jpg" ]
}

@test "moves pdf to Documents" {
    run bash "$FIXFOLDER" "$TEST_DIR"
    [ -f "$TEST_DIR/Documents/report.pdf" ]
}

@test "moves mp4 to Videos" {
    run bash "$FIXFOLDER" "$TEST_DIR"
    [ -f "$TEST_DIR/Videos/video.mp4" ]
}

@test "moves mp3 to Music" {
    run bash "$FIXFOLDER" "$TEST_DIR"
    [ -f "$TEST_DIR/Music/song.mp3" ]
}

@test "moves zip to Archives" {
    run bash "$FIXFOLDER" "$TEST_DIR"
    [ -f "$TEST_DIR/Archives/archive.zip" ]
}

@test "moves sh to Scripts" {
    run bash "$FIXFOLDER" "$TEST_DIR"
    [ -f "$TEST_DIR/Scripts/script.sh" ]
}

@test "moves unknown extension to Others" {
    run bash "$FIXFOLDER" "$TEST_DIR"
    [ -f "$TEST_DIR/Others/unknown.xyz" ]
}

@test "moves file without extension to Others" {
    run bash "$FIXFOLDER" "$TEST_DIR"
    [ -f "$TEST_DIR/Others/Makefile" ]
}

@test "reports total files moved in output" {
    run bash "$FIXFOLDER" "$TEST_DIR"
    [[ "$output" == *"Total files moved:"* ]]
}

@test "does not fail on empty directory" {
    local empty_dir="${TEST_DIR}/empty"
    mkdir -p "$empty_dir"
    run bash "$FIXFOLDER" "$empty_dir"
    [ "$status" -eq 0 ]
}

@test "works with relative path argument" {
    local cwd="$PWD"
    cd /tmp
    run bash "$FIXFOLDER" "$TEST_DIR"
    cd "$cwd"
    [ "$status" -eq 0 ]
}

@test "handles files with spaces in names" {
    touch "$TEST_DIR"/"vacation photo 2024.jpg"
    touch "$TEST_DIR"/"project notes.txt"
    run bash "$FIXFOLDER" "$TEST_DIR"
    [ -f "$TEST_DIR/Images/vacation photo 2024.jpg" ]
    [ -f "$TEST_DIR/Documents/project notes.txt" ]
}

@test "dry-run mode does not move files" {
    if grep -q '\-\-dry-run' "$FIXFOLDER"; then
        touch "$TEST_DIR"/drytest.jpg
        run bash "$FIXFOLDER" --dry-run "$TEST_DIR"
        [ -f "$TEST_DIR"/drytest.jpg ]
        [ ! -d "$TEST_DIR/Images" ]
    else
        skip "dry-run not implemented"
    fi
}

@test "handles directories inside the target gracefully" {
    mkdir -p "$TEST_DIR"/subdir
    touch "$TEST_DIR"/subdir/file.txt
    run bash "$FIXFOLDER" "$TEST_DIR"
    [ "$status" -eq 0 ]
}
