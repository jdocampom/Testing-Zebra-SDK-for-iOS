/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  config.h
 *
 *  Notes:
 *
 ******************************************************************************/

#ifndef __CONFIG_H__
#define __CONFIG_H__


#define ZT_SCANNER_APP_NAME                        @"Zebra Scanner Control"
#define ZT_SCANNER_NOTIFICATION_IDENTITY           @"com.zebra.ZebraRfd8500Barcode"
#define ZT_SCANNER_DEVICE_NAME_PATTERN_RFD8500     @"RFD*"
#define ZT_SCANNER_DEVICE_NAME_PATTERN_CS4070      @"CS*"
#define ZT_INFO_SCANNER_APP_NAME                   @"Zebra Scanner Control"
#define ZT_INFO_SCANNER_SDK_NAME                   @"Zebra Scanner SDK"
#define ZT_INFO_COPYRIGHT_TEXT                     @" Zebra Technologies Corp. and/or its affiliates. All rights reserved."
#define ZT_INFO_COPYRIGHT_YEAR                     @"©2022"
#define ZT_UPDATE_FW_BTN_TITLE                     @"UPDATE FIRMWARE"
#define ZT_UPDATE_FW_BTN_TITLE_UPDATED             @"✓ FIRMWARE UPDATED"
#define ZT_UPDATE_FW_VIEW_TITLE_UPDATING           @"Updating Firmware"
#define ZT_UPDATE_FW_VIEW_TITLE_REBOOTING          @"Rebooting Scanner"
#define ZT_FW_FILE_DIRECTIORY_NAME                 @"Download"
#define ZT_FW_FILE_EXTENTION                       @"DAT"
#define ZT_PLUGIN_FILE_EXTENTION                   @"SCNPLG"
#define ZT_RELEASE_NOTES_FILE_EXTENTION            @"txt"
#define ZT_METADATA_FILE                           @"Metadata.xml"
#define ZT_MODEL_LIST_TAG                          @"models"
#define ZT_MODEL_TAG                               @"model"
#define ZT_REVISION_TAG                            @"revision"
#define ZT_RELEASED_DATE_TAG                       @"release-date"
#define ZT_FAMILY_TAG                              @"family"
#define ZT_NAME_TAG                                @"name"
#define ZT_FIRMWARE_NAME_TAG                       @"combined-firmware"
#define ZT_RELEASE_DATE_LBL_PREFIX                 @"To Release "
#define ZT_PICTURE_FILE_NAME                       @"picture"
#define FW_PAGE_CONTENT_ONE                        @"Firmware Update Process Help"
#define FW_PAGE_CONTENT_ONE_SECOND                 @"Copy the correct 123Scan plug-in for your scanner to your device"
#define FW_PAGE_CONTECT_THREE                      @"Load 123Scan onto a Windows computer from"
#define FW_PAGE_CONTECT_THREE_URL_REAL             @"https://www.zebra.com/ap/en/products/software/scanning-systems/scanner-drivers-and-utilities/123scan2-configuration-utility.html"
#define FW_PAGE_CONTECT_THREE_URL                  @"www.Zebra.com/123Scan"
#define FW_PAGE_CONTECT_FOUR                       @"From your Windows PC with 123Scan, access your scanner's plug-in(.scnplg file) from C:\\ProgramData\\123Scan\\Plug-ins"
#define FW_PAGE_CONTECT_FIVE                        @"Put a copy of the  plug-in into your device's download folder (Application > Download)"
#define FW_PAGE_CONTECT_SIX                        @"Start the firmware update by clicking the update firmware button."
#define FW_PAGE_PLUGIN_MISMATCH_CONTENT_ONE        @"Delete the incorrect plug-in from the application's download folder."
#define FW_PAGE_PLUGIN_MISMATCH_CONTENT_TWO        @"Copy the correct plug-in to the application's download folder."
#define FIRMWARE_UPDATE_STOPPED @"Firmware Update Stopped."
#define VIRTUAL_TETHER_NOTIFICATION_TITLE @"Zebra Virtual Tether alarm activated."
#define VIRTUAL_TETHER_NON_VIBRATE_SUPPORT_MESSAGE @"Disabled in hosts that lack of vibration capability"
#define OK @"OK"
#define FIRMWARE_UPDATE_CANCEL_CONFIRMATION @"Do you want to cancel this firmware update?"
#define YES_BUTTON @"Yes"
#define NO_BUTTON @"No"
#define CONNECTION_HELP_TITLE @"Help"
#define ZT_SCANNER_PAGE_CONNECT_MFI_SCANNERS_TITLE @"Connect MFI Scanners"
#define SCAN_TO_CONNECT_APP_NAME_TITLE             @"Zebra Scanner Control"
#define BLE_TAB_BAR_TITLE @"BT LE"
#define MFI_TAB_BAR_TITLE @"MFi"
#define HELP_TAB_BAR_TITLE @"Help"
#define SETTINGS_TAB_BAR_TITLE @"App Settings"
#define ABOUTUS_IMAGE @"aboutIcon"

#define BLE_TAB_BAR_IMAGE @"ble"
#define MFI_TAB_BAR_IMAGE @"mfi"
#define HELP_TAB_BAR_IMAGE @"help"
#define SETTINGS_TAB_BAR_IMAGE @"settings"

#define BLE_TAB_BAR_INDEX 0
#define MFI_TAB_BAR_INDEX 1

#define TAB_BAR_TAG_0 0
#define TAB_BAR_TAG_1 1
#define TAB_BAR_TAG_2 2
#define TAB_BAR_TAG_3 3


#define SCANNER_STORY_BOARD  @"ScannerDemoAppStoryboard"
#define ID_SCANNER_VIRTUAL_THETHER_VC  @"ID_SCANNER_VIRTUAL_THETHER_VC"
#define ID_BTLE_STC_VC_IPHONE @"ID_BTLE_STC_VC_IPHONE"
//#define ID_MFI_SCANNERS_TABLE_VC @"ID_MFI_SCANNERS_TABLE_VC"
//#define ID_APP_CONNECTION_HELP_VC @"ID_APP_CONNECTION_HELP_VC"
#define ID_APP_SETTINGS_VC @"ID_APP_SETTINGS_VC"
#define ID_ACTIVE_SCANNER_VC @"ID_ACTIVE_SCANNER_VC"
#define ID_SCANNER_FWUPDATE_DAT_VC @"ID_SCANNER_FWUPDATE_DAT_VC"
#define ID_APP_ABOUT_VC @"ID_APP_ABOUT_VC"
#define ID_SCANNER_BEEPER_ACTION_VC @"ID_SCANNER_BEEPER_ACTION_VC"
#define ID_SCANNER_LED_ACTION_VC @"ID_SCANNER_LED_ACTION_VC"
#define ID_SCANNER_SYMBOLOGIES_VC @"ID_SCANNER_SYMBOLOGIES_VC"
#define ID_SCANNER_BEEPER_VC @"ID_SCANNER_BEEPER_VC"
#define ID_BARCODE_EVENT_VC @"ID_BARCODE_EVENT_VC"
#define ID_CONFIGURATION_SINGLE_VC @"ID_CONFIGURATION_SINGLE_VC"
#define ID_ASSET_DETAILS_VC @"ID_ASSET_DETAILS_VC"
#define ID_APP_CONNECTION_INSTRUCTIONS_VC @"ID_APP_CONNECTION_INSTRUCTIONS_VC"
#define ID_APP_SETTINGS_BACKGROUND_VC @"ID_APP_SETTINGS_BACKGROUND_VC"

#define DISABLED_MODE_ALERT_TITLE @"Message"
#define DISABLED_BLE_MODE_ALERT_MESSAGE @"Currently, you only selected MFi mode. To access BT LE devices, change the communication mode to BT LE/MFi + BT LE on the \"App Settings\" page."
#define DISABLED_MFI_MODE_ALERT_MESSAGE @"Currently, you only selected BT LE mode. To access MFi devices, change the communication mode to MFi/MFi + BT LE on the \"App Settings\" page."
#define ACTIVE_SCANNER_TITLE @"Active Scanner"
#define ACTIVE_SCANNER_BACK_BUTTON_TITLE @"Back"
#define ACTIVE_SCANNER_DISCONNECT_ALERT_TITLE @"Disconnect?"
#define ACTIVE_SCANNER_DISCONNECT_ALERT_MESSAGE @"This will disconnect the application from the scanner, however the device will still be paired to the system."
#define ACTIVE_SCANNER_DISCONNECT_ALERT_CANCEL @"Cancel"
#define ACTIVE_SCANNER_DISCONNECT_ALERT_CONTINUE @"Continue"
#define ACTIVE_SCANNER_BARCODE_ALERT_TITLE @"Clear Barcode Data?"
#define ACTIVE_SCANNER_BARCODE_ALERT_MESSAGE @"Are you sure that you want to clear all barcode data? This information cannot be restored after it is cleared."
#define ACTIVE_SCANNER_BARCODE_ALERT_CANCEL @"Cancel"
#define ACTIVE_SCANNER_BARCODE_ALERT_CONTINUE @"Continue"
#define BEEPER_SETTINGS_CANNOT_RETRIEVE_ALERT_MESSAGE @"Cannot retrieve beeper settings"
#define BEEPER_SETTINGS_CANNOT_RETRIEVE_ALERT_OK_TITLE @"OK"
#define UPDATE_FIRMWARE_OPEN_URL_SUCCESS @"Success"
#define UPDATE_FIRMWARE_PERCENTAGE_LABEL_STRING_FORMAT @"%i%%"
#define SCANNER_APP_ENGINE_NOTIFICATION_ID_FORMAT @"%@%f"
#define SCANNER_DEMO_APP_DELEGATE_NOTIFICATION_STATUS @"Notification permission status:%d"
#define SCAN_TO_CONNECT_EMPTY_STRING_VALUE @"Keep Current Settings"
#define SCAN_TO_CONNECT_KEEP_CURRENT_SETTINGS @"Keep Current Settings"
#define SCAN_TO_CONNECT_SET_FACTORY_DEFAULT @"Set Factory Default"

// AlertView Messages
#define ZT_SCANNER_ERROR_MESSAGE @"Error"
#define ZT_SCANNER_CANNOT_RETRIEVE_ASSET_MESSAGE @"Cannot retrieve asset information from the device"
#define ZT_SCANNER_DISCONNECT_SCANNER_FROM_APPLICATION_MESSAGE @"This will disconnect the application from the scanner, however the device will still be paired to the system."
#define ZT_SCANNER_DISCONNECTING_MESSAGE @"Disconnecting..."
#define ZT_SCANNER_CANNOT_PERFORM_TRIGGER_PULL @"Cannot perform [Trigger Pull] action"
#define ZT_SCANNER_CANNOT_PERFORM_TRIGGER_RELEASE @"Cannot perform [Trigger Release] action"
#define ZT_SCANNER_CANNOT_PERFORM_SCANNER_MODE @"Cannot perform [Scanner Mode] action"
#define ZT_SCANNER_MODE_ACTION_NOT_SUPPORTED @"Scanner mode action is not supported"
#define ZT_SCANNER_CANNOT_PERFORM_SCAN_ENABLE @"Cannot perform [Scan Enable] action"
#define ZT_SCANNER_CANNOT_PERFORM_SCAN_DISABLE @"Cannot perform [Scan Disable] action"
#define ZT_SCANNER_CANNOT_PERFORM_AIM_ON @"Cannot perform [Aim On] action"
#define ZT_SCANNER_CANNOT_PERFORM_AIM_OFF @"Cannot perform [Aim Off] action"
#define ZT_SCANNER_CANNOT_PERFORM_VIBRATION_FEEDBACK @"Cannot perform [Vibration Feedback] action"
#define ZT_SCANNER_CANNOT_PERFORM_LED_ACTION @"Cannot perform LED action"
#define ZT_SCANNER_CANNOT_PERFORM_BEEPER_ACTION @"Cannot perform beeper action"
#define ZT_SCANNER_CANNOT_RETRIEVE_BEEPER_SETTINGS @"Cannot retrieve beeper settings"
#define ZT_SCANNER_CANNOT_APPLY_BEEPER_CONFIG @"Cannot apply beeper configuration"
#define ZT_SCANNER_BEEPER_SETTINGS_NOT_RETRIEVED @"Beeper settings have not been retrieved. Action will not be performed"
#define ZT_SCANNER_CANNOT_RETRIEVE_SUPPORT_SYMBOLOGYS @"Cannot retrieve supported symbologies"
#define ZT_SCANNER_CANNOT_RETRIEVE_SUPPORT_SYMBOLOGYS_TRY_AGAIN @"Cannot retrieve supported symbologies. Please try again"
#define ZT_SCANNER_SYMBOLOGY_CONFIG_FAILED @"Symbology configuration failed"
#define ZT_SCANNER_SUPPORT_SYMBOLOGYS_NOT_RETRIEVED @"Supported symbologies have not been retrieved. Action will not be performed"
#define ZT_SCANNER_CANNOT_RETRIEVE_ASSET_INFORMATION @"Cannot retrieve asset information from the device"
#define ZT_SCANNER_CANNOT_PERFORM_NEW_FIRMWARE_ACTION @"Cannot perform [Start new firmware] action"
#define ZT_SCANNER_FIRMWARE_UPDATE_ABBORT_FAILED @"Firmware update Abort Failed"
#define ZT_SCANNER_SURE_WANT_GO_BACK @"Are you sure that you want to go back?"

typedef enum {
    ZT_INFO_UPDATE_FROM_DAT                   = 0x00,
    ZT_INFO_UPDATE_FROM_PLUGIN                = 0x01,
} ZT_INFO_UPDATE_FW;

#define MOT_INDENT_DEFAULT              20.0
#define MOT_NAVIGATION_BAR_HEIGHT       44.0
#define MOT_DEFAULT_FONT                17.0
#define MOT_START_IMAGE_WIDTH           0.7
#define MOT_MIN_IMAGE_WIDTH             0.4
#define MOT_ASPECT_RATIO_HEIGHT         0.4
#define START_PROGRESS_RESET_VALUE      0.0
#define FIRMWARE_UPDATE_RESET_AMOUNT    0.0f

typedef enum {
    BG_COLOUR_BLUE                   = 0x00,
    BG_COLOUR_YELLOW                 = 0x01,
    BG_COLOUR_FONT_COLOUR            = 0x02,
    BG_COLOUR_DARK_GRAY              = 0x03,
    BG_COLOUR_MEDIUM_GRAY            = 0x04,
    BG_COLOUR_LIGHT_GRAY             = 0x05,
    BG_COLOUR_TBL_LOW_GRAY           = 0x06,
    BG_COLOUR_WHITE                  = 0x07,
    BG_COLOUR_INACTIVE_BACKGROUND    = 0x08,
    BG_COLOUR_INACTIVE_TEXT          = 0x09,
    BG_COLOUR_DEFAULT_BTN_CLR        = 0x10,
} ZT_BG_COLOURS;

#define VIRTUAL_TETHER_TABLE_DEFAULT_SECTION_VALUE  1
#define VIRTUAL_TETHER_TABLE_DEFAULT_ROW_VALUE  1
#define VIRTUAL_TETHER_TABLE_NO_OF_SECTION  2
#define VIRTUAL_TETHER_TABLE_SCANNER_SETTINGS_NO_OF_ROW  3
#define VIRTUAL_TETHER_TABLE_HOST_SETTINGS_NO_OF_ROW  6
#define VIRTUAL_TETHER_TABLE_ROW_0  0
#define VIRTUAL_TETHER_TABLE_ROW_1  1
#define VIRTUAL_TETHER_TABLE_ROW_2  2
#define VIRTUAL_TETHER_TABLE_ROW_3  3
#define VIRTUAL_TETHER_TABLE_ROW_4  4
#define VIRTUAL_TETHER_TABLE_ROW_5  5
#define VIRTUAL_TETHER_TABLE_ROW_6  6
#define VIRTUAL_TETHER_ALARM_REPEAT_INTERVAL 2.5
#define VIRTUAL_TETHER_ALARM_SOUND_ID 1005
#define VIRTUAL_TETHER_ALARM_SOUND_FILE @"urgent-simple-tone-loop"
#define VIRTUAL_TETHER_ALARM_SOUND_FILE_FORMAT @"wav"
#define VIRTUAL_TETHER_CHECK_LAST_VC 1

#define SETTINGS_TABLE_NO_OF_ROW  9
#define SETTINGS_TABLE_DEFAULT_NO_OF_ROW  0
#define SCANNER_CONTROL_DS8178  @"Pair DS8178"
#define VIRTUAL_TETHER_DEFAULT_ROW_HEIGHT 103
#define SCANNER_VIRTUAL_TETHER_ALARM_ROW_HEIGHT 53
#define SCANNER__VIRTUAL_TETHER_SETTINGS_ROW_HEIGHT 200
#define SCANNER__VIRTUAL_TETHER_PICKER_SETTINGS_ROW_HEIGHT 320
#define VIRTUAL_TETHER_DEFEAT_ALARM_ROW_HEIGHT 462
#define VIRTUAL_TETHER_ALARM_PICKER_ROW_HEIGHT 369
#define VIRTUAL_TETHER_AUDIO_ALARM_ROW_HEIGHT 200
#define VIRTUAL_TETHER_SECTION_HEADER_HEIGHT 50
#define HELP_ICON_IMAGE @"help"
#define VIRTUAL_TETHER_SELECT_BLUE_COLOR [UIColor colorWithRed:0.0/256.0 green:124.0/256.0 blue:196.0/256.0 alpha:1.0];
#define VIRTUAL_TETHER_SECTION_BACKGROUND_COLOR [UIColor colorWithRed:219.0/256.0 green:216.0/256.0 blue:214.0/256.0 alpha:1.0];


#define VIRTUAL_TETHER_ENABLE_CHECK_MARK @"✓"
#define VIRTUAL_TETHER_DISABLE_CHECK_MARK @""
#define VIRTUAL_TETHER_PICKER_START_TIME 1
#define VIRTUAL_TETHER_PICKER_START_TIME_AUDIO_TIME 5
#define VIRTUAL_TETHER_PICKER_END_TIME 99
#define VIRTUAL_TETHER_TIME_FORMAT @"%d"
#define PICKER_AUDIO_ALARM_DEFAULT_SELECT_ROW  25
#define PICKER_AUDIO_ALARM_DURATION_DEFAULT_SELECT_ROW  4
#define PICKER_AUDIO_ALARM_PAUSE_DURATION_DEFAULT_SELECT_ROW  29
#define PICKER_COMPONENT 0
#define NO_OF_COMPONENT_IN_PICKER 1
#define DEFAULT_NO_OF_ROWS_IN_PICKER 0
#define DEFAULT_TITLE_IN_PICKER @""


#define RMD_VIRTUAL_TETHER_DEFEAT_ALARM 2119 //Byte
#define RMD_VIRTUAL_TETHER_PAUSE_ALARM_DURATION 2120 //Byte
#define RMD_VIRTUAL_TETHER_AUDIO_ALARM 2246 //Byte
#define RMD_VIRTUAL_TETHER_LED 2247 //Flag
#define RMD_VIRTUAL_TETHER_ILLUMINATION 2248 //Flag
#define RMD_VIRTUAL_TETHER_HAPTICS 2249 //Flag
#define RMD_VIRTUAL_TETHER_ALARM_ENABLE 2053 //Byte
#define RMD_VIRTUAL_TETHER_DELAY_BEFORE_ALARM 2054 //Byte
#define RMD_VIRTUAL_TETHER_ALARM_DURATION 2055 //Byte
#define RMD_VIRTUAL_TITLE @"Virtual Tether"
#define MESSAGE_VIRTUAL_TETHER_NOT_SUPPORTED @"Virtual tether is not supported by this scanner model"
#define MESSAGE_CANNOT_SET_VIRTUAL_TETHER_SETTING @"Cannot set virtual tether setting"
#define MESSAGE_VIRTUAL_TETHER_SIMULATION_FAILED @"Execution of action command to simulate virtual tether failed"
#define MESSAGE_CANNOT_STORE_VIRTUAL_TETHER_SETTING @"Cannot store virtual tether setting"

#define RMD_ATTRIBUTE_TYPE_FLAG @"F"
#define RMD_ATTRIBUTE_TYPE_BYTE @"B"

#define RMD_ATTRIBUTE_VALUE_TRUE @"TRUE"
#define RMD_ATTRIBUTE_VALUE_FALSE @"FALSE"
#define RMD_ATTRIBUTE_VALUE_DONOT_DEFEAT @"0"
#define RMD_ATTRIBUTE_VALUE_PAUSE_ALARM @"1"
#define RMD_ATTRIBUTE_VALUE_STOP_ALARM @"2"
#define RMD_ATTRIBUTE_VALUE_DISABLE_AUDIO @"0"
#define RMD_ATTRIBUTE_VALUE_ENABLE_NIGHT_MODE @"1"
#define RMD_ATTRIBUTE_VALUE_ENABLE_SILENT_MODE @"2"
#define RMD_ATTRIBUTE_VALUE_ZERO @"0"
#define RMD_ATTRIBUTE_VALUE_ONE @"1"
#define RMD_ATTRIBUTE_VALUE_ENABLE_SIMULATION @"232"
#define RMD_ATTRIBUTE_VALUE_DISABLE_SIMULATION @"233"

#define XML_TAG_INARGS_START @"<inArgs>"
#define XML_TAG_INARGS_END @"</inArgs>"
#define XML_TAG_SCANNERID_START @"<scannerID>"
#define XML_TAG_SCANNERID_END @"</scannerID>"
#define XML_TAG_CMDARGS_START @"<cmdArgs>"
#define XML_TAG_CMDARGS_END @"</cmdArgs>"
#define XML_TAG_ARGXML_START @"<arg-xml>"
#define XML_TAG_ARGXML_END @"</arg-xml>"
#define XML_TAG_ATTRIBUTE_LIST_START @"<attrib_list>"
#define XML_TAG_ATTRIBUTE_LIST_END @"</attrib_list>"
#define XML_TAG_ATTRIBUTE_START @"<attribute>"
#define XML_TAG_ATTRIBUTE_END @"</attribute>"
#define XML_TAG_ID_START @"<id>"
#define XML_TAG_ID_END @"</id>"
#define XML_TAG_DATATYPE_START @"<datatype>"
#define XML_TAG_DATATYPE_END @"</datatype>"
#define XML_TAG_VALUE_START @"<value>"
#define XML_TAG_VALUE_END @"</value>"
#define XML_TAG_ARG_INT_START @"<arg-int>"
#define XML_TAG_ARG_INT_END @"</arg-int>"

#define SCROLL_REACT_TO_VISIBILE_X_ZERO 0
#define SCROLL_REACT_TO_VISIBILE_Y_ZERO 0
#define SCROLL_REACT_TO_VISIBILE_HEIGHT_ONE 1
#define SCROLL_REACT_TO_VISIBILE_WIDTH_ONE 1

static const int TIMEOUT_VIRTUAL_TETHER_SIMULATION  = 5; //seconds
static const int TIMEOUT_VIRTUAL_TETHER_SIMULATION_PAUSE  = 3; //seconds

#define APP_SETTINGS_TABLE_ROW_0  0
#define APP_SETTINGS_TABLE_ROW_1  1
#define APP_SETTINGS_TABLE_ROW_2  2
#define APP_SETTINGS_TABLE_ROW_3  3
#define APP_SETTINGS_TABLE_ROW_4  4
#define APP_SETTINGS_TABLE_ROW_5  5
#define APP_SETTINGS_TABLE_ROW_6  6

///iPad constraints
#define FW_PAGE_DEVICE_IMG_HEIGHT_IPAD 150.0
#define FW_PAGE_BUTTON_HEIGHT_IPAD 50.0
#define FW_PAGE_DETAIL_VIEW_HEIGHT_IPAD 250.0
#define VIRTUAL_TETHER_PAGE_BUTTON_HEIGHT_IPAD 50.0

#endif /* __CONFIG_H__ */
