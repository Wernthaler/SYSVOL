'* VBS-Script zum Anheften von Verknüpfungen an die Taskleiste
'* für Windows 7 und Windows Server 2008 R2 (Deutsch und Englisch)
'* (c) 2010 by bent.schrader@googlemail.com
'* Version 1.1

'* ergänzt und erweitert von Randy am 16.04.2015
'* – Verknüpfungen, die im Quell-Verzeichnis aktualisiert wurden, werden neu angeheftet
'* – Alte Verknüpfungen, die nicht mehr angeheftet sind, werden gelöscht
'* Version 1.2

'* ergänzt und erweitert von WCS am 25.09.2015
'* – bevor alte Verknüpfungen aus dem (TargetFolder) gelöscht werden, wird überprüft,
'*   ob sie entweder im Startmenü oder in der Taskleiste noch angeheftet sind
'* Version 1.3

'* WCS am 28.06.2016
'* – Funktion auf Windows 8 erweitert. Windows 10 unterstützt diese Funktion derzeit nicht!
'* Version 1.4


Dim objArgs
Dim objSourceFolder
Dim objTargetFolder
Dim objFolderItem, objLNKItem
Dim Itemverb
Dim FileInUse

Set objArgs = WScript.Arguments
Set WSHShell = WScript.CreateObject("WScript.Shell")
Set objEnv = WshShell.Environment("Process")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("Shell.Application")

FQDN = LCase(objEnv("USERDNSDOMAIN"))
User = objEnv("USERNAME")

On Error Resume Next


' Ist das Argument (Source Folder) vorhanden
If objArgs.Count > 0 Then

	strSourceFolder = objArgs(0)
	' Lokaler Pfad für die Ablage der Verknüpfungen
	strTargetFolder = objEnv("APPDATA") & "\Microsoft\Internet Explorer\Quick Launch\"

	' “\“ wird am Ende des (Source Folder) angehängt, falls noch nicht vorhanden
	If Right(strSourceFolder,1) <> "\" Then strSourceFolder = strSourceFolder & "\"
	
	Set objSourceFolder = objFSO.GetFolder(strSourceFolder)
	Set objTargetFolder = objFSO.GetFolder(strTargetFolder)
	
		
	' Erstellen und aktualisieren von Taskleisten-Verknüpfungen
	' ———————————————————
	' Iteration des (Source Folder)
	For Each File In objSourceFolder.Files

		Set objSourceFile = objFSO.GetFile(File)
		
		' Schaut ob das File eine Verknüpfung ist
		If LCase(objFSO.GetExtensionName(objSourceFile)) = "lnk" Then
			
			' Schaut ob das File im (Target Folder) schon vorhanden ist
			If objFSO.FileExists(strTargetFolder & File.Name) Then
				
				Set objTargetFile = objFSO.GetFile(strTargetFolder & File.Name)
	
				' Vergleicht das Target File und Source File ob es geändert wurde
				If objSourceFile.DateLastModified <> objTargetFile.DateLastModified Then
			
					Set objFolderItem = objShell.Namespace(strTargetFolder)
					Set objLNKItem = objFolderItem.ParseName(File.Name)
					
					For Each Itemverb In objLNKItem.Verbs
						' Wenn der Vergleich positiv ausgefallen ist, werden die Verknüpfungen von der Taskliste gelöscht (DEU) (W7, W8, W10)
						If Replace(Itemverb.Name, "&", "") = "Von Taskleiste lösen" Then Itemverb.DoIt
						' Wenn der Vergleich positiv ausgefallen ist, werden die Verknüpfungen von der Taskliste gelöscht (ENG) (W7, W8, W10)
						If Replace(Itemverb.Name, "&", "") = "Unpin from Taskbar" Then Itemverb.DoIt
					Next
					
					' Das geänderte (Target File) wird überschrieben
					objFSO.CopyFile strSourceFolder & File.Name, strTargetFolder, TRUE
				
				End If
			
			Else
				
				' Das nicht vorhandene (Target File) wird kopiert
				objFSO.CopyFile strSourceFolder & File.Name, strTargetFolder, TRUE
			
			End If
				
			Set objFolderItem = objShell.Namespace(strTargetFolder)
			Set objLNKItem = objFolderItem.ParseName(File.Name)
			
			For Each Itemverb In objLNKItem.Verbs
				' Verknüpfung wird (wieder) angeheftet (DEU) (W7, W8, W10)
				If Replace(Itemverb.Name, "&", "") = "An Taskleiste anheften" Then Itemverb.DoIt
				' Verknüpfung wird (wieder) angeheftet (ENG) (W7, W8, W10)
				If Replace(Itemverb.Name, "&", "") = "Pin to Taskbar" Then Itemverb.DoIt
			Next
		
		End If
	
	Next

		
	' Löschen von alten Verknüpfungen im "\Microsoft\Internet Explorer\Quick Launch“ -Verzeichnis
	' ——————————————————————————————-
	' Iteration des (Target Folder)
	For Each File In objTargetFolder.Files
		
		Set objTargetFile = objFSO.GetFile(File)
		
		FileInUse = False
	
		' Schaut ob das File eine Verknüpfung ist
		If LCase(objFSO.GetExtensionName(objTargetFile)) = "lnk" Then
			
			Set objFolderItem = objShell.Namespace(strTargetFolder)
			Set objLNKItem = objFolderItem.ParseName(File.Name)
			
			For Each Itemverb In objLNKItem.Verbs
				' Schaut ob das (Target File) im Startmenü oder Taskleiste angeheftet ist (DEU) (W7)
				If (Replace(Itemverb.Name, "&", "") = "Vom Startmenü lösen") And Not FileInUse Then
					' (Target File) ist am Startmenü angeheftet, die Verknüpfung darf nicht gelöscht werden
					FileInUse = True
				End If
				' Schaut ob das (Target File) im Startmenü oder Taskleiste angeheftet ist (DEU) (W8, W10)
				If (Replace(Itemverb.Name, "&", "") = "Von ""Start"" lösen") And Not FileInUse Then
					' (Target File) ist am Startmenü angeheftet, die Verknüpfung darf nicht gelöscht werden
					FileInUse = True
				End If
				If (Replace(Itemverb.Name, "&", "") = "Von Taskleiste lösen") And Not FileInUse Then
					' (Target File) ist an der Taskleiste angeheftet, die Verknüpfung darf nicht gelöscht werden
					FileInUse = True
				End If
				' Schaut ob das (Target File) im Startmenü oder Taskleiste angeheftet ist (ENG) (W7)
				If (Replace(Itemverb.Name, "&", "") = "Unpin from Start Menu") And Not FileInUse Then
					' (Target File) ist am Startmenü angeheftet, die Verknüpfung darf nicht gelöscht werden
					FileInUse = True
				End If
				If (Replace(Itemverb.Name, "&", "") = "Unpin from Taskbar") And Not FileInUse Then
					' (Target File) ist an der Taskliste angeheftet, die Verknüpfung darf nicht gelöscht werden
					FileInUse = True
				End If
			Next

			If Not FileInUse Then
				' (Target File) ist nicht mehr verknüpft und kann gelöscht werden
				objFSO.deleteFile(objTargetFile)
			End If
			
		End If
	
	Next

End If


' Fehlerbehandlung / Logging
If Err.Number <> 0 Then
	' ERROR in Eventlog
	WSHShell.LogEvent 1, "Fehler bei Ausführung von [" & WScript.ScriptFullName & "] für Benutzer [" & User & "@" & FQDN & "]: " _
	& "Code: " & Err.Number & ", Quelle: " & Err.Source & ", Details: " & Err.Description
Else
	' SUCCESS in Eventlog
	WSHShell.LogEvent 0, "Erfolgreiche Ausführung von [" & WScript.ScriptFullName & "] für Benutzer [" & User & "@" & FQDN & "]."
End If
