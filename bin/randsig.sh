#!/bin/sh
# randsig.sh - A random signature tag-line generator using fortune
#
#  Author: David D. Scribner <dscribner 'at' bigfoot.com>
#    Date: 12/15/2001
# Version: 1.0.1
# License: GPL - http://www.gnu.org/licenses/gpl.html
#
# This script takes a user's existing sig file (usually ~/.signature)
# and tags a fortune to the bottom of it (with a blank line above and
# below the fortune as padding). This allows the user to continue using
# their existing signature file as is (which may also be referenced by
# other email clients that don't have the ability to run scripts, programs
# or utilize "piped" output), yet be able to attach random tag-lines to
# the signature file for those MUAs that do.
#
# Although you can use the fortune databases to generate random tag-lines
# "as is", I suggest scanning the fortune databases using a text editor,
# gleaning the wanted fortunes and combining them into a separate fortune
# file (with a "%" on its own line separating each fortune as you'll see
# exampled if you snatch tag lines from the fortune files). The fortune
# databases may be found in the directory /usr/share/games/fortune/,
# depending on your flavor of Linux of course. Try to keep those fortunes
# gleaned from one to a few lines to keep your overall signature trim
# (good signature etiquette). While you're gleaning your fortunes, remember
# that many MUAs wrap text at 72 characters. You may wish to insert LFs
# at appropriate places in the lines to account for this (so your tag-lines
# will wrap where wanted. Afterwards, the corresponding *.dat pointer
# file needed by the fortune program so it can reference the fortunes in
# the database can be generated on your "custom" fortune file with:
#
#      strfile -r <fortunefile>
#
# The "-r" parameter randomizes the fortunes in the pointer file, which
# when using fortunes snatched from the various databases and may be
# grouped together in your custom file, keeps them from being used
# sequentially as tags. The resulting "fortunefile" and "fortunefile.dat"
# files can be kept in the user's home directory (or a directory within
# it) if desired. If you edit the individual fortunes kept in your custom
# database after running 'strfile', or add/delete fortunes to/from the
# database, 'strfile' will need to be run to update the pointer file.
#
# If you don't wish to create your own custom fortune file, existing
# fortune files can be utilized by using something similar to:
#
#      fortune -s -e bofh-excuses computers linuxcookie kernelnewbies
#
# in this script, which will select only those fortunes which are short
# ('-s', which defaults to 160 characters or less), and evenly ('-e')
# distributes the fortunes from each file (since the fortune files are of
# varying sizes, it helps keep the ratio of tags used from each database
# in line so fortunes from a large database don't sequentially overshadow
# those from smaller databases). The fortune database names that follow
# the arguments will be those that the fortunes will be pulled from. The
# databases included on your system may differ. To see a list of all
# fortune databases that might exist on your system, issue the command:
#
#      fortune -f
#
# Include those fortune databases that appeal to you. More on utilizing
# the fortune program and its corresponding fortune files can be found in
# the man pages.
#
# I use Mutt as my MUA (in combination with Vim), which allows a user to
# create "pipes" to other commands or scripts for many actions. In the
# Mutt configuration file (~/.muttrc or an alternate sourced file) change
# or include the line:
#
#      set signature = "randsig.sh |"
#
# This pulls in the signature complete with the fortune tag-line at the
# start of the message creation process, allowing you to see the fortune
# tagline and even delete it should you choose to (for those times when
# you need the signature to be more "formal" perhaps). Should you desire
# to have your signature automagically appended to the email message as
# it's sent, comment out the "set signature" option in the .muttrc or
# appropriate sourced file and in its place (or wherever you have your
# other hooks listed) add the following line:
#
#      send-hook . 'set signature="randsig.sh |"'
#
# Other MUAs may simply allow you to specify a program or script to be run
# for your signature (such as KMail). In situations such as that, merely
# specify this script (pre-pended the path to it if necessary).
#
# I keep this script in my ~/bin directory, which is included in my path.
# If you don't have your system configured as such, make sure you have the
# full path to the script specified in your .muttrc file. As well, if your
# path does not include the directory that the 'fortune' program is stored
# in, be sure to include the full path so it can be found.
#
# In the lines below, the commands simply 'cat' the existing signature
# file (~/.signature), 'echo' a blank line to be used as a spacer between
# the signature and the fortune tag-line, attach the fortune pulled from
# a "custom" database ("sigfortunes") stored in a hidden directory in the
# user's home directory (~/.fortunes/ -- previously created to store the
# database and its corresponding "sigfortunes.dat" pointer file in) using
# the 'fortune' program (full path included), and finally uses 'echo' to
# add another blank line as padding below the tag-line.
#
# Although this script includes a ton of comments for only four lines of
# shell commands, they are included to make the utilization of the script
# as easy on your users as possible. Please edit or trim the comments as
# you see fit to speed execution if necessary.

cat ~/.signature
echo " "
`which fortune` ~/.fortunes/sigfortunes
