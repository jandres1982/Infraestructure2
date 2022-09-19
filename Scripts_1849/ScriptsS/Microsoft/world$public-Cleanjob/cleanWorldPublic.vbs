'//////////COPYRIGHT//////////
'
' The purpose of this script is
' to recursively enumerate and delete files and folders
' of a specific base directory
' (c)2011, All rights reserved by Thomas Galliker, Reto Burkart
'
'//////////HISTORY//////////
'
' 01.01.2010	Initial Script by Reto Burkart
' 20.06.2011	Force deletion even if current user is not owner of the target file/folder
' 27.06.2011	Further debugging infos and improved fail safety

'//////////DECLARATIONS//////////
OPTION EXPLICIT

CONST BASE_DIR		= "\\infv0001\world$\public"
CONST FILE_README	= "readmepublic.pdf" 'Note: (the first caracter must be a chr(255) (use ALT+255)

DIM lastErr		: lastErr		= 0
DIM logOk		: SET logOK  		= NEW bukiStringBuilder
DIM logErr		: SET logErr 		= NEW bukiStringBuilder
DIM dirFiltered		: SET dirFiltered	= NEW bukiStringBuilder
DIM startTime		: startTime		= now
Dim FSO

'//////////ENTRY POINT//////////
ON ERROR RESUME NEXT
Set FSO = CreateObject("Scripting.FileSystemObject")
removeDir BASE_DIR,logOK,logErr
IF err.number <> 0 THEN lastErr = err.number
ON ERROR RESUME NEXT
DIM endTime		: endTime		= now

logOk.Append "Time taken: " & datediff("s",startTime,endTime) & " seconds (minutes: ~" & INT(datediff("n",startTime,endTime)) & ")"


wscript.echo "OK:" & vbcrlf & logOK.toString
wscript.echo "Errors:" & vbcrlf & logErr.toString
if lastErr <> 0 THEN wscript.quit lastErr
if LEN(logErr.toString) > 0 THEN wscript.quit 1

'//////////METHODS//////////
SUB removeDir(strFolder,lO,lE)
	dim fo
	dim f

	Dim fsoFolder
	Set fsoFolder = FSO.GetFolder(strFolder)
	Wscript.Echo "Base Dir: " & fsoFolder.Path & " (Exists: "& FSO.FolderExists(fsoFolder.Path) &")"

	'=====DELETE FILES======'
	FOR EACH f in fsoFolder.files
		if not f.name = FILE_README THEN
			wscript.sleep 4 'give the destination a short break
			dim thisF : thisF = "Delete File " & f.path & " (len: " & LEN(f.path) & ")"
			ON ERROR RESUME NEXT
			f.delete True
			'Wscript.Echo thisF
			IF err.number <> 0 THEN
				thisF = thisF & " Error: " & err.number & ". " & err.description
				lE.append thisF
			ELSE
				thisF = thisF & " OK."
				lO.append thisF
			END IF
			ON ERROR GOTO 0
		else
			lO.append "Filtered File: " & f.path
			dirFiltered.append f.parentFolder.path
		end if
	NEXT

	'=====DELETE FOLDERS (RECURSIVELY)======'
	FOR EACH fo in fsoFolder.SubFolders
		Wscript.Echo "Subfolder: " & fo.Path & " (Exists: "& FSO.FolderExists(fo.Path) &")"
		removeDir fo.Path,lO,lE


		IF isFiltered(fo,dirFiltered.toArray) THEN
			lO.append "Filtered Folder: " & fo.path
		ELSE
			DIM thisFo : thisFo = "Delete Folder " & fo.path & " (len: " & LEN(fo.path) & ")"
			ON ERROR RESUME NEXT
			fo.delete True
			'Wscript.Echo thisFo
			IF err.number <> 0 THEN
				thisFo = thisFO & " Error: " & err.number & ". " & err.description
				lE.append thisFo
			ELSE
				thisFo = thisFO & " OK."
				lO.append thisFo
			END IF
			ON ERROR GOTO 0
		END IF
	NEXT



end SUB

function isFiltered(fsoFolder,filterArray) ' as boolean
	isFiltered = false
	DIM fltr
	FOR EACH fltr in filterArray
		if fsoFolder.path = fltr THEN
			isFiltered = TRUE
			exit for
		end if
	NEXT
end function

'//////////CLASSES//////////
Class bukiStringBuilder
	Dim arr 	'the array of strings to concatenate
	Dim growthRate  'the rate at which the array grows
	Dim itemCount   'the number of items in the array

	Private Sub Class_Initialize()
		growthRate = 50
		itemCount = 0
		ReDim arr(growthRate)
	End Sub

	Public Property get AppendCount
		AppendCount = itemCount
	End Property

	Public Property get currentCount
		currentCount = itemCount
	End Property


	'Append a new string to the end of the array. If the
	'number of items in the array is larger than the
	'actual capacity of the array, then "grow" the array
	'by ReDimming it.
	Public Sub Append(ByVal strValue)
		If itemCount > UBound(arr) Then
			ReDim Preserve arr(UBound(arr) + growthRate)
		End If

		ON ERROR RESUME NEXT
		'wscript.stdOut.WriteLine strValue
		ON ERROR GOTO 0

		arr(itemCount) = strValue
		itemCount = itemCount + 1
	End Sub

	'Concatenate the strings by simply joining your array
	'of strings and adding no separator between elements.
	Public Function ToString()
		REDIM PRESERVE arr(itemCount-1)
		DIM retVal : retVal = Join(arr, vbcrlf)
		WHILE RIGHT(retVal,LEN(vbcrlf)) = vbcrlf : retVal = LEFT(retVal,LEN(retVal) - LEN(vbcrlf)) : WEND
		ToString = retVal
	End Function

	Public Function ToSortedString()
		REDIM PRESERVE arr(itemCount-1)
		DIM retVal : retVal = Join(sortArray(arr), vbcrlf)
		WHILE RIGHT(retVal,LEN(vbcrlf)) = vbcrlf : retVal = LEFT(retVal,LEN(retVal) - LEN(vbcrlf)) : WEND
		ToSortedString = retVal
	End Function

	Public Function ToArray()
		REDIM PRESERVE arr(itemCount-1)
		ToArray = arr
	End Function

	Public Function ToSortedArray()
		REDIM PRESERVE arr(itemCount-1)
		ToSortedArray = sortArray(arr)
	End Function

	PRIVATE FUNCTION sortArray(arrSortieren) ' as array
		DIM i
		DIM j
		DIM arrTemp
		for i = 0 to ubound(arrSortieren)
			for j = i + 1 to ubound(arrSortieren)
				if arrSortieren(i) > arrSortieren(j) then
					arrTemp = arrSortieren(i)
					arrSortieren(i) = arrSortieren(j)
					arrSortieren(j) = arrTemp
				end if
			next
		next
		sortArray = arrSortieren
	end function

End Class