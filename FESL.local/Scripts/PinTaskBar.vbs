'* VBS-Script zum Anheften von Verkn�pfungen an die Taskleiste
'* f�r Windows 7 und Windows Server 2008 R2 (Deutsch und Englisch)
'* (c) 2010 by bent.schrader@googlemail.com
'* Version 1.1

'* erg�nzt und erweitert von Randy am 16.04.2015
'* � Verkn�pfungen, die im Quell-Verzeichnis aktualisiert wurden, werden neu angeheftet
'* � Alte Verkn�pfungen, die nicht mehr angeheftet sind, werden gel�scht
'* Version 1.2

'* erg�nzt und erweitert von WCS am 25.09.2015
'* � bevor alte Verkn�pfungen aus dem (TargetFolder) gel�scht werden, wird �berpr�ft,
'*   ob sie entweder im Startmen� oder in der Taskleiste noch angeheftet sind
'* Version 1.3

'* WCS am 28.06.2016
'* � Funktion auf Windows 8 erweitert. Windows 10 unterst�tzt diese Funktion derzeit nicht!
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
	' Lokaler Pfad f�r die Ablage der Verkn�pfungen
	strTargetFolder = objEnv("APPDATA") & "\Microsoft\Internet Explorer\Quick Launch\"

	' �\� wird am Ende des (Source Folder) angeh�ngt, falls noch nicht vorhanden
	If Right(strSourceFolder,1) <> "\" Then strSourceFolder = strSourceFolder & "\"
	
	Set objSourceFolder = objFSO.GetFolder(strSourceFolder)
	Set objTargetFolder = objFSO.GetFolder(strTargetFolder)
	
		
	' Erstellen und aktualisieren von Taskleisten-Verkn�pfungen
	' �������������������
	' Iteration des (Source Folder)
	For Each File In objSourceFolder.Files

		Set objSourceFile = objFSO.GetFile(File)
		
		' Schaut ob das File eine Verkn�pfung ist
		If LCase(objFSO.GetExtensionName(objSourceFile)) = "lnk" Then
			
			' Schaut ob das File im (Target Folder) schon vorhanden ist
			If objFSO.FileExists(strTargetFolder & File.Name) Then
				
				Set objTargetFile = objFSO.GetFile(strTargetFolder & File.Name)
	
				' Vergleicht das Target File und Source File ob es ge�ndert wurde
				If objSourceFile.DateLastModified <> objTargetFile.DateLastModified Then
			
					Set objFolderItem = objShell.Namespace(strTargetFolder)
					Set objLNKItem = objFolderItem.ParseName(File.Name)
					
					For Each Itemverb In objLNKItem.Verbs
						' Wenn der Vergleich positiv ausgefallen ist, werden die Verkn�pfungen von der Taskliste gel�scht (DEU) (W7, W8, W10)
						If Replace(Itemverb.Name, "&", "") = "Von Taskleiste l�sen" Then Itemverb.DoIt
						' Wenn der Vergleich positiv ausgefallen ist, werden die Verkn�pfungen von der Taskliste gel�scht (ENG) (W7, W8, W10)
						If Replace(Itemverb.Name, "&", "") = "Unpin from Taskbar" Then Itemverb.DoIt
					Next
					
					' Das ge�nderte (Target File) wird �berschrieben
					objFSO.CopyFile strSourceFolder & File.Name, strTargetFolder, TRUE
				
				End If
			
			Else
				
				' Das nicht vorhandene (Target File) wird kopiert
				objFSO.CopyFile strSourceFolder & File.Name, strTargetFolder, TRUE
			
			End If
				
			Set objFolderItem = objShell.Namespace(strTargetFolder)
			Set objLNKItem = objFolderItem.ParseName(File.Name)
			
			For Each Itemverb In objLNKItem.Verbs
				' Verkn�pfung wird (wieder) angeheftet (DEU) (W7, W8, W10)
				If Replace(Itemverb.Name, "&", "") = "An Taskleiste anheften" Then Itemverb.DoIt
				' Verkn�pfung wird (wieder) angeheftet (ENG) (W7, W8, W10)
				If Replace(Itemverb.Name, "&", "") = "Pin to Taskbar" Then Itemverb.DoIt
			Next
		
		End If
	
	Next

		
	' L�schen von alten Verkn�pfungen im "\Microsoft\Internet Explorer\Quick Launch� -Verzeichnis
	' ������������������������������-
	' Iteration des (Target Folder)
	For Each File In objTargetFolder.Files
		
		Set objTargetFile = objFSO.GetFile(File)
		
		FileInUse = False
	
		' Schaut ob das File eine Verkn�pfung ist
		If LCase(objFSO.GetExtensionName(objTargetFile)) = "lnk" Then
			
			Set objFolderItem = objShell.Namespace(strTargetFolder)
			Set objLNKItem = objFolderItem.ParseName(File.Name)
			
			For Each Itemverb In objLNKItem.Verbs
				' Schaut ob das (Target File) im Startmen� oder Taskleiste angeheftet ist (DEU) (W7)
				If (Replace(Itemverb.Name, "&", "") = "Vom Startmen� l�sen") And Not FileInUse Then
					' (Target File) ist am Startmen� angeheftet, die Verkn�pfung darf nicht gel�scht werden
					FileInUse = True
				End If
				' Schaut ob das (Target File) im Startmen� oder Taskleiste angeheftet ist (DEU) (W8, W10)
				If (Replace(Itemverb.Name, "&", "") = "Von ""Start"" l�sen") And Not FileInUse Then
					' (Target File) ist am Startmen� angeheftet, die Verkn�pfung darf nicht gel�scht werden
					FileInUse = True
				End If
				If (Replace(Itemverb.Name, "&", "") = "Von Taskleiste l�sen") And Not FileInUse Then
					' (Target File) ist an der Taskleiste angeheftet, die Verkn�pfung darf nicht gel�scht werden
					FileInUse = True
				End If
				' Schaut ob das (Target File) im Startmen� oder Taskleiste angeheftet ist (ENG) (W7)
				If (Replace(Itemverb.Name, "&", "") = "Unpin from Start Menu") And Not FileInUse Then
					' (Target File) ist am Startmen� angeheftet, die Verkn�pfung darf nicht gel�scht werden
					FileInUse = True
				End If
				If (Replace(Itemverb.Name, "&", "") = "Unpin from Taskbar") And Not FileInUse Then
					' (Target File) ist an der Taskliste angeheftet, die Verkn�pfung darf nicht gel�scht werden
					FileInUse = True
				End If
			Next

			If Not FileInUse Then
				' (Target File) ist nicht mehr verkn�pft und kann gel�scht werden
				objFSO.deleteFile(objTargetFile)
			End If
			
		End If
	
	Next

End If


' Fehlerbehandlung / Logging
If Err.Number <> 0 Then
	' ERROR in Eventlog
	WSHShell.LogEvent 1, "Fehler bei Ausf�hrung von [" & WScript.ScriptFullName & "] f�r Benutzer [" & User & "@" & FQDN & "]: " _
	& "Code: " & Err.Number & ", Quelle: " & Err.Source & ", Details: " & Err.Description
Else
	' SUCCESS in Eventlog
	WSHShell.LogEvent 0, "Erfolgreiche Ausf�hrung von [" & WScript.ScriptFullName & "] f�r Benutzer [" & User & "@" & FQDN & "]."
End If
