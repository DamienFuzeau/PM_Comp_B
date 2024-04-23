//%attributes = {}
var $version : Text:=File("/RESOURCES/version.txt").getText()
$version:=Request("Version:"; $version)
If (OK=1)
	File("/RESOURCES/version.txt").setText($version)
	
	BUILD APPLICATION(File(Build application settings file).platformPath)
	
	ALERT(OK=1 ? "Build complete" : "Build failed")
End if 
