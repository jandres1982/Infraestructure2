cmd /c "c:\Provision\Microsoft\BGINFO_V4.27\install.cmd"
#xcopy /E /I "C:\provision\Microsoft\BGINFO_V4.27" "C:\Program Files (x86)\BGInfo\" /Y
#"C:\Program Files (x86)\BGInfo\Bginfo64.exe" "C:\Program Files (x86)\BGInfo\default.bgi" /timer:0 /nolicprompt /silent
#cd "C:\windows\sysWOW64\"
#regedit.exe /s "C:\Program Files (x86)\BGInfo\bginfo.reg"