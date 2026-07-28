# Tablets Configuration

A PowerShell 7 project for configuring and auditing multiple Android tablets in parallel.

The project uses Android Debug Bridge (ADB) and Fastboot to automate common tablet setup tasks, collect hardware information, configure an APN, install and open applications, and export device information to a CSV file.

## Features

- Detects Android devices connected through ADB
- Waits until at least two tablets are available
- Configures multiple tablets in parallel
- Applies common Android system settings
- Configures and verifies a private APN
- Automates Android menu navigation using key events and screen taps
- Collects serial number, IMEI, and ICCID
- Installs and configures a digital signage application
- Applies application permissions using `appops`
- Supports Fastboot configuration for automatic power-on
- Exports collected device information to CSV

## Technologies

- PowerShell 7
- Android Debug Bridge
- Fastboot
- PowerShell classes and inheritance
- Parallel processing
- Regular expressions
- CSV export

## Project Structure

```text
├── main.ps1
├── tablets_setup.ps1
├── Functions.ps1
└── README.md
main.ps1

The main script:

starts the ADB server;
detects connected Android devices;
waits until at least two tablets are connected;
processes tablets in parallel;
stores results in a thread-safe collection;
exports the collected information to CSV;
stops the ADB server after processing.

Parallel execution is implemented with:

ForEach-Object -Parallel

The current throttle limit is:

-ThrottleLimit 2

Device results are stored in:

System.Collections.Concurrent.ConcurrentBag
tablets_setup.ps1

This script creates a tablet object and runs the configuration process for one device.

The current workflow includes:

applying basic Android settings;
checking the applied settings;
configuring the APN;
selecting and verifying the APN;
configuring battery protection;
checking battery-related settings;
granting permissions to the management application;
opening the management application;
installing and configuring the signage application;
collecting device information.
Functions.ps1

This file contains:

helper functions for Android menu navigation;
the Data class used for exported device information;
the base Tablets class;
the device-specific K9 class;
ADB and Fastboot commands;
hardware information collection;
APN configuration and verification;
application setup functions.
Class Structure

The base tablet class stores the ADB device identifier:

class Tablets
{
    [string] $Serie
}

The K9 class inherits from Tablets and provides device-specific APN configuration:

class K9 : Tablets
{
    K9([string] $Serie) : base($Serie) {}
}

This structure allows other tablet models to be added later by creating new classes with their own configuration methods.

Android Settings

The project applies settings such as:

fixed screen orientation;
manual screen brightness;
disabled screen timeout;
disabled adaptive brightness;
disabled emergency gestures;
disabled spell checker;
three-button navigation;
disabled cell broadcast application.

The script also verifies several settings after they are applied.

Device Information

The project collects:

serial number;
IMEI;
ICCID.

The serial number and ICCID are retrieved using Android system properties.

The IMEI is retrieved from an Android telephony service and parsed using a regular expression.

Example output object:

SN
IMEI
ICCID
APN Configuration

The K9 tablet class contains a device-specific workflow for:

opening Android network settings;
navigating to the APN menu;
creating an APN;
selecting the configured APN;
checking the active APN.

The workflow uses a combination of:

ADB activity commands;
key events;
screen taps;
Android content queries.
Parallel Processing

Each detected tablet is processed in a separate PowerShell parallel worker.

$Devices | ForEach-Object -Parallel {
    . ($using:setupPath)

    $ID = $_
    $data = main -Serial $ID

    ($using:Excel_Store).Add($data)
} -ThrottleLimit 2

A ConcurrentBag is used because multiple workers may finish at the same time.

Requirements
Windows
PowerShell 7 or newer
Android SDK Platform Tools
ADB-enabled Android tablets
USB debugging or wireless debugging enabled
Fastboot support for bootloader configuration
Permission to configure the target devices
Configuration

Before running the project, update the local paths in main.ps1.

Example:

$setupPath = "C:\Path\To\tablets_setup.ps1"

Update the ADB path used inside the parallel worker:

$adb = "C:\Path\To\adb.exe"

Update the APK path used by the installation function:

C:\Path\To\Application.apk

Update the CSV export path:

C:\Path\To\Output.csv
Usage

Open PowerShell 7 in the Android Platform Tools directory.

Run:

pwsh .\main.ps1

The script waits until at least two Android devices are available.

After detecting the devices, it configures them in parallel and exports the collected data to CSV.

Example CSV Output
SN,IMEI,ICCID
DEVICE_SERIAL_01,'000000000000000,'00000000000000000000
DEVICE_SERIAL_02,'000000000000001,'00000000000000000001

The values above are examples only.

Limitations
UI automation depends on the Android version and screen layout
Tap coordinates may need to be changed for other devices
Key-event sequences may not work on every Android interface
APN configuration is currently designed for the K9 tablet model
Some Fastboot commands are not supported by all manufacturers
Application paths and output paths are currently configured directly in the scripts
The script currently expects at least two connected devices
Error handling and retry logic are limited
Security and Privacy

The exported CSV file may contain sensitive device information, including:

IMEI;
ICCID;
serial numbers.
