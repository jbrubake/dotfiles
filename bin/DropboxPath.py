#!/usr/bin/env python

import os, sys, sqlite3
from base64 import b64encode, b64decode
from pickle import dumps, loads

version = '0.7.1'
'''
Changelog:
2009-05-25.0.6
	Added darwin as linux should require testing
2009-05-29.0.7
	Using pickles as Arash mentioned
	Changed binascii to base64 module
	Minor misc changes
2009-06-01.0.7.1
	Working around a possible bug in sqlite3 by opening db after chdir()
'''

db = 'dropbox.db'
try:
	print '''DropboxPath - move your dropbox folder in a simpler way.
Of course, NO WARRANTIES, you can lose files, yadda yadda...

Instructions:
- Close the dropbox client (right click it, select exit)
- BACKUP YOUR DROPBOX NOW
- Manually move your "My Dropbox" folder to the new location (or copy)
- Check autodetected current location on dropbox database here
- Drag/type your NEW dropbox folder when prompted
- Press ENTER to change it
- Open dropbox again and you should be set.'''
	dbfile = ''
	print '\nTrying to find your dropbox.db (%s):' % sys.platform
	if sys.platform == 'win32':
		assert os.environ.has_key('APPDATA'), Exception('APPDATA env variable not found')
		dbpath = os.path.join(os.environ['APPDATA'],'Dropbox')
	elif sys.platform in ('linux2','darwin'):
		assert os.environ.has_key('HOME'), Exception('HOME env variable not found')
		dbpath = os.path.join(os.environ['HOME'],'.dropbox')
	else: # other platforms?
		raise Exception('platform %s not known, please report' % sys.platform)

	dbfile = os.path.join(dbpath,db)
	assert os.path.isfile(dbfile), Exception('dropbox.db not found, is dropbox installed?')

	print 'Reading db file.'
	lastdir = os.getcwd()
	os.chdir(dbpath)
	connection = sqlite3.connect(db, isolation_level=None)
	os.chdir(lastdir)
	cursor = connection.cursor()
	cursor.execute('SELECT value FROM config WHERE key="dropbox_path"')
	row = cursor.fetchone()
	oldpath = 'Default folder'
	if row is not None:
		oldpath = loads(b64decode(row[0]))
	print '\nCurrent folder:', oldpath

	newpath = raw_input('\nDrag or type the NEW dropbox folder location and press ENTER:\n')
	assert os.path.isdir(newpath), Exception('New folder location is not a directory')

	print '\nChanging dropbox path:\nFrom: %s\nTo:   %s\n' % (oldpath, newpath)
	raw_input('Press ENTER to confirm it or close the script now:')

	print '\nWriting changes to database file'
	newpath = unicode(newpath)
	b64path = b64encode(dumps(newpath))
	cursor.execute('REPLACE INTO config (key,value) VALUES ("dropbox_path",?)', (b64path,))
	cursor.close()
	connection.close()
	print '\nConnection to db closed'
	hostdb = os.path.join(dbpath,'host.db')
	if os.path.isfile(hostdb):
		print '\nRemoving host.db'
		os.unlink(hostdb)
except:
	e, m = sys.exc_info()[:2]
	if e is KeyboardInterrupt:
		sys.exit(0)
	else:
		print 'Exception %s ocurred:\n%s\n\n' % (e, m)
		print 'If you cannot figure out what happened, paste it on the forum thread about me.'
		raw_input('Press ENTER to exit... ')
		sys.exit(1)
print 'If you can see this, I think that all worked. Try opening dropbox again.\nGood luck!'
raw_input('Press ENTER to exit... ')
sys.exit(0)
