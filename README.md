# LTSConvert
A Powershell script to convert any 64-bit installation of Windows 10 to IoT Enterprise LTSC 2021 (EOL = January 13, 2032) without data loss - for those who want to avoid switching to Windows 11 and keep receiving updates on 10

The script has been tested and works on Windows 10 Home, Pro, and Education - but it should work on any 64-bit edition of Windows 10 because of the way it functions

![image](https://github.com/user-attachments/assets/24975610-81f6-47cc-a34d-e62ca219d462)

**_Instructions_**
- The Windows installer may hang a few times around 70-100% for a while - be patient and wait, it will continue
- After restarting, run the LTSConvert script again and choose Activation - Windows will no longer be activated after the conversion
- Choose Option 1 (HWID Activation) when the activation script runs - if it fails for some reason then choose option 4 (KMS38 Activation)
- After Windows activates, run Windows update to get the necessary LTSC updates



**_Common Questions_**

**Will I lose any data by doing this/does this remove anything I already have installed?**
- No! That's exactly the purpose of this, so you can switch without losing any data or having to do a fresh installation of Windows.

**Does IoT Enterprise LTSC 2021 support all of my programs/games/etc?**
- Yes! I've personally been using IoT Enterprise LTSC since 2019, and I can confirm that everything works just as you'd expect with Windows 10 Home/Pro/etc.

**IoT Enterprise LTSC 2021 is only on version 21H2 but my Windows 10 installation is on 22H2, will this still work without losing data?**
- Yes! I've been successfully able to use this on Home, Pro, and Education versions of 22H2 - they convert back to 21H2 just fine.

**Can I use a real key rather than MAS to activate Windows 10 IoT Enterprise LTSC 2021?**
- Yes! The only caveat being that they're generally pretty pricey ($150+) but this converts you to a full, real installation of Windows 10 IoT Enterprise LTSC 2021. Just skip the step of running step 3: Activate Windows in the launcher if you'd like to do this.
