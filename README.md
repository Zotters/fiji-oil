

![](https://ibb.co/PsKSj3hB/)
*Welcome to the Fiji Oil project. This script is made for FiveM, it was built on the QBX framework. It features a rich configuration and a collection and refining process to oil. This adds a new way for players to earn money on your server while introducing new items that can be used in various ways.*

# WORK IN PROGRESS
*This is a work in progress! Not all features are available. Available features may not function properly, if you experience issues please share!*

## Features
* Open valves on an oil pump to start a stream of oil to main container  
* Collect Oil from the main container
* Refine the Oil
* Sell the Oil



## Installation
>*Add these to your inventory items.lua*
```lua
    ['empty_oil'] = {
        label = 'Empty Oil Bucket',
        stack = false,
        weight = 150,
    },
    ['full_oil'] = {
        label = 'Oil Bucket',
        stack = false,
        weight = 1000,
    },
    ['oil_drum'] = {
        label = 'Oil Barrel',
        stack = false,
        weight = 2500,
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
