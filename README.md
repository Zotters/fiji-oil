

![](https://i.ibb.co/YTKXfNVK/Fiji-Oil20.png)  

## Features

- **Complete Oil Production Chain**
  - Extract crude oil from pumps
  - Refine crude oil into various grades
  - Package refined oil for delivery
  - Deliver packaged oil for profit

- **Dynamic Oil Extraction**
  - Open valves at oil pumps
  - Random oil types (light/heavy crude)
  - Timed collection points
  - Visual indicators and map markers

- **Advanced Refinery System**
  - Multi-stage refining process
  - Load crude oil into hoppers
  - Distillation process
  - Extract refined products
  - Quality-based outcomes (pure, standard, dirty)
  - Chance for byproducts

- **Oil Packaging**
  - Convert refined oil into transportable products
  - Requires empty drums
  - Multiple oil grades and types

- **Delivery System**
  - Random delivery locations
  - Custom delivery vehicles with keys
  - Time-based bonus rewards
  - Smart vehicle spawning system

- **Sleek UI Elements**
  - Circular timers for valves and deliveries
  - Refinery control panel
  - Progress indicators

- **Framework Support**
  - QBCore / QBX Core
  - ESX
  - ox_inventory
  - qs-inventory
  - Automatic framework detection

- **Developer-Friendly**
  - Highly configurable
  - Well-documented code
  - Easy to extend

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)

## Installation

1. Ensure you have the required dependencies installed
2. Download the latest release from [GitHub](https://github.com/Zotters/fiji-oil/releases)
3. Extract the files to your server's resources folder
4. Add `ensure fiji-oil` to your server.cfg
5. Configure the settings in `config.lua` to your liking
6. Restart your server

## Configuration

The script is highly configurable through the `config.lua` file. You can adjust:

- Oil pump locations
- Refinery settings
- Packaging requirements
- Delivery locations and rewards
- Time bonuses
- Vehicle models
- Item requirements
- And much more!

## Items

The following items are used by the script:

- `empty_oil` - Empty oil container
- `crude_light` - Light crude oil
- `crude_heavy` - Heavy crude oil
- `refined_light_pure` - Pure refined light oil
- `refined_light_standard` - Standard refined light oil
- `refined_light_dirty` - Dirty refined light oil
- `refined_heavy_pure` - Pure refined heavy oil
- `refined_heavy_standard` - Standard refined heavy oil
- `refined_heavy_dirty` - Dirty refined heavy oil
- `empty_drum` - Empty oil drum
- `packaged_light_pure` - Packaged pure light oil
- `packaged_light_standard` - Packaged standard light oil
- `packaged_light_dirty` - Packaged dirty light oil
- `packaged_heavy_pure` - Packaged pure heavy oil
- `packaged_heavy_standard` - Packaged standard heavy oil
- `packaged_heavy_dirty` - Packaged dirty heavy oil

You'll need to add these items to your inventory system.

## Usage

### Oil Extraction
1. Approach an oil pump
2. Open the valve
3. Go to the marked collection point
4. Collect oil using empty containers

### Oil Refining
1. Take your crude oil to the refinery
2. Load the crude oil into the hopper
3. Start the distillation process
4. Extract the refined oil

### Oil Packaging
1. Take your refined oil to the packaging station
2. Use empty drums to package the oil
3. Package the oil for delivery

### Oil Delivery
1. Take your packaged oil to the delivery office
2. Select the oil type and quantity to deliver
3. Drive the delivery vehicle to the destination
4. Complete the delivery to receive payment

## Commands

- `/canceldelivery` - Cancel your current delivery and return the oil

## Screenshots

**Coming soon**

## Support

For support, use [Issues](https://github.com/Zotters/fiji-oil/issues)

## Items
<details>
  <summary>QBCore Items</summary>
  
  ```lua
  ['empty_oil'] = {
      ['name'] = 'empty_oil',
      ['label'] = 'Empty Oil Container',
      ['weight'] = 1000,
      ['type'] = 'item',
      ['image'] = 'empty_oil.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'An empty container for collecting crude oil'
  },
  ['crude_light'] = {
      ['name'] = 'crude_light',
      ['label'] = 'Light Crude Oil',
      ['weight'] = 2000,
      ['type'] = 'item',
      ['image'] = 'crude_light.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'Unrefined light crude oil'
  },
  ['crude_heavy'] = {
      ['name'] = 'crude_heavy',
      ['label'] = 'Heavy Crude Oil',
      ['weight'] = 2500,
      ['type'] = 'item',
      ['image'] = 'crude_heavy.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'Unrefined heavy crude oil'
  },
  ['refined_light_pure'] = {
      ['name'] = 'refined_light_pure',
      ['label'] = 'Pure Light Oil',
      ['weight'] = 1800,
      ['type'] = 'item',
      ['image'] = 'refined_light_pure.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'High-quality refined light oil'
  },
  ['refined_light_standard'] = {
      ['name'] = 'refined_light_standard',
      ['label'] = 'Standard Light Oil',
      ['weight'] = 1800,
      ['type'] = 'item',
      ['image'] = 'refined_light_standard.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'Standard-quality refined light oil'
  },
  ['refined_light_dirty'] = {
      ['name'] = 'refined_light_dirty',
      ['label'] = 'Dirty Light Oil',
      ['weight'] = 1800,
      ['type'] = 'item',
      ['image'] = 'refined_light_dirty.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'Low-quality refined light oil'
  },
  ['refined_heavy_pure'] = {
      ['name'] = 'refined_heavy_pure',
      ['label'] = 'Pure Heavy Oil',
      ['weight'] = 2200,
      ['type'] = 'item',
      ['image'] = 'refined_heavy_pure.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'High-quality refined heavy oil'
  },
  ['refined_heavy_standard'] = {
      ['name'] = 'refined_heavy_standard',
      ['label'] = 'Standard Heavy Oil',
      ['weight'] = 2200,
      ['type'] = 'item',
      ['image'] = 'refined_heavy_standard.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'Standard-quality refined heavy oil'
  },
  ['refined_heavy_dirty'] = {
      ['name'] = 'refined_heavy_dirty',
      ['label'] = 'Dirty Heavy Oil',
      ['weight'] = 2200,
      ['type'] = 'item',
      ['image'] = 'refined_heavy_dirty.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'Low-quality refined heavy oil'
  },
  ['empty_drum'] = {
      ['name'] = 'empty_drum',
      ['label'] = 'Empty Oil Drum',
      ['weight'] = 1500,
      ['type'] = 'item',
      ['image'] = 'empty_drum.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'An empty drum for packaging refined oil'
  },
  ['packaged_light_pure'] = {
      ['name'] = 'packaged_light_pure',
      ['label'] = 'Packaged Pure Light Oil',
      ['weight'] = 3000,
      ['type'] = 'item',
      ['image'] = 'packaged_light_pure.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'High-quality light oil ready for delivery'
  },
  ['packaged_light_standard'] = {
      ['name'] = 'packaged_light_standard',
      ['label'] = 'Packaged Standard Light Oil',
      ['weight'] = 3000,
      ['type'] = 'item',
      ['image'] = 'packaged_light_standard.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'Standard-quality light oil ready for delivery'
  },
  ['packaged_light_dirty'] = {
      ['name'] = 'packaged_light_dirty',
      ['label'] = 'Packaged Dirty Light Oil',
      ['weight'] = 3000,
      ['type'] = 'item',
      ['image'] = 'packaged_light_dirty.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'Low-quality light oil ready for delivery'
  },
  ['packaged_heavy_pure'] = {
      ['name'] = 'packaged_heavy_pure',
      ['label'] = 'Packaged Pure Heavy Oil',
      ['weight'] = 3500,
      ['type'] = 'item',
      ['image'] = 'packaged_heavy_pure.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'High-quality heavy oil ready for delivery'
  },
  ['packaged_heavy_standard'] = {
      ['name'] = 'packaged_heavy_standard',
      ['label'] = 'Packaged Standard Heavy Oil',
      ['weight'] = 3500,
      ['type'] = 'item',
      ['image'] = 'packaged_heavy_standard.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'Standard-quality heavy oil ready for delivery'
  },
  ['packaged_heavy_dirty'] = {
      ['name'] = 'packaged_heavy_dirty',
      ['label'] = 'Packaged Dirty Heavy Oil',
      ['weight'] = 3500,
      ['type'] = 'item',
      ['image'] = 'packaged_heavy_dirty.png',
      ['unique'] = false,
      ['useable'] = false,
      ['shouldClose'] = false,
      ['combinable'] = nil,
      ['description'] = 'Low-quality heavy oil ready for delivery'
  },
```
</details>

<details> <summary>ESX Items</summary> 
	
```lua
	['empty_oil'] = {
    ['name'] = 'empty_oil',
    ['label'] = 'Empty Oil Container',
    ['weight'] = 1000,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'empty_oil.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'An empty container for collecting crude oil'
},
['crude_light'] = {
    ['name'] = 'crude_light',
    ['label'] = 'Light Crude Oil',
    ['weight'] = 2000,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'crude_light.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'Unrefined light crude oil'
},
['crude_heavy'] = {
    ['name'] = 'crude_heavy',
    ['label'] = 'Heavy Crude Oil',
    ['weight'] = 2500,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'crude_heavy.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'Unrefined heavy crude oil'
},
['refined_light_pure'] = {
    ['name'] = 'refined_light_pure',
    ['label'] = 'Pure Light Oil',
    ['weight'] = 1800,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'refined_light_pure.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'High-quality refined light oil'
},
['refined_light_standard'] = {
    ['name'] = 'refined_light_standard',
    ['label'] = 'Standard Light Oil',
    ['weight'] = 1800,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'refined_light_standard.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'Standard-quality refined light oil'
},
['refined_light_dirty'] = {
    ['name'] = 'refined_light_dirty',
    ['label'] = 'Dirty Light Oil',
    ['weight'] = 1800,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'refined_light_dirty.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'Low-quality refined light oil'
},
['refined_heavy_pure'] = {
    ['name'] = 'refined_heavy_pure',
    ['label'] = 'Pure Heavy Oil',
    ['weight'] = 2200,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'refined_heavy_pure.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'High-quality refined heavy oil'
},
['refined_heavy_standard'] = {
    ['name'] = 'refined_heavy_standard',
    ['label'] = 'Standard Heavy Oil',
    ['weight'] = 2200,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'refined_heavy_standard.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'Standard-quality refined heavy oil'
},
['refined_heavy_dirty'] = {
    ['name'] = 'refined_heavy_dirty',
    ['label'] = 'Dirty Heavy Oil',
    ['weight'] = 2200,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'refined_heavy_dirty.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'Low-quality refined heavy oil'
},
['empty_drum'] = {
    ['name'] = 'empty_drum',
    ['label'] = 'Empty Oil Drum',
    ['weight'] = 1500,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'empty_drum.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'An empty drum for packaging refined oil'
},
['packaged_light_pure'] = {
    ['name'] = 'packaged_light_pure',
    ['label'] = 'Packaged Pure Light Oil',
    ['weight'] = 3000,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'packaged_light_pure.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'High-quality light oil ready for delivery'
},
['packaged_light_standard'] = {
    ['name'] = 'packaged_light_standard',
    ['label'] = 'Packaged Standard Light Oil',
    ['weight'] = 3000,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'packaged_light_standard.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'Standard-quality light oil ready for delivery'
},
['packaged_light_dirty'] = {
    ['name'] = 'packaged_light_dirty',
    ['label'] = 'Packaged Dirty Light Oil',
    ['weight'] = 3000,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'packaged_light_dirty.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'Low-quality light oil ready for delivery'
},
['packaged_heavy_pure'] = {
    ['name'] = 'packaged_heavy_pure',
    ['label'] = 'Packaged Pure Heavy Oil',
    ['weight'] = 3500,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'packaged_heavy_pure.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'High-quality heavy oil ready for delivery'
},
['packaged_heavy_standard'] = {
    ['name'] = 'packaged_heavy_standard',
    ['label'] = 'Packaged Standard Heavy Oil',
    ['weight'] = 3500,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'packaged_heavy_standard.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'Standard-quality heavy oil ready for delivery'
},
['packaged_heavy_dirty'] = {
    ['name'] = 'packaged_heavy_dirty',
    ['label'] = 'Packaged Dirty Heavy Oil',
    ['weight'] = 3500,
    ['rare'] = 0,
    ['can_remove'] = 1,
    ['type'] = 'item',
    ['image'] = 'packaged_heavy_dirty.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['description'] = 'Low-quality heavy oil ready for delivery'
},
```

</details> <details> <summary>ox_inventory Items</summary>
	
```lua
		['empty_oil'] = {
		    label = 'Empty Oil Container',
		    weight = 1000,
		    stack = true,
		    close = false,
		    description = 'An empty container for collecting crude oil'
		},
		['crude_light'] = {
		    label = 'Light Crude Oil',
		    weight = 2000,
		    stack = true,
		    close = false,
		    description = 'Unrefined light crude oil'
		},
		['crude_heavy'] = {
		    label = 'Heavy Crude Oil',
		    weight = 2500,
		    stack = true,
		    close = false,
		    description = 'Unrefined heavy crude oil'
		},
		['refined_light_pure'] = {
		    label = 'Pure Light Oil',
		    weight = 1800,
		    stack = true,
		    close = false,
		    description = 'High-quality refined light oil'
		},
		['refined_light_standard'] = {
		    label = 'Standard Light Oil',
		    weight = 1800,
		    stack = true,
		    close = false,
		    description = 'Standard-quality refined light oil'
		},
		['refined_light_dirty'] = {
		    label = 'Dirty Light Oil',
		    weight = 1800,
		    stack = true,
		    close = false,
		    description = 'Low-quality refined light oil'
		},
		['refined_heavy_pure'] = {
		    label = 'Pure Heavy Oil',
		    weight = 2200,
		    stack = true,
		    close = false,
		    description = 'High-quality refined heavy oil'
		},
		['refined_heavy_standard'] = {
		    label = 'Standard Heavy Oil',
		    weight = 2200,
		    stack = true,
		    close = false,
		    description = 'Standard-quality refined heavy oil'
		},
		['refined_heavy_dirty'] = {
		    label = 'Dirty Heavy Oil',
		    weight = 2200,
		    stack = true,
		    close = false,
		    description = 'Low-quality refined heavy oil'
		},
		['empty_drum'] = {
		    label = 'Empty Oil Drum',
		    weight = 1500,
		    stack = true,
		    close = false,
		    description = 'An empty drum for packaging refined oil'
		},
		['packaged_light_pure'] = {
		    label = 'Packaged Pure Light Oil',
		    weight = 3000,
		    stack = true,
		    close = false,
		    description = 'High-quality light oil ready for delivery'
		},
		['packaged_light_standard'] = {
		    label = 'Packaged Standard Light Oil',
		    weight = 3000,
		    stack = true,
		    close = false,
		    description = 'Standard-quality light oil ready for delivery'
		},
		['packaged_light_dirty'] = {
		    label = 'Packaged Dirty Light Oil',
		    weight = 3000,
		    stack = true,
		    close = false,
		    description = 'Low-quality light oil ready for delivery'
		},
		['packaged_heavy_pure'] = {
		    label = 'Packaged Pure Heavy Oil',
		    weight = 3500,
		    stack = true,
		    close = false,
		    description = 'High-quality heavy oil ready for delivery'
		},
		['packaged_heavy_standard'] = {
		    label = 'Packaged Standard Heavy Oil',
		    weight = 3500,
		    stack = true,
		    close = false,
		    description = 'Standard-quality heavy oil ready for delivery'
		},
		['packaged_heavy_dirty'] = {
		    label = 'Packaged Dirty Heavy Oil',
		    weight = 3500,
		    stack = true,
		    close = false,
		    description = 'Low-quality heavy oil ready for delivery'
		},
```
</details> 


## Shops
```lua
	OilCompany = {
		name = 'Los Santos Oil',
		blip = {
			id = 643, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'empty_oil', price = 35 }
		}, locations = {
			vec3(-41.36, -2148.09, 11.22)
		}, targets = {
			{ loc = vec3(-41.27, -2148.17, 10.89), length = 0.5, width = 3.0, heading = 270.0, minZ = 30.5, maxZ = 32.0, distance = 3 }
		}
	},
```
## Coming Soon
![](https://i.ibb.co/HDpjnrPK/image.png)

## Credits

- Created by Zotters
- UI Design by Zotters
- Special thanks to the FiveM community

## Version History

### 1.0.0
- Initial release
- Complete oil production chain
- Framework detection system
- Delivery system with time bonuses
- Refinery with quality-based outcomes
- Packaging system
- Dynamic oil extraction

### 1.0.1
- Added multi-target support
- Added script usage for non-target systems
- Updated Bridge 

---

Made with ❤️ by Zotters

