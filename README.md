# garmin-basics
Connect IQ (garmin) in Monkey C for recording sensors data

## Steps to prep watch for deployment

1. If the watch is new follow the setup instructions on the watch.
	- NOTE: Allow the watch to sync time via gps.
	- NOTE: For wrist select "left" or "right" depending on the wrist the participate will wear it on.

<br/>

2. For the following options turn "on" or "off" depending on the specification below
	- Settings > Notifications & Alerts > Smart Notifications > **off** 
	- Settings > Notifications & Alerts > Health & Wellness > **off** (All *Health & Wellness* should be off)
	- Settings > Notifications & Alerts > Morning Report > **off**
	- Settings > Notifications & Alerts > Notification Center > **off**

	
	- Settings > Sound & Vibe > Vibrations > System > **off**
	- Settings > Sound & Vibe > Vibrations > Alert Vibrations > **off**
	- Settings > Sound & Vibe > Vibrations > Button Press > **off**

	
	- Settings > Display & Brightness > Keys & Touch > **on**
	- Settings > Display & Brightness > Touch > **on**
	- Settings > Display & Brightness > Touch Lock > **off**

	
	- Settings > Focus Modes > Activity > Sound & Vibe > Alert Tones > **off**
	- Settings > Focus Modes > Activity > Sound & Vibe > Button Tones > **off**
	- Settings > Focus Modes > Activity > Sound & Vibe > Vibration > System > **off**
	- Settings > Focus Modes > Activity > Sound & Vibe > Vibration > Alert Vibration > **off**
	- Settings > Focus Modes > Activity > Sound & Vibe > Vibration > Button Press > **off**

## Steps to deploy app on the watch

1. Dowload ANDROID FILE TRANSFER (only need AFT if on Mac, Linux will work just file with out)

2. Connect the watch via USB-C cable

3. Open AFT (if on Mac, if on Linux press the recognised device in you file manager)

4. Drag & Drop the `.prg` file from your computer into `/GARMIN/APPS/`

5. Wait 10 seconds 

6. Unplug watch

7. Navigate to `Activites > basicActive` 

8. Press on `basicActive` to start the recoding


## How to retrieve the data

1. Connect the watch via USB-C cable

2. Navigate to `/GARMIN/ACTIVITY/`

3. Select all `.fit` files

4. Drag & Drop all  `.fit` files to a folder on your computer

5. **WAIT** for all files to transfer (this may take a long time if there many files)

6. Unplug the watch

## IMPORTANT INFORMATION

1. While app is running **DO NOT** plug watch into computer 

2. While app is running you **can** charge via a non-computer connection (e.g. outlet in wall, non-computer usb-c charger)
 
