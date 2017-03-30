// Adding PNLF device for AppleBacklight.kext

DefinitionBlock("", "SSDT", 2, "hack", "PNLF", 0)
{
    External(_SB.PCI0, DeviceObj)
    Scope(_SB.PCI0)
    {
        External(IGPU, DeviceObj)
        Scope(IGPU)
        {
            OperationRegion(IGD5, PCI_Config, 0, 0x14)
            Field(IGD5, AnyAcc, NoLock, Preserve)
            {
                Offset(0x10),
                BAR1, 32,
            }
            
            Device(PNLF)
            {
                Name(_ADR, Zero)
                Name(_HID, EisaId ("APP0002"))
                Name(_CID, "backlight")
                Name(_UID, 0x0C)
                Name(_STA, 0x0B)
                
                OperationRegion(RMB1, SystemMemory, ^BAR1 & ~0xF, 0xe1184)
                Field(RMB1, AnyAcc, Lock, Preserve)
                {
                    Offset(0x48250),
                    LEV2, 32,
                    LEVL, 32,
                    Offset(0x70040),
                    P0BL, 32,
                    Offset(0xc8250),
                    LEVW, 32,
                    LEVX, 32,
                    Offset(0xe1180),
                    PCHL, 32,
                }
                
                Method(_INI)
                {
                    Local2 = 0x56c
                    // This 0xC value comes from looking what OS X initializes this
                    // register to after display sleep (using ACPIDebug/ACPIPoller)
                    LEVW = 0xC0000000
                    // change/scale only if different than current...
                    Local1 = LEVX >> 16
                    If (!Local1) { Local1 = Local2 }
                    If (Local2 != Local1)
                    {
                        // set new backlight PWMAX but retain current backlight level by scaling
                        Local0 = (((LEVX & 0xFFFF) * Local2) / Local1) | (Local2 << 16)
                        LEVX = Local0
                    }
                }
            }
        }
    }
}
//EOF