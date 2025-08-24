

![](https://i.ibb.co/YTKXfNVK/Fiji-Oil20.png)  
*Welcome to the Fiji Oil project. This is an open-source oil project made for FiveM. This script adds ways for players to collect, refine, package and deliever oil to earn money. Please keep in mind that this is a work in progress and all features are not listed and features that are listed may not function properly.*

# WORK IN PROGRESS
*All features are not listed and features that are listed may not function properly! If you are experiencing [issue](https://github.com/Zotters/fiji-oil/issues) please open a [new issue](https://github.com/Zotters/fiji-oil/issues/new/choose).*

## Features
* Open valve at pump, oil flows for a certain amount of time. 
* Collect oil from a random collection zone -- Once the valve is open a blip will appear on the map
  > This is on a timer, once the timer expires the blip will be removed and the player will have to reopen the valve.
* Different oil types
* Refine the Oil
* --Sell the Oil

## Items
```lua
-- [[ FIJI OIL ]] --
-- Base collection items
['empty_oil'] = {
    label = 'Empty Oil Bucket',
    weight = 250,
    stack = true,
    image = 'empty_oil'
},
['crude_light'] = {
    label = 'Light Crude Oil',
    weight = 800,
    stack = false,
    image = 'crude_light'
},
['crude_heavy'] = {
    label = 'Heavy Crude Oil',
    weight = 1200,
    stack = false,
    image = 'crude_heavy'
},

-- Refined oil products (Light)
['refined_light_pure'] = {
    label = 'Pure Light Oil',
    weight = 600,
    stack = true,
    image = 'refined_light_pure'
},
['refined_light_standard'] = {
    label = 'Standard Light Oil',
    weight = 600,
    stack = true,
    image = 'refined_light_standard'
},
['refined_light_dirty'] = {
    label = 'Dirty Light Oil',
    weight = 600,
    stack = true,
    image = 'refined_light_dirty'
},

-- Refined oil products (Heavy)
['refined_heavy_pure'] = {
    label = 'Pure Heavy Oil',
    weight = 900,
    stack = true,
    image = 'refined_heavy_pure'
},
['refined_heavy_standard'] = {
    label = 'Standard Heavy Oil',
    weight = 900,
    stack = true,
    image = 'refined_heavy_standard'
},
['refined_heavy_dirty'] = {
    label = 'Dirty Heavy Oil',
    weight = 900,
    stack = true,
    image = 'refined_heavy_dirty'
},

-- Packaging materials
['empty_drum'] = {
    label = 'Empty Oil Drum',
    weight = 500,
    stack = true,
    image = 'empty_drum'
},

-- Packaged products (Light)
['packaged_light_pure'] = {
    label = 'Packaged Pure Light Oil',
    weight = 1200,
    stack = true,
    image = 'packaged_light_pure'
},
['packaged_light_standard'] = {
    label = 'Packaged Standard Light Oil',
    weight = 1200,
    stack = true,
    image = 'packaged_light_standard'
},
['packaged_light_dirty'] = {
    label = 'Packaged Dirty Light Oil',
    weight = 1200,
    stack = true,
    image = 'packaged_light_dirty'
},

-- Packaged products (Heavy)
['packaged_heavy_pure'] = {
    label = 'Packaged Pure Heavy Oil',
    weight = 1500,
    stack = true,
    image = 'packaged_heavy_pure'
},
['packaged_heavy_standard'] = {
    label = 'Packaged Standard Heavy Oil',
    weight = 1500,
    stack = true,
    image = 'packaged_heavy_standard'
},
['packaged_heavy_dirty'] = {
    label = 'Packaged Dirty Heavy Oil',
    weight = 1500,
    stack = true,
    image = 'packaged_heavy_dirty'
},

-- Byproducts
['sulfur_chunk'] = {
    label = 'Sulfur Chunk',
    weight = 150,
    stack = true,
    image = 'sulfur_chunk'
},
['plastic_residue'] = {
    label = 'Plastic Residue',
    weight = 100,
    stack = true,
    image = 'plastic_residue'
}```||

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
