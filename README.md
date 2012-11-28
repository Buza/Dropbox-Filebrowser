Dropbox-Filebrowser
=========

This is a simple UITableView-based file browser for Dropbox. 

Summary
-----------

![Image](http://cl.ly/image/1K3D1V2M2q3t/Dropbox-Filebrowser.png)

If you've ever wanted to build a simple file browser for your Dropbox content, this is for you. This is a simple example of how to build a UITableView-based file browser for browsing your Dropbox folders and files in iOS. This project is build with ARC, and works on both iPhone and iPad contained in a UIPopover.

Note that in order to use this, you will need to obtain a [Dropbox API Key and secret](https://www.dropbox.com/developers/start/setup#ios) from the Dropbox website. 

When you have your API key and secret, add them to Common.h, and make sure to set the appropriate callback in the project .plist to 'db-YOUR_DROPBOX_APP_KEY' as follows:

![Image](http://cl.ly/image/0r1z1W3E363K/DropboxURLCallback.png)

