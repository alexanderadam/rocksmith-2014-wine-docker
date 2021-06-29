# :whale2: Docker container image for :guitar: Rocksmith 2014 Remastered from :cyclone: Ubisoft

## :grey_question: What is it about?

[Rocksmith](https://www.ubisoft.com/en-us/game/rocksmith/), [Rocksmith 2014](https://www.ubisoft.com/en-us/game/rocksmith-2014-edition/) and [Rocksmith 2014 remastered](https://www.ubisoft.com/en-us/game/rocksmith-2014-remastered-edition) are music video games by [Ubisoft](https://www.ubisoft.com/).

It is the best guitar training software I found _but_ it is _not_ natively available on Linux.

So far you will need virtualization or a compatibility layer like [Wine](https://appdb.winehq.org/objectManager.php?sClass=version&iId=29333) or [Proton](https://github.com/ValveSoftware/Proton/issues/812) (see [protondb](https://www.protondb.com/app/221680)) to run it.
And even then you might run into various issues.
It would be nice being able just to install and run it [via winepak](https://www.winepak.org/) (i.e. `flatpak install winepak com.ubisoft.rocksmith2014`) but so far [there's no pak available](https://github.com/winepak/applications/issues/166).
You also might be interested in [that petition on change.org](https://www.change.org/p/ubisoft-port-rocksmith-2014-to-linux-natively) to support Rocksmith on Linux natively.

Proton [is working for _some_ people](https://www.protondb.com/app/221680) but still needs various fixes.

So this repository is basically an attempt to bring an easier :guitar: Rocksmith experience to :penguin: Linux.
Simply pulling and running a proper prebuild Docker image would be nice solution.

## :warning: Disclaimer :warning:

1. I did _not_ get it working. I'm running Rocksmith 2014 within a "real" Windows machine now (dual boot — and it has bugs even there). I guess the repository could be finished but currently I'm not seeing what is missing.
2. This repository is basically a merge of [@PedrioliLab's](https://github.com/PedrioliLab/docker-wine) and [@scottyhardy's](https://github.com/scottyhardy/docker-wine) repositories plus some tweaks and hints I found somewhere else. I think I linked all of them, so this might also help if you are struggeling with Rocksmith 2014 remastered on Wine in general.


## :gear: How to run

### :wrench: Setup

You can build the image with `docker build -t rocksmith .` (or just use `./build.sh`).

Afterwards might want to run `./run.sh setup /usr/bin/winecfg` first, to check whether audio is working in the audio tab and to install wine gecko and wine mono.

This image is using [the wine archive which does not provide `wine-gecko` or `wine-mono`. This means  you will be asked if you want to download those components. For best compatibility, it is recommended to click `Yes` here](https://wiki.winehq.org/Ubuntu#If_you_have_previously_used_the_distro_packages.2C_you_will_notice_some_differences_in_the_WineHQ_ones:).

### :guitar: Playing Rocksmith

Afterwards you might want to install or run Rocksmith by pointing wine to the executable of the mounted installer volume:

```bash
$ ./run.sh '/usr/bin/wine /home/user/rocksmith/Rocksmith2014.exe'
```

## :heavy_exclamation_mark: Errors and Pitfalls

### :snail: Poor performance

You can workaround the problem by disabling `d3d11`.

`winecfg` :arrow_right: `Libraries` :arrow_right: [`New override for library:` ] `d3d11` :arrow_right: `Add` :arrow_right: `Edit...` :arrow_right: `Disable`

And you might want to use the [`./ini_generator.sh`](ini_generator.sh) (from [playonlinux](https://www.playonlinux.com/en/topic-14040-Script_Rocksmith_2014_Steam.html)) to edit or generate `Rocksmith.ini`.

I had to lower the resolution even on "Windows" to have it working without stuttering although I'm running it with more than enough resources and a peroper graphic card. So this would obviously most probably be necessary on Linux machines, too.


### :electric_plug: Real Tone Cable not working

Call `pavucontrol` and disable `Rocksmith Guitar Adapter` in the `Configuration` tab.
You can check this with:

```bash
$ pactl list sources | grep -i 'Rocksmith'
```
If this command returns nothing it is successfully disabled. Otherwise you might check with `pacmd` as well.


If this is not working you might want to switch to ALSA instead of Pulseaudio:

```bash
$ ./run.sh winetricks settings sound=alsa
```

If this isn't working either, you should switch back with
```bash
$ ./run.sh winetricks settings sound=pulse
```

### :mute: No sound or message `ERROR SOUND INITIALIZATION`

If you see something like
`No audio output device is detected. Please connect and enable an audio output device then restart Rocksmith 2014.`

You may want to [try a solution from this Wiki page](https://github.com/mviereck/x11docker/wiki/Container-sound:-ALSA-or-Pulseaudio). Good luck!

### :computer: Black screen when starting the game

Seems to be [related to external monitors](https://www.codeweavers.com/compatibility/crossover/forum/rocksmith-2014-pc?msg=189332).
Try using just one monitor or run wine virtual desktop emulation in Graphics tab of `winecfg`.

### :warning: Other errors

You might want to follow one of those:
* [Reddit thread](https://www.reddit.com/r/SteamPlay/comments/appsuj/can_anyone_talk_me_through_rocksmith_setup_link/):
* [ProtonDB thread](https://www.protondb.com/app/221680)
* [Stackoverflow](https://gaming.stackexchange.com/questions/359910/how-to-play-rocksmith-2014-remastered-on-linux-using-the-usb-guitar-adapter)
* [PlayOnLinux](https://www.playonlinux.com/en/topic-14040-Script_Rocksmith_2014_Steam.html)

or [**DidYouKillMyFather**'s guide from reddit](https://www.reddit.com/r/SteamPlay/comments/appsuj/can_anyone_talk_me_through_rocksmith_setup_link/egak754/):

> 1.  Open a terminal
> 2.  Enter `WINEPREFIX=~/.steam/steam/steamapps/compatdata/221680/pfx winetricks sound=alsa` and press `[Enter]`
> 3.  Enter `WINEPREFIX=~/.steam/steam/steamapps/compatdata/221680/pfx winecfg` and press `[Enter]`
    * If either of these fail, run `sudo apt install wine-development winetricks` to install WINE and winetricks
> 4.  Go to Drives, select `Z:`, and set it to `~/.steam` in the Path box
> 5.  Click `OK`
> 6.  If the game does not pick up your guitar, run `apt install pavucontrol` (assuming you're on Ubuntu or Mint)
>
> That should do it for you. If it doesn't, do the following:
>
> 1.  From the above step 4, change Z: to `~/.local/share/Steam`
> 2.  Run `echo "default-fragments = 5" | sudo tee -a /etc/pulse/daemon.conf` and `echo "default-fragment-size-msec = 2" | sudo tee -a /etc/pulse/daemon.conf`
> 3.  In Steam, right-click Rocksmith and then enter Properties. From there go Set Launch Options and enter `PROTON_NO_D3D11=1 %command%`
> 4.  Click `OK` and then close the Properties window
>
> If you have any further problems you may be SoL for now. I'll decode what all this gibberish is a little later.
>
> **Explanations:**
>
> WINE can have different prefixes, which is like different Windows installations with tweaks to get specific applications running. By default you have a `~/.wine` folder. I'm not sure how far along you are in your Linux journey, but `~` means "_Home Directory_" and points you towards `/home/$USER/` (you can see this by opening a terminal and entering `echo $USER` and `echo $HOME`). This is the default `WINEPREFIX`, but every Proton game as a folder (`.../pfx`) which is it's own `WINEPREFIX` and has whatever tweaks it needs to be able to run, provided it's on the whitelist.
>
> In other words, in that command `WINEPREFIX=~/.steam/steam/steamapps/compatdata/221680/pfx winecfg` you're telling WINE that you want its "root" to be `~/.steam/steam/steamapps/compatdata/221680/pfx` and then run `winecfg` within that root. Same thing for the `winetricks` command.
>
> The `Z:` drive is just a "fake" drive that follows the Windows naming scheme (`A:` - `Z:`, as opposed to the near infinite `sd_`/`hd_`/`vd_`/`xd_` format that Linux has). You're setting this drive to look in your Steam's data folder, where Rocksmith will be able to see it. Some distributions use `~/.steam` but most of them use `~/.local/share/Steam`. Sometimes people will make a symbolic link between the two, especially if they distrohop a lot.
>
> `pavucontrol` is a program that makes PulseAudio a lot easier to use. It's almost like a mixing board that allows for finer control over all of your sound devices.
>
> `tee` is a program that redirects whatever you entered into a specified file. You can do this with redirects too (`echo "test" > example.txt`) but it's easier to use `tee` when you need superuser permissions. `tee -a` appends to the file, so you don't overwrite previous information. (EXAMPLE: `echo "Hi" | tee example.txt` `echo "Hi again" | tee -a example.txt`)


## :bulb: Hints

If you have the Rocksmith USB cable anyway, you also might want to have a look at [guitarix](https://guitarix.org/), [rakarrack](http://rakarrack.sourceforge.net/) (recent patches on [GitHub](https://github.com/Stazed/rakarrack)), [Ardour](https://github.com/Ardour/ardour) and [Hydrogen](http://hydrogen-music.org/downloads/).

## :construction: TODO

* Well, making it work in the first place. :wink:
* maybe integrating other [tweaks mentioned on WineHQ](https://www.winehq.org/search?q=Rocksmith+2014)
  * Use `winealsa.drv` instead of `pulseaudio` (edit the registry for that)
  * recommend using `2.7-staging` and turning on Enable_CSMT and EAX Set `Win32UltraLowLatencyMode=0` in `Rocksmith.ini`
  * setting `ExclusiveMode=0` in `Rocksmith.ini`?
  * Important: You need to open Pulse audio volume control (`pavucontrol`) and in the configuration tab disable Rocksmith guitar adapter so the guitar cable gets connected.
  * Change `load-module module-udev-detect` to `load-module module-udev-detect tsched=0` in `/etc/pulse/default.pa`
  * https://bugs.winehq.org/show_bug.cgi?id=35224
  * https://lutris.net/games/install/3319/view

* Open Wine configuration, Audio tab, and instead of system default set your current audio output as your output device

* https://wiki.archlinux.org/index.php/PulseAudio/Troubleshooting#Glitches.2C_skips_or_crackling

* Open Wine configuration, Audio tab, and instead of system default set your current audio output as your output device