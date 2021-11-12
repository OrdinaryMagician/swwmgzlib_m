This repository contains shared code and assets used by all **SWWM GZ** side mods *(**Red Oni**, **Red-Eyed Rampage**, **Red Star of Innocence**)*.

It is meant to be merged into them when building a mod archive. Note that due to how **ZScript** class extending works, this can't be loaded as a folder, you have to build a pk3/pk7 archive, otherwise **GZDoom** will complain and quit out.

Shared code and assets are added and tweaked as needed by the side mods. In most cases code will be 1:1 to **SWWM GZ** itself, unless some specific changes are needed. Additionally, several features have been stripped, as they are unused in these mods.

Functions that must be extended:

- **`private ui void SWWMHandler.RenderShaders( RenderEvent e )`**<br/>
  Used for rendering mod-specific shaders.
- **`static clearscope void SWWMHandler.ClearAllShaders( PlayerInfo p, bool noscope = false )`**<br/>
  Used when we want to disable all shaders.<br/>
  *noscope* : Don't disable scope overlay shaders.
- **`private bool SWWMHandler.ModReplacement( ReplaceEvent e )`**<br/>
  Used for mod-specific replacements. Return false if nothing was replaced.
- **`private ui void SWWMHandler.ModConsoleProcess( ConsoleEvent e )`**<br/>
  Used for mod-specific console event processing.
- **`private void SWWMHandler.ModNetworkProcess( ConsoleEvent e )`**<br/>
  Used for mod-specific network event processing.
- **`static play bool SWWMUtility.ValidProjectile( Actor a )`**<br/>
  Required by some shared code. Used to finetune projectile detection.<br/>
  This is mainly needed to handle false positives returned by `IsZeroDamage()`.

Constants that must be defined:

- **`const String SWWMMODPREFIX`**<br/>
  Prefix for mod CVars and others *(oni/saya/kirin)*.
- **`const int SWWMMAXBACKPACK`**<br/>
  Maximum **Hammerspace Embiggener** amount. Can be set to zero if it's not used *(kirin)*.
- **`const Color SWWMHEALTHFLASH`**<br/>
  Color for healing flashes.
- **`const Color SWWMARMORFLASH`**<br/>
  Color for armor flashes.
- **`const String SWWMLOGONAME`**<br/>
  Base name of the M_DOOM equivalent *(M_REDONI/M_SAYA/M_KIRIN)*.
- **`const int SWWMCREDITSCOL0`**<br/>
  Color of credits section header.
- **`const int SWWMCREDITSCOL1`**<br/>
  Color of credits entry header.
- **`const int SWWMCREDITSCOL2`**<br/>
  Color of credits entry text.

The ***TODO*** list:

- Streamlined **`SWWMHelpMenu`**.
- Generic **`SWWMStatusBar`** base class with reusable functions.
- Generic **`SWWMPlayer`** class with reusable functions.
