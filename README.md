## Mounty

Mounty is a tool for mounting remote shares on OSX. It takes WiFi SSID as an argument, and attempts the connection only if the SSID matches the network the system is currently connected to. It also verifies that the share isn't already mounted. If it is, it returns the location where the share is already mounted, rather then attempting to mount it again.

Mounty is superior to the unix mount command available in OSX because it can store the credentials for the network share (username and password) in the keychain. This makes it ideal for use in bash scripts. For instance, you can make a bash script that calls mounty several times, iterating through all kinds of network shares you connect to on regular basis. Simply add that script to cron, and you'll never have to worry about manually remounting those shares again.

I added the SSID argument so that monty knows to only attempt the connection if the system is connected to the right network, ideal for laptops, if you work in several different locations, and need to access different network shares, based on the location.

## Installing

Download the precompiled binary from the "compiled" directory above or compile the source in Xcode and copy the mounty binary to any directory in your path, like /usr/bin/.

## Running

Example:

mounty smb://server/share /mount/pint WiFi_SSID

It works with any type of share that OSX can mount, not just samba, as it relies on the internal NetFS library.

## License

Released under the MIT License.