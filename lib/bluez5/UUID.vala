/*
 * bluez5 -- DBus bindings for BlueZ 5 <http://www.bluez.org>
 *
 * Copyright (C) 2015 David Lechner <david@lechnology.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY throws IOError; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * UUID.vala: Bluetooth UUIDs and string conversion functions.
 */

using GLib.Bus;

namespace BlueZ5.UUID {
    const string 16BIT_PREFIX = "0000";
    const string BASE = "-0000-1000-8000-00805f9b34fb";

    /**
     * Bluetooth Core Specification
     */
    public const string SDP = 16BIT_PREFIX + "0001" + BASE;

    /**
     * [NO USE BY PROFILES]
     */
    public const string UDP = 16BIT_PREFIX + "0002" + BASE;

    /**
     * RFCOMM with TS 07.10
     */
    public const string RFCOMM = 16BIT_PREFIX + "0003" + BASE;

    /**
     * [NO USE BY PROFILES]
     */
    public const string TCP = 16BIT_PREFIX + "0004" + BASE;

    /**
     * Telephony Control Specification / TCS Binary
     */
    [Deprecated]
    public const string TCS_BIN = 16BIT_PREFIX + "0005" + BASE;

    /**
     * [NO USE BY PROFILES]
     */
    public const string TCS_AT = 16BIT_PREFIX + "0006" + BASE;

    /**
     * Attribute Protocol
     */
    public const string ATT = 16BIT_PREFIX + "0007" + BASE;

    /**
     * IrDA Interoperability
     */
     public const string OBEX = 16BIT_PREFIX + "0008" + BASE;

    /**
     * [NO USE BY PROFILES]
     */
    public const string IP = 16BIT_PREFIX + "0009" + BASE;

    /**
     * [NO USE BY PROFILES]
     */
    public const string FTP = 16BIT_PREFIX + "000a" + BASE;

    /**
     * [NO USE BY PROFILES]
     */
    public const string HTTP = 16BIT_PREFIX + "000c" + BASE;

    /**
     * [NO USE BY PROFILES]
     */
    public const string WSP = 16BIT_PREFIX + "000e" + BASE;

    /**
     * Bluetooth Network Encapsulation Protocol (BNEP)
     */
    public const string BNEP = 16BIT_PREFIX + "000f" + BASE;

    /**
     * Extended Service Discovery Profile (ESDP)
     */
    [Deprecated]
    public const string UPNP = 16BIT_PREFIX + "0010" + BASE;

    /**
     * Human Interface Device Profile (HID)
     */
     public const string HIDP = 16BIT_PREFIX + "0011" + BASE;

    /**
     * Hardcopy Cable Replacement Profile (HCRP)
     */
    public const string HardcopyControlChannel = 16BIT_PREFIX + "0012" + BASE;

    /**
     * See Hardcopy Cable Replacement Profile (HCRP)
     */
    public const string HardcopyDataChannel = 16BIT_PREFIX + "0014" + BASE;

    /**
     * Hardcopy Cable Replacement Profile (HCRP)
     */
    public const string HardcopyNotification = 16BIT_PREFIX + "0016" + BASE;

    /**
     * Audio/Video Control Transport Protocol (AVCTP)
     */
    public const string AVCTP = 16BIT_PREFIX + "0017" + BASE;

    /**
     * Audio/Video Distribution Transport Protocol (AVDTP)
     */
    public const string AVDTP = 16BIT_PREFIX + "0019" + BASE;

    /**
     * Common ISDN Access Profile (CIP)
     */
    [Deprecated]
    public const string CMTP = 16BIT_PREFIX + "001B" + BASE;

    /**
     * Multi-Channel Adaptation Protocol (MCAP)
     */
    public const string MCAPControlChannel = 16BIT_PREFIX + "001e" + BASE;

    /**
     * Multi-Channel Adaptation Protocol (MCAP)
     */
    public const string MCAPDataChannel = 16BIT_PREFIX + "001f" + BASE;

    /**
     * Bluetooth Core Specification
     */
    public const string L2CAP = 16BIT_PREFIX + "0100" + BASE;

    /**
     * Bluetooth Core Specification
     *
     * Service Class
     */
    public const string ServiceDiscoveryServer = 16BIT_PREFIX + "1000" + BASE;

    /**
     * Bluetooth Core Specification
     *
     * Service Class
     */
    public const string BrowseGroupDescriptor = 16BIT_PREFIX + "1001" + BASE;

    /**
     * Serial Port Profile (SPP)
     *
     * NOTE: The example SDP record in SPP v1.0 does not include a
     * BluetoothProfileDescriptorList attribute, but some implementations
     * may also use this UUID for the Profile Identifier.
     *
     * Service Class/ Profile
     */
    public const string SerialPort = 16BIT_PREFIX + "1101" + BASE;

    /**
     * LAN Access
     *
     * Profile
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier.
     *
     * Service Class/ Profile
     */
    [Deprecated]
    public const string LANAccessUsingPPP = 16BIT_PREFIX + "1102" + BASE;

    /**
     * Dial-up Networking Profile (DUN)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier.
     *
     * Service Class/ Profile
     */
    public const string DialupNetworking = 16BIT_PREFIX + "1103" + BASE;

    /**
     * Synchronization Profile (SYNC)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier.
     *
     * Service Class/ Profile
     */
    public const string IrMCSync = 16BIT_PREFIX + "1104" + BASE;

    /**
     * Object Push Profile (OPP)
     *
     * NOTE: Used as both Service Class Identifier and Profile.
     *
     * Service Class/ Profile
     */
    public const string OBEXObjectPush = 16BIT_PREFIX + "1105" + BASE;

    /**
     * File Transfer Profile (FTP)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier.
     *
     * Service Class/ Profile
     */
    public const string OBEXFileTransfer = 16BIT_PREFIX + "1106" + BASE;

    /**
     * Synchronization Profile (SYNC)
     */
    public const string IrMCSyncCommand = 16BIT_PREFIX + "1107" + BASE;

    /**
     * Headset Profile (HSP)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier.
     *
     * Service Class/ Profile
     */
    public const string Headset = 16BIT_PREFIX + "1108" + BASE;

    /**
     * Cordless Telephony Profile (CTP)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier.
     *
     * Service Class/ Profile
     */
    [Deprecated]
    public const string CordlessTelephony = 16BIT_PREFIX + "1109" + BASE;

    /**
     * Advanced Audio Distribution Profile (A2DP)
     *
     * Service Class
     */
    public const string AudioSource = 16BIT_PREFIX + "110a" + BASE;

    /**
     * Advanced Audio Distribution Profile (A2DP)
     *
     * Service Class
     */
    public const string AudioSink = 16BIT_PREFIX + "110b" + BASE;

    /**
     * Audio/Video Remote Control Profile (AVRCP)
     *
     * Service Class
     */
    public const string AV_RemoteControlTarget = 16BIT_PREFIX + "110c" + BASE;

    /**
     * Advanced Audio Distribution Profile (A2DP)
     *
     * Profile
     */
    public const string AdvancedAudioDistribution = 16BIT_PREFIX + "110d" + BASE;

    /**
     * Audio/Video Remote Control Profile (AVRCP)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier.
     *
     * Service Class/ Profile
     */
    public const string AV_RemoteControl = 16BIT_PREFIX + "110e" + BASE;

    /**
     * Audio/Video Remote Control Profile (AVRCP)
     *
     * NOTE: The AVRCP specification v1.3 and later require that 0x110E also
     * be included in the ServiceClassIDList before 0x110F for backwards
     * compatibility.
     *
     * Service Class
     */
    public const string AV_RemoteControlController = 16BIT_PREFIX + "110f" + BASE;

    /**
     * Intercom Profile (ICP)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier.
     *
     * Service Class
     */
    [Deprecated]
    public const string Intercom = 16BIT_PREFIX + "1110" + BASE;

    /**
     * Fax Profile (FAX)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier.
     *
     * Service Class
     */
    [Deprecated]
    public const string Fax = 16BIT_PREFIX + "1111" + BASE;

    /**
     * Headset Profile (HSP)
     *
     * Service Class
     */
    public const string Headset_Audio_Gateway = 16BIT_PREFIX + "1112" + BASE;

    /**
     * Interoperability Requirements for Bluetooth technology as a WAP,
     * Bluetooth SIG
     *
     * Service Class
     */
    [Deprecated]
    public const string WAP = 16BIT_PREFIX + "1113" + BASE;

    /**
     * Interoperability Requirements for Bluetooth technology as a WAP,
     * Bluetooth SIG
     *
     * Service Class
     */
    [Deprecated]
    public const string WAP_CLIENT = 16BIT_PREFIX + "1114" + BASE;

    /**
     * Personal Area Networking Profile (PAN)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier
     * for PANU role.
     *
     * Service Class / Profile
     */
    public const string PANU = 16BIT_PREFIX + "1115" + BASE;

    /**
     * Personal Area Networking Profile (PAN)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier
     * for NAP role.
     *
     * Service Class / Profile
     */
    public const string NAP = 16BIT_PREFIX + "1116" + BASE;

    /**
     * Personal Area Networking Profile (PAN)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier
     * for GN role.
     *
     * Service Class / Profile
     */
    public const string GN = 16BIT_PREFIX + "1117" + BASE;

    /**
     * Basic Printing Profile (BPP)
     *
     * Service Class
     */
    public const string DirectPrinting = 16BIT_PREFIX + "1118" + BASE;

    /**
     * See Basic Printing Profile (BPP)
     *
     * Service Class
     */
    public const string ReferencePrinting = 16BIT_PREFIX + "1119" + BASE;

    /**
     * Basic Imaging Profile (BIP)
     *
     * Profile
     */
    public const string BasicImagingProfile = 16BIT_PREFIX + "111a" + BASE;

    /**
     * Basic Imaging Profile (BIP)
     *
     * Service Class
     */
    public const string ImagingResponder = 16BIT_PREFIX + "111b" + BASE;

    /**
     * Basic Imaging Profile (BIP)
     *
     * Service Class
     */
    public const string ImagingAutomaticArchive = 16BIT_PREFIX + "111c" + BASE;

    /**
     * Basic Imaging Profile (BIP)
     *
     * Service Class
     */
    public const string ImagingReferencedObjects = 16BIT_PREFIX + "111d" + BASE;

    /**
     * Hands-Free Profile (HFP)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier.
     *
     * Service Class / Profile
     */
    public const string Handsfree = 16BIT_PREFIX + "111e" + BASE;

    /**
     * Hands-free Profile (HFP)
     *
     * Service Class
     */
    public const string HandsfreeAudioGateway = 16BIT_PREFIX + "111f" + BASE;

    /**
     * Basic Printing Profile (BPP)
     *
     * Service Class
     */
    public const string DirectPrintingReferenceObjectsService = 16BIT_PREFIX + "1120" + BASE;

    /**
     * Basic Printing Profile (BPP)
     *
     * Service Class
     */
    public const string ReflectedUI = 16BIT_PREFIX + "1121" + BASE;

    /**
     * Basic Printing Profile (BPP)
     *
     * Profile
     */
    public const string BasicPrinting = 16BIT_PREFIX + "1122" + BASE;

    /**
     * Basic Printing Profile (BPP)
     *
     * Service Class
     */
    public const string PrintingStatus = 16BIT_PREFIX + "1123" + BASE;

    /**
     * Human Interface Device (HID)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier.
     *
     * Service Class / Profile
     */
    public const string HumanInterfaceDeviceService = 16BIT_PREFIX + "1124" + BASE;

    /**
     * Hardcopy Cable Replacement Profile (HCRP)
     *
     * Profile
     */
    public const string HardcopyCableReplacement = 16BIT_PREFIX + "1125" + BASE;

    /**
     * Hardcopy Cable Replacement Profile (HCRP)
     *
     * Service Class
     */
    public const string HCR_Print = 16BIT_PREFIX + "1126" + BASE;

    /**
     * Hardcopy Cable Replacement Profile (HCRP)
     *
     * Service Class
     */
    public const string HCR_Scan = 16BIT_PREFIX + "1127" + BASE;

    /**
     * Common ISDN Access Profile (CIP)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier.
     *
     * Service Class / Profile
     */
    [Deprecated]
    public const string Common_ISDN_Access = 16BIT_PREFIX + "1128" + BASE;

    /**
     * SIM Access Profile (SAP)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier.
     *
     * Service Class / Profile
     */
    public const string SIM_Access = 16BIT_PREFIX + "112d" + BASE;

    /**
     * Phonebook Access Profile (PBAP)
     *
     * Service Class
     */
    public const string PhonebookAccessPCE = 16BIT_PREFIX + "112e" + BASE;

    /**
     * Phonebook Access Profile (PBAP)
     *
     * Service Class
     */
    public const string PhonebookAccessPSE = 16BIT_PREFIX + "112f" + BASE;

    /**
     * Phonebook Access Profile (PBAP)
     *
     * Profile
     */
    public const string PhonebookAccess = 16BIT_PREFIX + "1130" + BASE;

    /**
     * Headset Profile (HSP)
     *
     * NOTE: See erratum #3507.
     * 0x1108 and 0x1203 should also be included in the ServiceClassIDList
     * before 0x1131 for backwards compatibility.
     *
     * Service Class
     */
    public const string Headset_HS = 16BIT_PREFIX + "1131" + BASE;

    /**
     * Message Access Profile (MAP)
     *
     * Service Class
     */
    public const string MessageAccessServer = 16BIT_PREFIX + "1132" + BASE;

    /**
     * Message Access Profile (MAP)
     *
     * Service Class
     */
    public const string MessageNotificationServer = 16BIT_PREFIX + "1133" + BASE;

    /**
     * Message Access Profile (MAP)
     *
     * Profile
     */
    public const string MessageAccessProfile = 16BIT_PREFIX + "1134" + BASE;

    /**
     * Global Navigation Satellite System Profile (GNSS)
     *
     * Profile
     */
    public const string GNSS = 16BIT_PREFIX + "1135" + BASE;

    /**
     * Global Navigation Satellite System Profile (GNSS)
     *
     * Service Class
     */
    public const string GNSS_Server = 16BIT_PREFIX + "1136" + BASE;

    /**
     * 3D Synchronization Profile (3DSP)
     * Service Class
     */
    public const string 3D_Display = 16BIT_PREFIX + "0137" + BASE;

    /**
     * 3D Synchronization Profile (3DSP)
     *
     * Service Class
     */
    public const string 3D_Glasses = 16BIT_PREFIX + "1138" + BASE;

    /**
     * 3D Synchronization Profile (3DSP)
     *
     * Profile
     */
    public const string 3D_Synchronization = 16BIT_PREFIX + "0139" + BASE;

    /**
     * Multi-Profile Specification (MPS)
     *
     * Profile
     */
    public const string MPS_Profile = 16BIT_PREFIX + "113a" + BASE;

    /**
     * Multi-Profile Specification (MPS)
     *
     * Service Class
     */
    public const string MPS_SC = 16BIT_PREFIX + "113b" + BASE;

    /**
     * Calendar, Task, and Notes (CTN) Profile
     *
     * Service Class
     */
    public const string CTN_Access = 16BIT_PREFIX + "113c" + BASE;

    /**
     * Calendar Tasks and Notes (CTN) Profile
     *
     * Service Class
     */
    public const string CTN_Notification = 16BIT_PREFIX + "113d" + BASE;

    /**
     * Calendar Tasks and Notes (CTN) Profile
     *
     * Profile
     */
    public const string CTN_Profile = 16BIT_PREFIX + "113e" + BASE;

    /**
     * Device Identification (DID)
     *
     * NOTE: Used as both Service Class Identifier and Profile Identifier.
     *
     * Service Class / Profile
     */
    public const string PnPInformation = 16BIT_PREFIX + "1200" + BASE;

    /**
     * N/A
     *
     * Service Class
     */
    public const string GenericNetworking = 16BIT_PREFIX + "1201" + BASE;

    /**
     * N/A
     *
     * Service Class
     */
    public const string GenericFileTransfer = 16BIT_PREFIX + "1202" + BASE;

    /**
     * N/A
     *
     * Service Class
     */
    public const string GenericAudio = 16BIT_PREFIX + "1203" + BASE;

    /**
     * N/A
     *
     * Service Class
     */
    public const string GenericTelephony = 16BIT_PREFIX + "1204" + BASE;

    /**
     * Enhanced Service Discovery Profile (ESDP)
     *
     * Service Class
     */
    [Deprecated]
    public const string UPNP_Service = 16BIT_PREFIX + "1205" + BASE;

    /**
     * Enhanced Service Discovery Profile (ESDP)
     *
     * Service Class
     */
    [Deprecated]
    public const string UPNP_IP_Service = 16BIT_PREFIX + "1206" + BASE;

    /**
     * Enhanced Service Discovery Profile (ESDP)
     *
     * Service Class
     */
    [Deprecated]
    public const string ESDP_UPNP_IP_PAN = 16BIT_PREFIX + "1300" + BASE;

    /**
     * Enhanced Service Discovery Profile (ESDP)
     *
     * Service Class
     */
    [Deprecated]
    public const string ESDP_UPNP_IP_LAP = 16BIT_PREFIX + "1301" + BASE;

    /**
     * Enhanced Service Discovery Profile (ESDP)
     *
     * Service Class
     */
    [Deprecated]
    public const string ESDP_UPNP_L2CAP = 16BIT_PREFIX + "1302" + BASE;

    /**
     * Video Distribution Profile (VDP)
     *
     * Service Class
     */
    public const string VideoSource = 16BIT_PREFIX + "1303" + BASE;

    /**
     * Video Distribution Profile (VDP)
     *
     * Service Class
     */
    public const string VideoSink = 16BIT_PREFIX + "1304" + BASE;

    /**
     * Video Distribution Profile (VDP)
     *
     * Profile
     */
    public const string VideoDistribution = 16BIT_PREFIX + "1305" + BASE;

    /**
     * Health Device Profile
     *
     * Profile
     */
    public const string HDP = 16BIT_PREFIX + "1400" + BASE;

    /**
     * Health Device Profile (HDP)
     *
     * Service Class
     */
    public const string HDP_Source = 16BIT_PREFIX + "1401" + BASE;

    /**
     * Health Device Profile (HDP)
     *
     * Service Class
     */
    public const string HDP_Sink = 16BIT_PREFIX + "1402" + BASE;

    /**
     * Gets the 3 to 6 (or more) character profile name for a given UUID.
     */
    public string to_short_profile (string uuid) {
        switch (uuid) {
        case SDP:
            return "SDP";
        case UDP:
            return "UDP";
        case RFCOMM:
            return "RFCOMM";
        case TCP:
            return "TCP";
        case TCS_BIN:
        case TCS_AT:
            return "TCS";
        case ATT:
            return "ATT";
        case OBEX:
            return "OBEX";
        case IP:
            return "IP";
        case FTP:
            return "FTP";
        case HTTP:
            return "HTTP";
        case WSP:
            return "WSP";
        case BNEP:
            return "BNEP";
        case UPNP:
            return "UPNP";
        case HIDP:
            return "HIDP";
        case HardcopyControlChannel:
        case HardcopyDataChannel:
        case HardcopyNotification:
            return "HCRP";
        case AVCTP:
            return "AVCTP";
        case AVDTP:
            return "AVDTP";
        case CMTP:
            return "CMTP";
        case MCAPControlChannel:
        case MCAPDataChannel:
            return "MCAP";
        case L2CAP:
            return "L2CAP";
        case ServiceDiscoveryServer:
            return "ServiceDiscoveryServer";
        case BrowseGroupDescriptor:
            return "BrowseGroupDescriptor";
        case SerialPort:
            return "SPP";
        case LANAccessUsingPPP:
            return "LANAccessUsingPPP";
        case DialupNetworking:
            return "DUN";
        case IrMCSync:
            return "SYNC";
        case OBEXObjectPush:
            return "OPP";
        case OBEXFileTransfer:
            return "FTP";
        case IrMCSyncCommand:
            return "SYNC";
        case Headset:
            return "HSP";
        case CordlessTelephony:
            return "CTP";
        case AudioSource:
        case AudioSink:
            return "A2DP";
        case AV_RemoteControlTarget:
            return "AVRCP";
        case AdvancedAudioDistribution:
            return "A2DP";
        case AV_RemoteControl:
        case AV_RemoteControlController:
            return "AVRCP";
        case Intercom:
            return "ICP";
        case Fax:
            return "FAX";
        case Headset_Audio_Gateway:
            return "HSP";
        case WAP:
        case WAP_CLIENT:
            return "WAP";
        case PANU:
        case NAP:
        case GN:
            return "PAN";
        case DirectPrinting:
        case ReferencePrinting:
            return "BPP";
        case BasicImagingProfile:
        case ImagingResponder:
        case ImagingAutomaticArchive:
        case ImagingReferencedObjects:
            return "BIP";
        case Handsfree:
        case HandsfreeAudioGateway:
            return "HFP";
        case DirectPrintingReferenceObjectsService:
        case ReflectedUI:
        case BasicPrinting:
        case PrintingStatus:
            return "BPP";
        case HumanInterfaceDeviceService:
            return "HID";
        case HardcopyCableReplacement:
        case HCR_Print:
        case HCR_Scan:
            return "HCRP";
        case Common_ISDN_Access:
            return "CIP";
        case SIM_Access:
            return "SAP";
        case PhonebookAccessPCE:
        case PhonebookAccessPSE:
        case PhonebookAccess:
            return "PBAP";
        case Headset_HS:
            return "HSP";
        case MessageAccessServer:
        case MessageNotificationServer:
        case MessageAccessProfile:
            return "MAP";
        case GNSS:
        case GNSS_Server:
            return "GNSS";
        case 3D_Display:
        case 3D_Glasses:
        case 3D_Synchronization:
            return "3DSP";
        case MPS_Profile:
        case MPS_SC:
            return "MPS";
        case CTN_Access:
        case CTN_Notification:
        case CTN_Profile:
            return "CTN";
        case PnPInformation:
            return "DID";
        case GenericNetworking:
            return "GenericNetworking";
        case GenericFileTransfer:
            return "GenericFileTransfer";
        case GenericAudio:
            return "GenericAudio";
        case GenericTelephony:
            return "GenericTelephony";
        case UPNP_Service:
        case UPNP_IP_Service:
        case ESDP_UPNP_IP_PAN:
        case ESDP_UPNP_IP_LAP:
        case ESDP_UPNP_L2CAP:
            return "ESDP";
        case VideoSource:
        case VideoSink:
        case VideoDistribution:
            return "VDP";
        case HDP:
        case HDP_Source:
        case HDP_Sink:
            return "HDP";
        default:
            return "Unknown";
        }
    }
}
