/*
 * bluez5 -- DBus bindings for BlueZ 5 <http://www.bluez.org>
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
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
 * UUID.vala: Enum that converts to/from UUID strings.
 */

using GLib.Bus;

namespace BlueZ5 {
    /**
     * Workaround for gio/gio.h not included.
     */
    [Deprecated]
    public DBusError workaround;

    [DBus (use_string_marshalling = true)]
    public enum UUID {
        /**
         * Bluetooth Core Specification
         */
        [DBus (value = "00000001-0000-1000-8000-00805F9B34FB")]
        SDP,

        /**
         * [NO USE BY PROFILES]
         */
        [DBus (value = "00000002-0000-1000-8000-00805F9B34FB")]
        UDP,

        /**
         * RFCOMM with TS 07.10
         */
        [DBus (value = "0000x000-0000-1000-8000-00805F9B34FB")]
        RFCOMM,

        /**
         * [NO USE BY PROFILES]
         */
        [DBus (value = "00000004-0000-1000-8000-00805F9B34FB")]
        TCP,

        /**
         * Telephony Control Specification / TCS Binary
         */
        [DBus (value = "00000005-0000-1000-8000-00805F9B34FB")]
        [Deprecated]
        TCS_BIN,

        /**
         * [NO USE BY PROFILES]
         */
        [DBus (value = "0000x000-0000-1000-8000-00805F9B34FB")]
        TCS_AT,

        /**
         * Attribute Protocol
         */
        [DBus (value = "00000007-0000-1000-8000-00805F9B34FB")]
        ATT,

        /**
         * IrDA Interoperability
         */
         [DBus (value = "00000008-0000-1000-8000-00805F9B34FB")]
        OBEX,

        /**
         * [NO USE BY PROFILES]
         */
        [DBus (value = "0000x000-0000-1000-8000-00805F9B34FB")]
        IP,

        /**
         * [NO USE BY PROFILES]
         */
        [DBus (value = "0000000A-0000-1000-8000-00805F9B34FB")]
        FTP,

        /**
         * [NO USE BY PROFILES]
         */
        [DBus (value = "0000000C-0000-1000-8000-00805F9B34FB")]
        HTTP,

        /**
         * [NO USE BY PROFILES]
         */
        [DBus (value = "0000000E-0000-1000-8000-00805F9B34FB")]
        WSP,

        /**
         * Bluetooth Network Encapsulation Protocol (BNEP)
         */
        [DBus (value = "0000000F-0000-1000-8000-00805F9B34FB")]
        BNEP,

        /**
         * Extended Service Discovery Profile (ESDP)
         */
        [DBus (value = "00000010-0000-1000-8000-00805F9B34FB")]
        [Deprecated]
        UPNP,

        /**
         * Human Interface Device Profile (HID)
         */
         [DBus (value = "00000011-0000-1000-8000-00805F9B34FB")]
        HIDP,

        /**
         * Hardcopy Cable Replacement Profile (HCRP)
         */
        [DBus (value = "00000012-0000-1000-8000-00805F9B34FB")]
        HardcopyControlChannel,

        /**
         * See Hardcopy Cable Replacement Profile (HCRP)
         */
        [DBus (value = "00000014-0000-1000-8000-00805F9B34FB")]
        HardcopyDataChannel,

        /**
         * Hardcopy Cable Replacement Profile (HCRP)
         */
        [DBus (value = "00000016-0000-1000-8000-00805F9B34FB")]
        HardcopyNotification,

        /**
         * Audio/Video Control Transport Protocol (AVCTP)
         */
        [DBus (value = "00000017-0000-1000-8000-00805F9B34FB")]
        AVCTP,

        /**
         * Audio/Video Distribution Transport Protocol (AVDTP)
         */
        [DBus (value = "00000019-0000-1000-8000-00805F9B34FB")]
        AVDTP,

        /**
         * Common ISDN Access Profile (CIP)
         */
        [DBus (value = "0000001B-0000-1000-8000-00805F9B34FB")]
        [Deprecated]
        CMTP,

        /**
         * Multi-Channel Adaptation Protocol (MCAP)
         */
        [DBus (value = "0000001E-0000-1000-8000-00805F9B34FB")]
        MCAPControlChannel,

        /**
         * Multi-Channel Adaptation Protocol (MCAP)
         */
        [DBus (value = "0000001F-0000-1000-8000-00805F9B34FB")]
        MCAPDataChannel,

        /**
         * Bluetooth Core Specification
         */
        [DBus (value = "00000100-0000-1000-8000-00805F9B34FB")]
        L2CAP,

        /**
         * Bluetooth Core Specification
         *
         * Service Class
         */
        [DBus (value = "00001000-0000-1000-8000-00805F9B34FB")]
        ServiceDiscoveryServer,

        /**
         * Bluetooth Core Specification
         *
         * Service Class
         */
        [DBus (value = "00001001-0000-1000-8000-00805F9B34FB")]
        BrowseGroupDescriptor,

        /**
         * Serial Port Profile (SPP)
         *
         * NOTE: The example SDP record in SPP v1.0 does not include a
         * BluetoothProfileDescriptorList attribute, but some implementations
         * may also use this UUID for the Profile Identifier.   Service Class/ Profile
         */
        [DBus (value = "00001101-0000-1000-8000-00805F9B34FB")]
        SerialPort,

        /**
         * LAN Access
         *
         * Profile
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier.
         * Service Class/ Profile
         */
        [DBus (value = "00001102-0000-1000-8000-00805F9B34FB")]
        [Deprecated]
        LANAccessUsingPPP,

        /**
         * Dial-up Networking Profile (DUN)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier.
         * Service Class/ Profile
         */
        [DBus (value = "00001103-0000-1000-8000-00805F9B34FB")]
        DialupNetworking,

        /**
         * Synchronization Profile (SYNC)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier. Service Class/ Profile
         */
        [DBus (value = "00001104-0000-1000-8000-00805F9B34FB")]
        IrMCSync,

        /**
         * Object Push Profile (OPP)
         *
         * NOTE: Used as both Service Class Identifier and Profile.    Service Class/ Profile
         */
        [DBus (value = "00001105-0000-1000-8000-00805F9B34FB")]
        OBEXObjectPush,

        /**
         * File Transfer Profile (FTP)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier. Service Class/ Profile
         */
        [DBus (value = "00001106-0000-1000-8000-00805F9B34FB")]
        OBEXFileTransfer,

        /**
         * Synchronization Profile (SYNC)
         */
        [DBus (value = "00001107-0000-1000-8000-00805F9B34FB")]
        IrMCSyncCommand,

        /**
         * Headset Profile (HSP)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier. Service Class/ Profile
         */
        [DBus (value = "00001108-0000-1000-8000-00805F9B34FB")]
        Headset,

        /**
         * Cordless Telephony Profile (CTP)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier.
         *
         * Service Class/ Profile
         */
        [DBus (value = "00001109-0000-1000-8000-00805F9B34FB")]
        [Deprecated]
        CordlessTelephony,

        /**
         * Advanced Audio Distribution Profile (A2DP)
         *
         * Service Class
         */
        [DBus (value = "0000110A-0000-1000-8000-00805F9B34FB")]
        AudioSource,

        /**
         * Advanced Audio Distribution Profile (A2DP)
         *
         * Service Class
         */
        [DBus (value = "0000110B-0000-1000-8000-00805F9B34FB")]
        AudioSink,

        /**
         * Audio/Video Remote Control Profile (AVRCP)
         *
         * Service Class
         */
        [DBus (value = "0000110C-0000-1000-8000-00805F9B34FB")]
        AV_RemoteControlTarget,

        /**
         * Advanced Audio Distribution Profile (A2DP)
         *
         * Profile
         */
        [DBus (value = "0000110D-0000-1000-8000-00805F9B34FB")]
        AdvancedAudioDistribution,

        /**
         * Audio/Video Remote Control Profile (AVRCP)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier. Service Class/ Profile
         */
        [DBus (value = "0000110E-0000-1000-8000-00805F9B34FB")]
        AV_RemoteControl,

        /**
         * Audio/Video Remote Control Profile (AVRCP)
         *
         * NOTE: The AVRCP specification v1.3 and later require that 0x110E also
         * be included in the ServiceClassIDList before 0x110F for backwards
         * compatibility.
         *
         * Service Class
         */
        [DBus (value = "0000110F-0000-1000-8000-00805F9B34FB")]
        AV_RemoteControlController,

        /**
         * Intercom Profile (ICP)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier.
         *
         * Service Class
         */
        [DBus (value = "00001110-0000-1000-8000-00805F9B34FB")]
        [Deprecated]
        Intercom,

        /**
         * Fax Profile (FAX)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier.
         *
         * Service Class
         */
        [DBus (value = "00001111-0000-1000-8000-00805F9B34FB")]
        [Deprecated]
        Fax,

        /**
         * Headset Profile (HSP)
         *
         * Service Class
         */
        [DBus (value = "00001112-0000-1000-8000-00805F9B34FB")]
        Headset_Audio_Gateway,

        /**
         * Interoperability Requirements for Bluetooth technology as a WAP,
         * Bluetooth SIG
         *
         * Service Class
         */
        [DBus (value = "00001113-0000-1000-8000-00805F9B34FB")]
        [Deprecated]
        WAP,

        /**
         * Interoperability Requirements for Bluetooth technology as a WAP,
         * Bluetooth SIG
         *
         * Service Class
         */
        [DBus (value = "00001114-0000-1000-8000-00805F9B34FB")]
        [Deprecated]
        WAP_CLIENT,

        /**
         * Personal Area Networking Profile (PAN)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier
         * for PANU role.
         *
          * Service Class / Profile
         */
        [DBus (value = "00001115-0000-1000-8000-00805F9B34FB")]
        PANU,

        /**
         * Personal Area Networking Profile (PAN)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier
         * for NAP role.
         *
          * Service Class / Profile
         */
        [DBus (value = "00001116-0000-1000-8000-00805F9B34FB")]
        NAP,

        /**
         * Personal Area Networking Profile (PAN)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier
         * for GN role.
         *
          * Service Class / Profile
         */
        [DBus (value = "00001117-0000-1000-8000-00805F9B34FB")]
        GN,

        /**
         * Basic Printing Profile (BPP)
         *
         * Service Class
         */
        [DBus (value = "00001118-0000-1000-8000-00805F9B34FB")]
        DirectPrinting,

        /**
         * See Basic Printing Profile (BPP)
         *
         * Service Class
         */
        [DBus (value = "00001119-0000-1000-8000-00805F9B34FB")]
        ReferencePrinting,

        /**
         * Basic Imaging Profile (BIP)
         *
         * Profile
         */
        [DBus (value = "0000111A-0000-1000-8000-00805F9B34FB")]
        BasicImagingProfile,

        /**
         * Basic Imaging Profile (BIP)
         *
         * Service Class
         */
        [DBus (value = "0000111B-0000-1000-8000-00805F9B34FB")]
        ImagingResponder,

        /**
         * Basic Imaging Profile (BIP)
         *
         * Service Class
         */
        [DBus (value = "0000111C-0000-1000-8000-00805F9B34FB")]
        ImagingAutomaticArchive,

        /**
         * Basic Imaging Profile (BIP)
         *
         * Service Class
         */
        [DBus (value = "0000111D-0000-1000-8000-00805F9B34FB")]
        ImagingReferencedObjects,

        /**
         * Hands-Free Profile (HFP)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier.
         *
          * Service Class / Profile
         */
        [DBus (value = "0000111E-0000-1000-8000-00805F9B34FB")]
        Handsfree,

        /**
         * Hands-free Profile (HFP)
         *
         * Service Class
         */
        [DBus (value = "0000111F-0000-1000-8000-00805F9B34FB")]
        HandsfreeAudioGateway,

        /**
         * Basic Printing Profile (BPP)
         *
         * Service Class
         */
        [DBus (value = "00001120-0000-1000-8000-00805F9B34FB")]
        DirectPrintingReferenceObjectsService,

        /**
         * Basic Printing Profile (BPP)
         *
         * Service Class
         */
        [DBus (value = "00001121-0000-1000-8000-00805F9B34FB")]
        ReflectedUI,

        /**
         * Basic Printing Profile (BPP)
         *
         * Profile
         */
        [DBus (value = "00001122-0000-1000-8000-00805F9B34FB")]
        BasicPrinting,

        /**
         * Basic Printing Profile (BPP)
         *
         * Service Class
         */
        [DBus (value = "00001123-0000-1000-8000-00805F9B34FB")]
        PrintingStatus,

        /**
         * Human Interface Device (HID)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier.
         *
          * Service Class / Profile
         */
        [DBus (value = "00001124-0000-1000-8000-00805F9B34FB")]
        HumanInterfaceDeviceService,

        /**
         * Hardcopy Cable Replacement Profile (HCRP)
         *
         * Profile
         */
        [DBus (value = "00001125-0000-1000-8000-00805F9B34FB")]
        HardcopyCableReplacement,

        /**
         * Hardcopy Cable Replacement Profile (HCRP)
         *
         * Service Class
         */
        [DBus (value = "00001126-0000-1000-8000-00805F9B34FB")]
        HCR_Print,

        /**
         * Hardcopy Cable Replacement Profile (HCRP)
         *
         * Service Class
         */
        [DBus (value = "00001127-0000-1000-8000-00805F9B34FB")]
        HCR_Scan,

        /**
         * Common ISDN Access Profile (CIP)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier.
         *
         * Service Class / Profile
         */
        [DBus (value = "00001128-0000-1000-8000-00805F9B34FB")]
        [Deprecated]
        Common_ISDN_Access,

        /**
         * SIM Access Profile (SAP)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier.
         *
          * Service Class / Profile
         */
        [DBus (value = "0000112D-0000-1000-8000-00805F9B34FB")]
        SIM_Access,

        /**
         * Phonebook Access Profile (PBAP)
         *
         * Service Class
         */
        [DBus (value = "0000112E-0000-1000-8000-00805F9B34FB")]
        PhonebookAccessPCE,

        /**
         * Phonebook Access Profile (PBAP)
         *
         * Service Class
         */
        [DBus (value = "0000112F-0000-1000-8000-00805F9B34FB")]
        PhonebookAccessPSE,

        /**
         * Phonebook Access Profile (PBAP)
         *
         * Profile
         */
        [DBus (value = "00001130-0000-1000-8000-00805F9B34FB")]
        PhonebookAccess,

        /**
         * Headset Profile (HSP)
         *
         * NOTE: See erratum #3507.
         * 0x1108 and 0x1203 should also be included in the ServiceClassIDList
         * before 0x1131 for backwards compatibility.
         *
         * Service Class
         */
        [DBus (value = "00001131-0000-1000-8000-00805F9B34FB")]
        Headset_HS,

        /**
         * Message Access Profile (MAP)
         *
         * Service Class
         */
        [DBus (value = "00001132-0000-1000-8000-00805F9B34FB")]
        MessageAccessServer,

        /**
         * Message Access Profile (MAP)
         *
         * Service Class
         */
        [DBus (value = "00001133-0000-1000-8000-00805F9B34FB")]
        MessageNotificationServer,

        /**
         * Message Access Profile (MAP)
         *
         * Profile
         */
        [DBus (value = "00001134-0000-1000-8000-00805F9B34FB")]
        MessageAccessProfile,

        /**
         * Global Navigation Satellite System Profile (GNSS)
         *
         * Profile
         */
        [DBus (value = "00001135-0000-1000-8000-00805F9B34FB")]
        GNSS,

        /**
         * Global Navigation Satellite System Profile (GNSS)
         *
         * Service Class
         */
        [DBus (value = "00001136-0000-1000-8000-00805F9B34FB")]
        GNSS_Server,

        /**
         * 3D Synchronization Profile (3DSP)
         * Service Class
         */
        [DBus (value = "00000137-0000-1000-8000-00805F9B34FB")]
        3D_Display,

        /**
         * 3D Synchronization Profile (3DSP)
         *
         * Service Class
         */
        [DBus (value = "00001138-0000-1000-8000-00805F9B34FB")]
        3D_Glasses,

        /**
         * 3D Synchronization Profile (3DSP)
         *
         * Profile
         */
        [DBus (value = "00000139-0000-1000-8000-00805F9B34FB")]
        3D_Synchronization,

        /**
         * Multi-Profile Specification (MPS)
         *
         * Profile
         */
        [DBus (value = "0000113A-0000-1000-8000-00805F9B34FB")]
        MPS_Profile,

        /**
         * Multi-Profile Specification (MPS)
         *
         * Service Class
         */
        [DBus (value = "0000113B-0000-1000-8000-00805F9B34FB")]
        MPS_SC,

        /**
         * Calendar, Task, and Notes (CTN) Profile
         *
         * Service Class
         */
        [DBus (value = "0000113C-0000-1000-8000-00805F9B34FB")]
        CTN_Access,

        /**
         * Calendar Tasks and Notes (CTN) Profile
         *
         * Service Class
         */
        [DBus (value = "0000113D-0000-1000-8000-00805F9B34FB")]
        CTN_Notification,

        /**
         * Calendar Tasks and Notes (CTN) Profile
         *
         * Profile
         */
        [DBus (value = "0000113E-0000-1000-8000-00805F9B34FB")]
        CTN_Profile,

        /**
         * Device Identification (DID)
         *
         * NOTE: Used as both Service Class Identifier and Profile Identifier.
         *
         * Service Class / Profile
         */
        [DBus (value = "00001200-0000-1000-8000-00805F9B34FB")]
        PnPInformation,

        /**
         * N/A
         *
         * Service Class
         */
        [DBus (value = "00001201-0000-1000-8000-00805F9B34FB")]
        GenericNetworking,

        /**
         * N/A
         *
         * Service Class
         */
        [DBus (value = "00001202-0000-1000-8000-00805F9B34FB")]
        GenericFileTransfer,

        /**
         * N/A
         *
         * Service Class
         */
        [DBus (value = "00001203-0000-1000-8000-00805F9B34FB")]
        GenericAudio,

        /**
         * N/A
         *
         * Service Class
         */
        [DBus (value = "00001204-0000-1000-8000-00805F9B34FB")]
        GenericTelephony,

        /**
         * Enhanced Service Discovery Profile (ESDP)
         *
         * Service Class
         */
        [DBus (value = "00001205-0000-1000-8000-00805F9B34FB")]
        [Deprecated]
        UPNP_Service,

        /**
         * Enhanced Service Discovery Profile (ESDP)
         *
         * Service Class
         */
        [DBus (value = "00001206-0000-1000-8000-00805F9B34FB")]
        [Deprecated]
        UPNP_IP_Service,

        /**
         * Enhanced Service Discovery Profile (ESDP)
         *
         * Service Class
         */
        [DBus (value = "00001300-0000-1000-8000-00805F9B34FB")]
        [Deprecated]
        ESDP_UPNP_IP_PAN,

        /**
         * Enhanced Service Discovery Profile (ESDP)
         *
         * Service Class
         */
        [DBus (value = "00001301-0000-1000-8000-00805F9B34FB")]
        [Deprecated]
        ESDP_UPNP_IP_LAP,

        /**
         * Enhanced Service Discovery Profile (ESDP)
         *
         * Service Class
         */
        [DBus (value = "00001302-0000-1000-8000-00805F9B34FB")]
        [Deprecated]
        ESDP_UPNP_L2CAP,

        /**
         * Video Distribution Profile (VDP)
         *
         * Service Class
         */
        [DBus (value = "00001303-0000-1000-8000-00805F9B34FB")]
        VideoSource,

        /**
         * Video Distribution Profile (VDP)
         *
         * Service Class
         */
        [DBus (value = "00001304-0000-1000-8000-00805F9B34FB")]
        VideoSink,

        /**
         * Video Distribution Profile (VDP)
         *
         * Profile
         */
        [DBus (value = "00001305-0000-1000-8000-00805F9B34FB")]
        VideoDistribution,

        /**
         * Health Device Profile
         *
         * Profile
         */
        [DBus (value = "00001400-0000-1000-8000-00805F9B34FB")]
        HDP,

        /**
         * Health Device Profile (HDP)
         *
         * Service Class
         */
        [DBus (value = "00001401-0000-1000-8000-00805F9B34FB")]
        HDP_Source,

        /**
         * Health Device Profile (HDP)
         *
         * Service Class
         */
        [DBus (value = "00001402-0000-1000-8000-00805F9B34FB")]
        HDP_Sink;

        /**
         * Gets the 3 to 6 (or more) character profile name for a given UUID.
         */
        public string to_short_profile () {
            switch (this) {
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
}