# Save Notes
I started this project in an iOS Development class in college.  The primary purpose of the project for me was to learn how to use Dropbox’s Sync API.
Save Notes allows a user to view and edit plain text notes saved in their Apps folder(~/Dropbox/Apps/Save Notes) in their Dropbox, as well as search their notes’ contents.

## Demo
<p align="center">
  <img src="https://raw.githubusercontent.com/clrung/SaveNotes/master/README%20Assets/SaveNotesDemo.gif" alt="Demo"/>
</p>
This demonstrates the creation and deletion of a note, and also shows adjusting the text size via the Settings tab.

## Note
Since I didn’t want to publish my Dropbox App's API key and secret to Github, you must edit Save Notes/passwords.plist with your Dropbox app's API key and secret before launching Save Notes.
```XML
	<key>key</key>
	<string>DROPBOX_KEY_HERE</string>
	<key>secret</key>
	<string>DROPBOX_SECRET_HERE</string>
```