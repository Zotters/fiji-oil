

![](https://i.ibb.co/YTKXfNVK/Fiji-Oil20.png)  
*Welcome to the Fiji Oil project. This is an open-source oil project made for FiveM. This script adds ways for players to collect, refine, package and deliever oil to earn money. Please keep in mind that this is a work in progress and all features are not listed and features that are listed may not function properly.*

# WORK IN PROGRESS
*All features are not listed and features that are listed may not function properly! If you are experiencing [https://github.com/Zotters/fiji-oil/issues](issues) please open a [https://github.com/Zotters/fiji-oil/issues/new/choose](new_issue).*

## Features
* Open valve at pump, oil flows for a certain amount of time. 
* Collect oil from a random collection zone -- Once the valve is open a blip will appear on the map
  > This is on a timer, once the timer expires the blip will be removed and the player will have to reopen the valve.
* Different oil types
* Refine the Oil
* --Sell the Oil



## Installation
>*Add these to your inventory items.lua*
```lua
itemsFoundIn = INSTALLATION.INFO
```
>*Add this to your shops.lua*  
```lua
	OilCompany = {
		name = 'Los Santos Oil',
		blip = {
			id = 643, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'empty_oil', price = 35 },
            { name = 'empty_drum', price = 75 }
		}, locations = {
			vec3(-41.36, -2148.09, 11.22) -- Change
		}, targets = {
			{ loc = vec3(-41.27, -2148.17, 10.89), length = 0.5, width = 3.0, heading = 270.0, minZ = 30.5, maxZ = 32.0, distance = 3 }
		}
	},
```
>* *Add images to the web section of your inventory.*  
>* *Drop **'fiji-oil'** into server resources*  
>* *Ensure **fiji-oil** in your **server.cfg***  
>* *Edit **Config.lua** to your liking*
>* Start your server and enjoy!

## Dependencies
> **[OXLIB](https://overextended.dev)**  
> **[OXINVENTORY](https://overextended.dev)**  
> **[OXTARGET](https://overextended.dev)**   
>  *or* **[QBX](https://www.qbox.re)**

## Written by Zotters
