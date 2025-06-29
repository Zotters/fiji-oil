

![](https://i.ibb.co/YTKXfNVK/Fiji-Oil20.png)  
*Welcome to the Fiji Oil project. This script is made for FiveM, it was built on the QBX framework. It features a rich configuration and a collection and refining process to oil. This adds a new way for players to earn money on your server while introducing new items that can be used in various ways.*

# WORK IN PROGRESS
*This is a work in progress! Not all features are available. Available features may not function properly, if you experience issues please share!*

## Features
* Open valve at pump, oil flows for a certain amount of time.
* Collect oil from a random collection zone
* Refine the Oil
* Sell the Oil



## Installation
>*Add these to your inventory items.lua*
```lua
    ['empty_oil'] = {
        label = 'Empty Oil Bucket',
        stack = true,
        weight = 150,
    },
    ['empty_drum'] = {
        label = 'Empty Oil Drum',
        stack = false,
        weight = 500,
    },
    ['full_oil_light'] = {
        label = 'Light Oil Bucket',
        stack = false,
        weight = 1500,
    },
    ["full_oil_heavy"] = {
        label = "Heavy Oil Bucket",
        weight = 3000,
        stack = false,
    },
    ['refined_light'] = {
        label = 'Light Crude Oil',
        stack = false,
        weight = 1500,
    },
    ["refined_heavy"] = {
        label = "Heavy Crude Oil",
        weight = 3000,
        stack = false,
    },
    ['oil_drum_light'] = {
        label = 'Light Oil Drum',
        stack = false,
        weight = 7500,
    },
    ['oil_drum_heavy'] = {
        label = 'Heavy Oil Drum',
        stack = false,
        weight = 7500,
    },
```  
>*Add this to your shops.lua  
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
