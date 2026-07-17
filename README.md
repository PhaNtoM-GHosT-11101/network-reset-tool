<div align="center">
<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&height=200&color=gradient&customColorList=1,5,9&text=Network%20Reset%20Tool&fontColor=9ece6a&fontSize=60&fontAlignY=38&desc=One%20click%20to%20fix%20your%20college%20WiFi%20login%20page.&descColor=73daca&descSize=18&descAlignY=58&animation=fadeIn" />
<br/>

[![Batch](https://img.shields.io/badge/Windows-Batch%20Script-9ece6a?style=for-the-badge&logo=windows&logoColor=black)](#)
[![NITA](https://img.shields.io/badge/Built%20For-NITA%20College%20WiFi-73daca?style=for-the-badge)](#)
</div>

---

## The Problem

NITA college WiFi has a login page that randomly breaks. DNS gets corrupted, the portal stops redirecting, and you are stuck offline. The standard fix requires 6 manual steps in CMD. Every single time.

I automated those 6 steps into one double-click.

---

## What It Does

Runs a sequence of network reset commands (flushdns, netsh reset, winsock reset) that clears all corrupted network state and restores the WiFi login page redirect.

---

## Usage

`
1. Download network-reset.bat
2. Right-click → Run as Administrator
3. Wait 10 seconds
4. Reconnect to WiFi
5. Login page works again
`

---

<div align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=1,5,9&height=100&section=footer" />
<sub>Built out of frustration at 2am — by <b>Aditya Priyadarshi</b></sub>
</div>