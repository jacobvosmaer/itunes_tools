# itunes_tools

## Introduction
These tools, written to be used with iTunes on Mac OS X, serve three purposes:

- using iTunes as a GUI to select music files (`itunes_selection`);
- creating new playlists in iTunes (`make_itunes_playlist` and
 `build_itunes_playlists`);
- adding files to the iTunes library while avoiding the creation of 
  duplicate entries (`itunes_add_missing`).

## Requirements
Once compiled, the binaries _should_ work on OS X 10.4 and later, when
using a 32-bit Intel processor. However, I have only tested them on a 
64-bit 10.7 system. The source compiles with Xcode 4.3, but it may also
work with earlier versions.

## Installation
Running the install.sh script will compile the source using Xcode, and
install the binaries in `/usr/local/bin`, and the man pages (where
existent) in `/usr/local/share/man`.

## Usage
### itunes_selection
Select tracks in the main window of iTunes and run 

    itunes_selection

 to get a newline-separated list of the paths to the selected tracks,
 similar to the output of `find`.

### make_itunes_playlist
Running 

    make_itunes_playlist "My Playlist" file1 file2 file3

 will create a new playlist in iTunes, titled "My Playlist (timestamp)",
containing file1, file2 and file3 as its tracks. Alternatively, you can use
`-` as an argument to read a list of paths from stdin:

    find foo/ -iname "*.mp3" | make_itunes_playlist "My Playlist" -

### build_itunes_playlists
Suppose you have a folder `foo/`, containing an m3u playlist `list.m3u`,
and a subfolder `foo/bar/` containing another playlist `another\ list.m3u`.
Then running

    build_itunes_playlists foo

will created a new folder playlist titled "Imported (timestamp)" in iTunes,
containg a playlist "list" containing the tracks in `list.m3u`, and a 
subfolder "bar" containing "another list".

### itunes_add_missing
Suppose you have a folder `foo/` containing lots of MP3 files, some of
which are already in the iTunes library, but some of which are not. Use
the following command to add only those files which are missing from the 
iTunes library to it:

    find foo/ -iname "*.mp3" | itunes_add_missing

Note that `itunes_add_missing` is a little slow to start because it collects
the inodes of _all_ file tracks in your iTunes library when you run it.
It does not check for doubles in its input.

## Silly example
Select some file tracks in iTunes and run

    itunes_selection | make_itunes_playlist "Don't need no plus button" -

to make a playlist out of them without using the "+" button in the lower
left of the screen.

