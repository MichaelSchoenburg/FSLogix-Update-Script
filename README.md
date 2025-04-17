# FSLogix Update Script
PowerShell script which automatically updates FSLogix to the latest version. Intended for use with a RMM tool.

## Inputs/Variables
Let's break down each of the input variables in this PowerShell script for updating FSLogix:

**1. `$Restart`**

* **Purpose:** This variable determines whether the script should instruct the FSLogix installer to perform a system restart after the installation/update process.
* **Values:**
    * `0`: Indicates that the script should allow the FSLogix installer to initiate a system restart if required by the installation.
    * `1`: Indicates that the script should instruct the FSLogix installer to suppress any automatic system restart, even if the installation would normally require one.
* **Configuration:** You configure this variable by assigning it either the integer `0` or `1`. This is typically done through your RMM (Remote Monitoring and Management) tool when deploying or scheduling the script. For example:
    ```powershell
    $Restart = 0  # To allow a restart
    $Restart = 1  # To prevent a restart
    ```
* **Considerations:**
    * **`0` (Allow Restart):** This is generally the safer option to ensure the FSLogix installation completes correctly, as some updates might require a restart to fully take effect.
    * **`1` (Prevent Restart):** You might choose this option if you need to control restarts for operational reasons (e.g., during business hours) and plan to initiate a restart through other means later. However, be aware that suppressing necessary restarts can lead to incomplete installations or unexpected behavior.

**2. `$MinutesTolerance`**

* **Purpose:** This variable defines a time window (in minutes) around the specified `$InstallTime` during which the script is allowed to proceed with the FSLogix update. This adds flexibility to the scheduled execution time.
* **Values:** A positive integer representing the number of minutes.
* **Configuration:** You configure this variable by assigning it a positive integer value through your RMM tool. For example:
    ```powershell
    $MinutesTolerance = 15  # Allow execution within 15 minutes before or after the InstallTime
    $MinutesTolerance = 60  # Allow execution within 60 minutes (1 hour) before or after the InstallTime
    ```
* **How it Works:** The `Check-Scheduled-Time` function calculates the difference between the current time and the `$InstallTime`. If the absolute value of this difference (in minutes) is less than the `$MinutesTolerance`, the function returns `$true`, and the script proceeds with the update.
* **Considerations:**
    * A smaller tolerance makes the execution time more precise.
    * A larger tolerance provides more flexibility if the script execution from your RMM is not perfectly punctual.

**3. `$InstallTime`**

* **Purpose:** This variable specifies the exact time of day (in 24-hour format) when the script should attempt to perform the FSLogix update, provided it's also the `$InstallDay`.
* **Values:** A string in the format "HH:mm" (e.g., "04:00" for 4:00 AM, "18:30" for 6:30 PM).
* **Configuration:** You configure this variable by assigning it a string representing the desired time in 24-hour format through your RMM tool. For example:
    ```powershell
    $InstallTime = "03:30"  # Set the install time to 3:30 AM
    $InstallTime = "22:00"  # Set the install time to 10:00 PM
    ```
* **How it Works:** The `Check-Scheduled-Time` function compares the current time with this `$InstallTime`. It also uses the `$MinutesTolerance` to allow execution within a specified window around this time.
* **Considerations:** Choose a time when systems are likely to be less busy to minimize disruption.

**4. `$InstallDay`**

* **Purpose:** This variable specifies the day of the week (in German) when the script should attempt to perform the FSLogix update, in conjunction with the `$InstallTime`.
* **Values:** A string representing a German weekday: "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag".
* **Configuration:** You configure this variable by assigning it the German name of the desired weekday through your RMM tool. For example:
    ```powershell
    $InstallDay = "Sonntag"  # Set the install day to Sunday
    $InstallDay = "Mittwoch" # Set the install day to Wednesday
    ```
* **How it Works:** The `Check-Scheduled-Time` function compares the current day of the week (in German) with the value of `$InstallDay`. The script will only proceed with the update if the current day matches `$InstallDay` and the current time is within the tolerance of `$InstallTime`.
* **Considerations:** Choose a day when systems are likely to be less busy, such as weekends or outside of peak business hours.

**5. `$DownloadPath`**

* **Purpose:** This variable specifies the local file system path on the target machine where the FSLogix installer ZIP file will be downloaded. The script will also create a subfolder within this path to extract the installer files.
* **Values:** A string representing a valid local file system path. For example: `"C:\Temp\FSLogix"`, `"D:\SoftwareUpdates\FSLogix"`, `"\\server\share\FSLogixDownloads"`.
* **Configuration:** You configure this variable by assigning it a string representing the desired download path through your RMM tool. For example:
    ```powershell
    $DownloadPath = "C:\FSLogixUpdate"
    $DownloadPath = "\\fileserver\Software\FSLogix"
    ```
* **Considerations:**
    * Ensure the specified path exists or that the system running the script has the necessary permissions to create it. The script includes logic to create the directory if it doesn't exist.
    * The path should have enough free disk space to download the FSLogix ZIP file and extract its contents.
    * Using a dedicated folder for downloads can help with organization and cleanup (as the script attempts to delete the downloaded ZIP and extracted folder in the `finally` block).

**In summary:** These input variables provide crucial configuration for the FSLogix update script, allowing you to control *when* the update happens, *how* it handles restarts, and *where* the necessary files are downloaded. You will typically set these variables within the deployment or scheduling settings of your RMM tool for each target machine or group of machines. The script then uses these variables to make decisions about whether and how to proceed with the FSLogix update.

## How to set the varialbes
The script expects the RMM tool to define the variables at runtime. This is the case e. g. with Riversuite Riverbird.

## OUTPUTS
Exit Code 0 = Success

Exit Code 1 = Error

Exit Code 2 = Warning
