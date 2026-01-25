# Smart File Organizer (fixfolder)

A powerful bash script that automatically organizes files in any directory into categorized subdirectories based on file types. Say goodbye to messy Downloads folders!

## Features

- 🗂️ **Automatic Organization** - Sorts files into 17 predefined categories
- 📊 **Detailed Logging** - Complete audit trail of all file operations
- ✅ **Smart Detection** - Recognizes 100+ file extensions
- 🔒 **Safe Operations** - Comprehensive error handling and validation
- 📈 **Progress Tracking** - Real-time counters and summaries
- 🎨 **User-Friendly** - Color-coded installation with helpful feedback

## Supported File Categories

| Category | Extensions |
|----------|-----------|
| **Images** | jpg, jpeg, png, gif, bmp, tiff, svg, webp, heic, raw |
| **Documents** | pdf, doc, docx, txt, xls, xlsx, ppt, pptx, odt, csv, rtf, md |
| **Videos** | mp4, avi, mkv, mov, wmv, flv, webm, m4v, 3gp, vob, rmvb |
| **Music** | mp3, wav, flac, aac, ogg, m4a, wma |
| **Archives** | zip, tar, gz, rar, 7z, bz2, iso, xz, cab, arj, lzma, zst |
| **Scripts** | sh, py, js, rb, pl, php, bat, ps1 |
| **Packages** | deb, rpm, dmg, exe, flatpak, appimage |
| **Executables** | bin, run |
| **Fonts** | ttf, otf, woff, woff2 |
| **Code** | c, cpp, java, cs, go, rs, swift, kt |
| **Config** | ini, cfg, conf, yml, yaml, json, xml, toml |
| **Logs** | log |
| **Backups** | bak, bkp |
| **Temporary** | tmp, temp |
| **Torrents** | torrent |
| **Profiles** | profile, icc |
| **Others** | All uncategorized files |

## Installation

### System-wide Installation (Recommended)

```bash
# Download the installation script
chmod +x install.sh

# Run with sudo for system-wide installation
sudo ./install.sh
```

### User Installation

```bash
# Run without sudo for user-only installation
./install.sh
```

After installation, you may need to restart your terminal or run:
```bash
source ~/.bashrc
```

## Usage

### Basic Usage

```bash
# Organize files in a specific directory
fixfolder /path/to/directory

# Example: Organize Downloads folder
fixfolder ~/Downloads

# Example: Organize current directory
fixfolder .
```

### Get Help

```bash
fixfolder --help
fixfolder -h
```

### View Logs

```bash
# View the most recent log
cat ~/smart-file-organizer_logs/fixfiles.log

# View logs in real-time (if running)
tail -f ~/smart-file-organizer_logs/fixfiles.log
```

## What Happens When You Run fixfolder?

1. **Validation** - Checks if the target directory exists
2. **Directory Creation** - Creates category subdirectories
3. **File Categorization** - Identifies each file's type by extension
4. **File Moving** - Moves files to appropriate category folders
5. **Logging** - Records all operations with timestamps
6. **Summary** - Displays total files moved and any errors

## Example Output

```
Smart File Organizer - Version 2.0
Files have been organized in /home/user/Downloads.
Total files moved: 47
```

## Log File Format

The log file (`~/smart-file-organizer_logs/fixfiles.log`) contains:

```
Script started at: 2026-01-25 14:32:15
Executed command: fixfolder /home/user/Downloads
Executed by user: username
Target directory: /home/user/Downloads
----------------------------------------
Creating category directories...
  [✓] Created directory: Images
  [✓] Created directory: Documents
  [✓] Created directory: Videos
...
----------------------------------------
Starting file organization...
  [MOVED] vacation.jpg → Images/
  [MOVED] report.pdf → Documents/
  [MOVED] movie.mp4 → Videos/
----------------------------------------
Moving uncategorized files to Others...
  [MOVED] readme.README → Others/
----------------------------------------
Organization Summary:
  Total files moved: 47
  Total errors: 0
----------------------------------------
Script ended at: 2026-01-25 14:32:18
========================================
```

## Uninstallation

```bash
fixfolder-uninstall
```

This removes the script but preserves your log files. To also remove logs:

```bash
rm -rf ~/smart-file-organizer_logs
```

## Directory Structure After Organization

```
YourDirectory/
├── Images/
│   ├── photo1.jpg
│   └── screenshot.png
├── Documents/
│   ├── report.pdf
│   └── notes.txt
├── Videos/
│   └── movie.mp4
├── Music/
│   └── song.mp3
├── Archives/
│   └── backup.zip
└── Others/
    └── unknown_file.xyz
```

## Safety Features

- ✅ Directory validation before execution
- ✅ File existence checks before moving
- ✅ Error logging for failed operations
- ✅ Preserves original files (moves, not copies)
- ✅ Creates category directories automatically
- ✅ Handles files without extensions

## Requirements

- Bash 4.0 or higher
- Linux, macOS, or WSL (Windows Subsystem for Linux)
- Write permissions for target directory

## Troubleshooting

### Command not found

If you get "command not found" after installation:

```bash
# Reload your shell configuration
source ~/.bashrc

# Or check if the PATH was added
echo $PATH
```

### Permission denied

If you get permission errors:

```bash
# For system-wide installation
sudo ./install.sh

# Or ensure the script is executable
chmod +x fixfolder
```

### Files not moving

Check the log file for specific errors:

```bash
cat ~/smart-file-organizer_logs/fixfiles.log
```

Common issues:
- Insufficient permissions in target directory
- Files are locked or in use by another process
- Disk space issues

## Contributing

Found a bug or want to add a new file category? Contributions are welcome!

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Submit a pull request

## License

This project is open source and available under the MIT License.

## Author

Created to bring order to chaos, one directory at a time.

## Version History

- **v2.0** - Enhanced logging with detailed file tracking
- **v1.0** - Initial release with basic organization features

---

**Happy Organizing! 🗂️**