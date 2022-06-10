FROM mcr.microsoft.com/windows/servercore:ltsc2019

WORKDIR /azp

COPY start.ps1 .

COPY install_modules.ps1 .

## Install NuGet
SHELL ["powershell", "-ExecutionPolicy", "Bypass", "-Command"]
RUN Install-PackageProvider -Name NuGet -Force

## Install Az Module
RUN Install-Module -Name Az -Force

## Install Az Cli
RUN powershell .\install_modules.ps1

## Run initial script
CMD powershell .\start.ps1
