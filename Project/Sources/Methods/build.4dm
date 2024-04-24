//%attributes = {}
var $version:=File("/RESOURCES/version.txt").getText()
$version:=Request("Version:"; $version)
If (OK=1)
	File("/RESOURCES/version.txt").setText($version)
	
	BUILD APPLICATION(File(Build application settings file).platformPath)
	
	ALERT(OK=1 ? "Build complete" : "Build failed")
	
	If (OK=1)
		var $componentName:=File(Structure file; fk platform path).name
		var $zipFile:=File("/PACKAGE/Build/Components/"+$componentName+".zip")
		If ($zipFile.exists)
			$zipFile.delete()
		End if 
		var $zip:=ZIP Create archive(Folder("/PACKAGE/Build/Components/"+$componentName+".4dbase"); $zipFile)
		
		If ($zip.success)
			
			var $worker : 4D.SystemWorker
			var $param:={currentDirectory: Folder("/PACKAGE/")}
			var $ghCreateRelease:="/usr/local/bin/gh release create "+$version
			$ghCreateRelease+=" \""+File($zipFile.platformPath; fk platform path).path+"#"+$zipFile.fullName+"\""
			$ghCreateRelease+=" --title \"Version "+$version+"\""
			$ghCreateRelease+=" --notes \"Version "+$version+"\""
			$ghCreateRelease+=" --latest"
			
			$worker:=4D.SystemWorker.new("git add ."; $param)
			$worker.wait(30)
			$worker:=4D.SystemWorker.new("git commit -am \"Version "+$version+"\""; $param)
			$worker.wait(30)
			$worker:=4D.SystemWorker.new("git push"; $param)
			$worker.wait(30)
			$worker:=4D.SystemWorker.new("git tag "+$version; $param)
			$worker.wait(30)
			$worker:=4D.SystemWorker.new("git push origin --tags"; $param)
			$worker.wait(30)
			$worker:=4D.SystemWorker.new($ghCreateRelease; $param)
			$worker.wait(30)
			
			ALERT("Published")
		End if 
	End if 
	
End if 
