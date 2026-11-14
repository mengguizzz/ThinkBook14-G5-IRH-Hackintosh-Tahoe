/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20260929 (64-bit version)
 * Copyright (c) 2000 - 2026 Intel Corporation
 *
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of SSDT-PNLF-RPL.aml
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x00000088 (136)
 *     Revision         0x02
 *     Checksum         0xFF
 *     OEM ID           "LOCAL"
 *     OEM Table ID     "PNLF"
 *     OEM Revision     0x00000000 (0)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20260929 (539363625)
 */
DefinitionBlock ("", "SSDT", 2, "LOCAL", "PNLF", 0x00000000)
{
    External (_SB_.PC00.GFX0, DeviceObj)

    If (_OSI ("Darwin"))
    {
        Scope (\_SB.PC00.GFX0)
        {
            Device (PNLF)
            {
                Name (_HID, EisaId ("APP0002"))  // _HID: Hardware ID
                Name (_CID, "backlight")  // _CID: Compatible ID
                Name (_UID, 0x13)  // _UID: Unique ID
                Name (_STA, 0x0B)  // _STA: Status
            }
        }
    }
}
