@echo off
:: Launch apply script elevated
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0Apply-TraditionalChinese.ps1\"' -Verb RunAs"
