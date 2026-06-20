# Mod-HAMMR Lite (aka Lite-HAMMR)

The Lite version of Mod-HAMMR, stripped down to it's initial meaning of just showing what mods are or should be deployed on your chars.

Standard conversation that you will hear between SWGOH players each an every day:

A: 
  - I cannot beat Tier 3 in event xyz
  - I always lose in GA
  - My guild always loses in TW
  - My guild doesn't perform in TB
  
B: Yeah, maybe your mods ain't good enough and the teams are not well equipped.

A: Really?

B: Sure, it's  often the mods, so as I said, they may not be good enough.

A: But then I need to know: How Are My Mods Really?


This is where Lite-HAMMR (How Are My Mods Really) may be helpful to you. This tool crawls through your SWGOH roster and shows you all your characters with their gear, power and how they are / should be modded.

Looking for his big brother that also let's you configure your teams like you play them or get consolidated data for your entire guild?
https://github.com/BerndFranzen/Mod-HAMMR


How to start
============
1) Make sure, you have Microsoft Powershell 7.00 or higher installed (Windows, Mac, Linux) (https://aka.ms/PSWindows)
2) Download Lite-HAMMR.ps1 to your Windows/Mac/Linux machine:
3) Unblock the PS1 file with "Unblock-File .\Lite-HAMMR.ps1"
4) Have your SWGOH allycode ready (e.g. 832123322)
5) Start the script in Microsoft Powershell 7.0.0 or higher like this:
    **.\Lite-HAMMR.ps1 832123322**

<img width="1466" height="251" alt="image" src="https://github.com/user-attachments/assets/3887bb42-a433-41a1-bb65-8258c2630f6e" />

 
What information will you get?
==============================
Basically the tool will drop a single HTML file with your player name:

<img width="2221" height="1715" alt="image" src="https://github.com/user-attachments/assets/ba0c54ad-8eb4-4f83-81c4-651f3a600f63" />


What does that data mean for me?
=================================
This is what the HTML file provides:
- Name          - The ingame name of the character, this may not reflect the name that you see in your localized version of the game but the API cannot return anythin else.
- Power         - The total power of this char
- Gear          - The Gear-level either G01-G13 or R01-R10 for relic chars
- Speed         - Speed of the character with the bonus given through mods in brackets
- MMScore       - The Mod Meta Score indicating the level of modding (see below for further explanations)
- Mod-Sets      - applied (black) or recommended (red) mod-sets for this char
- Mod-Slots     - if this field is black: Speed of this mod, number of rolls (improvements) on speed, mod-set of this mod, primary attribute of this mod, one or more "+" for any secondary attribute of this mod that matches the primary attribute and one or more "*" for any secondary attribute of this mod that matches on of the mod-sets.
- Mod-Slots    - if this field is red: The mod does not reflect the current Meta, this is the recommended primary attribute for this mod
- Mod Slots    - if this field is written in bold: The mod has a rarity of 6*

And now let's have a closer look on some characters, so you know what actions you have to take to make the results look better (and your teams perform better)

* Jedi Master Kenobi
  - has got a full MMScore of 150, what means that
    - the mod sets applied match the Meta
    - all mods have a primary that matches the Meta
    - all mods have speed either as primary or secondary attribute
    - all mods have been sliced to 6A
  - all mods that have a speed secondary attribute have been calibrated to that a total of (5) times speed has been added.
* Ahsoka Tano
  - has got a full MMScore of 150, but:
    - the MMScore only matches the (A)ll meta, not the Top-100 guilds
* Rey
  - only has an MMScore of 80, because:
    - the mod applied on the Receiver slot does currently not follow the Meta and should have either Health or Speed as primary attribute
  - several mods only show less than (5) rolls on speed, so I should also see if I can replace them by suitable mods with better speed or calibrate them to get additiona rolls
* Darth Vader
  - only has an MMScore of 30, because:
    - the mod sets applied overall do currently not follow the Meta and should be Critical Damage and Potency
    - the mods applied on 4 slots either do not have the right primary attributes or are not from a Critical Damage mod set
   
So, that gives me lists of characters to work on so that the actual mods applied reflect what is recommended through the Meta.

PREREQUISITES
=============
- Microsoft Powershell 7.0.0 or higher (Windows, Mac, Linux) (https://aka.ms/PSWindows)
- PSParseHTML Powershell Module (by EvotecIT), installed automatically if not present 
- Your allycode registered and synched on swgoh.gg

MMSCore
=======
NOTE: There is no absolute truth in modding, this tool just compares the mods to the current meta. You my find it usefull to mod a character differently for another game mode (JKL for example) or as it takes a different role in the squad that you play it in. This is only a SUGGESTION based on the current Meta!

What is the MMScore? the MMScore is intended to help you to learn from the best. It pulls all data from swgoh.gg' Mod Meta Report and compares the character's mods against this meta list and calculates the score as follows:
- Matching mod set 20 points for 4-mod sets (e.g. Speed) and 10 points for 2-mod sets (e.g. Health) (max. 30)
- Matching primary attribute 5 points per mod (max. 30)
- Speed on primary or secondary attribute 5 points per mod (max. 30)
- All mod sets and primaries matching and speed on all mods 10 points

This results in a total possible MMScore of 100. If the score is not reached, the recommended mod sets and primaries are listed, otherwise the assigned mods are listed with their speed, mod set and primary attribute.

If a char has reached an MMScore of 100, the rarity of each mod will be evaluated as well as when sclicing a mod from 5A to 6E, both, primary and all secondary get a status boost which increases the mod's value.
- For each mod with a rarity of 6* extra 5 points are added (max. 30)
- If all mods have been sliced to 6A extra 20 points are added

This results in a total possible MMScore of 150. All 6* mods equipped are printed in BOLD to highlight them and show you were you still can improve.

So there are basically 3 levels to achieve:
- 100 - all mods follow the current meta for this char and every mod has Speed on either primary or secondary attribute
- 130 - all mods have additionally been sliced to 6*
- 150 - all mods have additionally been sliced to 6A

NOTE: Mods below 5* and Level 15 are filtered and regarded as not present.

What is the difference between Strict and Relaxed mode?
- swgoh.gg provides 2 different lists of their Mod Meta Report, one using the Top 100 Guilds' mods and one from all players registerd.
- In Strict mode, the tool only uses the Top 100's mods and gives you the corresponding score
- In Relaxed mode, the score is calculated for both lists and the higher score is displayed.
- If the score from All players is used, this is indicated by the MMScore beinfollowed by "(A)"
- Relaxed mode has been added to handle the fact that meta sometime "flickers" and shows you a good score one day and a bad store every other day


Contact
=======
Allycode  832-123-322

Mail      swgoh-guildstats@outlook.com

Q&A
===
Q: Why does an MMScore of a character drop although I modded according to the recommendations?

A: Because it's Meta and this is constantly changing so you may need to re-mod from time to time.


Q: When I try to run the script on Windows I get an error preventing the execution because it's not signed.

A: You can exempt the script with the command "Unblock-File <script-name>".


Q: I have upgrades my chars but why do the pages still show the old values?
  
A: swgoh.gg only updates the stats every 24 hours. You can force a manual update through your profile page on your profile page of swgoh.gg. You can also update the entire guild once every 12 hours or become a "Patron" at swgoh.gg 
   for a small fee, which reduces the automatic update intervall and grants more manual refreshes per day.
