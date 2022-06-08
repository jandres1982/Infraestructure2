FROM mcr.microsoft.com/windows/servercore:ltsc2019

WORKDIR /azp

COPY start.ps1 .

COPY install_modules.ps1 .

RUN powershell .\install_modules.ps1

CMD powershell .\start.ps1