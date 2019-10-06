//
//  main.m
//  RazerBlade
//
//  Created by Kishor Prins on 2017-04-12.
//  Copyright © 2017 Kishor Prins. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "razerkbd_driver.h"
#include "razerchromacommon.h"

struct razer_report razer_send_payload(IOUSBDeviceInterface **dev, struct razer_report *request_report);
void apply_row(IOUSBDeviceInterface **usb_dev, int row_num, int total, const char *rgb);
void activate_effect(IOUSBDeviceInterface **usb_dev);
int getPercent(int step, int total);

int setKey(int step, char *rgb, int r, int g, int b) {
    rgb[step++] = r;
    rgb[step++] = g;
    rgb[step++] = b;
    return step;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        //NSLog(@"Hello, World!");
        
        CFMutableDictionaryRef matchingDict;
        io_iterator_t iter;
        kern_return_t kr;
        io_service_t usbDevice;
        
        /* set up a matching dictionary for the class */
        matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
        if (matchingDict == NULL) {
            return -1; // fail
        }
        
        /* Now we have a dictionary, get an iterator.*/
        kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iter);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        /* iterate */
        while ((usbDevice = IOIteratorNext(iter))) {
            kern_return_t kr;
            IOCFPlugInInterface **plugInInterface = NULL;
            SInt32 score;
            HRESULT result;
            IOUSBDeviceInterface **dev = NULL;
            
            UInt16 vendor;
            UInt16 product;
            UInt16 release;
            
            kr = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
            
            //Don’t need the device object after intermediate plug-in is created
            kr = IOObjectRelease(usbDevice);
            if ((kIOReturnSuccess != kr) || !plugInInterface) {
                printf("Unable to create a plug-in (%08x)\n", kr);
                continue;
                
            }
            
            //Now create the device interface
            result = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID650), (LPVOID *)&dev);
            
            //Don’t need the intermediate plug-in after device interface is created
            (*plugInInterface)->Release(plugInInterface);
            
            if (result || !dev) {
                printf("Couldn’t create a device interface (%08x)\n",
                       (int) result);
                continue;
                
            }
            
            //Check these values for confirmation
            kr = (*dev)->GetDeviceVendor(dev, &vendor);
            kr = (*dev)->GetDeviceProduct(dev, &product);
            kr = (*dev)->GetDeviceReleaseNumber(dev, &release);
            
            if (!is_blade_laptop(dev)) {
                
                (void) (*dev)->Release(dev);
                continue;
            }
            
            //Open the device to change its state
            kr = (*dev)->USBDeviceOpen(dev);
            if (kr != kIOReturnSuccess)  {
                printf("Unable to open device: %08x\n", kr);
                (void) (*dev)->Release(dev);
                continue;
                
            }
            
            activate_effect(dev);
            kr = (*dev)->USBDeviceClose(dev);
            
            // Change Light Mode
//            char rgb1[3];
//
//            rgb1[0] = 100;
//            rgb1[1] = 255;
//            rgb1[2] = 0;
            
//
//            struct razer_report report = get_razer_report(0x03, 0x0B, 0x46); // In theory should be able to leave data size at max as we have start/stop
//
//            report.arguments[0] = 0xFF; // Frame ID
//            report.arguments[1] = 3;
//            report.arguments[2] = 0;
//            report.arguments[3] = 2;
//
//            report.arguments[4] = 0xFF;
//            report.arguments[5] = 0x00;
//            report.arguments[6] = 0x00;
//
//            report.arguments[7] = 0xFF;
//            report.arguments[8] = 0x00;
//            report.arguments[9] = 0x00;
//
//            report.arguments[10] = 0xFF;
//            report.arguments[11] = 0x00;
//            report.arguments[12] = 0x00;
            
            
            int key = 0;
            int total = 15;
            int count = total * 3;
            unsigned char rgb[count];
            int i = 0;
            
            // top row
            i = 0;
            i = setKey(i, rgb, 0xFF, 0, 0);
            i = setKey(i, rgb, 0x22, 0, 0x55);
            i = setKey(i, rgb, 0x44, 0, 0x77);
            i = setKey(i, rgb, 0x66, 0, 0x99);
            i = setKey(i, rgb, 0xCC, 0, 0xCC);
            
            i = setKey(i, rgb, 0xFF, 0, 0xFF);
            i = setKey(i, rgb, 0xFF, 0, 0xFF);
            i = setKey(i, rgb, 0xFF, 0, 0xFF);
            i = setKey(i, rgb, 0xFF, 0, 0xFF);
            i = setKey(i, rgb, 0xFF, 0, 0xFF);
            i = setKey(i, rgb, 0xFF, 0, 0xFF);
            
            i = setKey(i, rgb, 0xFF, 0, 0xFF);
            i = setKey(i, rgb, 0xCC, 0, 0xCC);
            i = setKey(i, rgb, 0x66, 0, 0x99);
            i = setKey(i, rgb, 0x44, 0, 0x77);
            i = setKey(i, rgb, 0x22, 0, 0x55);
            

//            while (i <= count) {
//                rgb[i++] = 0xFF;
//                rgb[i++] = 0x00;
//                rgb[i++] = 0xFF;
//            }
            
            
            apply_row(dev, 0, total, rgb);
            kr = (*dev)->USBDeviceClose(dev);
            sleep(0.1);
//            sleep(0.1);
//            kr = (*dev)->Release(dev);
            
            i = 0;
            i = setKey(i, rgb, 0x00, 0, 0x22);
            i = setKey(i, rgb, 0x00, 0, 0x44);
            i = setKey(i, rgb, 0x00, 0, 0x66);
            i = setKey(i, rgb, 0x00, 0, 0x88);
            i = setKey(i, rgb, 0x00, 0, 0xAA);
            i = setKey(i, rgb, 0x00, 0, 0xCC);
            i = setKey(i, rgb, 0x00, 0, 0xFF);
            i = setKey(i, rgb, 0x00, 0, 0xFF);
            
            i = setKey(i, rgb, 0x00, 0, 0xFF);
            i = setKey(i, rgb, 0x00, 0, 0xFF);
            i = setKey(i, rgb, 0x00, 0, 0xCC);
            
            i = setKey(i, rgb, 0x00, 0, 0xAA);
            i = setKey(i, rgb, 0x00, 0, 0x88);
            i = setKey(i, rgb, 0x00, 0, 0x66);
            i = setKey(i, rgb, 0x00, 0, 0x44);
            i = setKey(i, rgb, 0x00, 0, 0x22);
            
//            i = 0;
//            while (i <= count) {
//                rgb[i++] = 0x00;
//                rgb[i++] = 0x00;
//                rgb[i++] = 0xFF;
//            }
            
            apply_row(dev, 1, total, rgb);
            kr = (*dev)->USBDeviceClose(dev);
            sleep(0.1);
//            kr = (*dev)->Release(dev);
            
//            i = 0;
//            while (i <= count) {
//                rgb[i++] = 0x00;
//                rgb[i++] = 0x66;
//                rgb[i++] = 0xFF;
//            }
            
            i = 0;
            i = setKey(i, rgb, 0x00, 0x11, 0xFF);
            i = setKey(i, rgb, 0x00, 0x22, 0xFF);
            i = setKey(i, rgb, 0x00, 0x33, 0xFF);
            i = setKey(i, rgb, 0x00, 0x44, 0xFF);
            i = setKey(i, rgb, 0x00, 0x55, 0xFF);
            i = setKey(i, rgb, 0x00, 0x66, 0xFF);
            i = setKey(i, rgb, 0x00, 0x77, 0xFF);
            i = setKey(i, rgb, 0x00, 0x88, 0xFF);
            
            i = setKey(i, rgb, 0x00, 0x88, 0xFF);
            i = setKey(i, rgb, 0x00, 0x77, 0xFF);
            i = setKey(i, rgb, 0x00, 0x66, 0xFF);
            i = setKey(i, rgb, 0x00, 0x55, 0xFF);
            i = setKey(i, rgb, 0x00, 0x44, 0xFF);
            i = setKey(i, rgb, 0x00, 0x33, 0xFF);
            i = setKey(i, rgb, 0x00, 0x22, 0xFF);
            i = setKey(i, rgb, 0x00, 0x11, 0xFF);
            
//            key = 3 * 3;
//            rgb[key++] = 0xFF;
//            rgb[key++] = 0x00;
//            rgb[key++] = 0x11;
            
            apply_row(dev, 2, total, rgb);
            kr = (*dev)->USBDeviceClose(dev);
            sleep(0.1);
//            kr = (*dev)->Release(dev);

            i = 0;
            i = setKey(i, rgb, 0x00, 0x44, 0xFF);
            i = setKey(i, rgb, 0x00, 0x66, 0xFF);
            i = setKey(i, rgb, 0x00, 0x88, 0xFF);
            i = setKey(i, rgb, 0x00, 0xAA, 0xFF);
            i = setKey(i, rgb, 0x00, 0xCC, 0xFF);
            i = setKey(i, rgb, 0x00, 0xFF, 0xFF);
            i = setKey(i, rgb, 0x00, 0xFF, 0xFF);
            i = setKey(i, rgb, 0x00, 0xFF, 0xFF);

            i = setKey(i, rgb, 0x00, 0xFF, 0xFF);
            i = setKey(i, rgb, 0x00, 0xFF, 0xFF);
            i = setKey(i, rgb, 0x00, 0xFF, 0xFF);
            i = setKey(i, rgb, 0x00, 0xCC, 0xFF);
            i = setKey(i, rgb, 0x00, 0xAA, 0xFF);
            i = setKey(i, rgb, 0x00, 0x88, 0xFF);
            i = setKey(i, rgb, 0x00, 0x66, 0xFF);
            i = setKey(i, rgb, 0x00, 0x44, 0xFF);
            
//            i = 0;
//            while (i <= count) {
//                rgb[i++] = 0x00;
//                rgb[i++] = 0xFF;
//                rgb[i++] = 0xFF;
//            }
            
//            key = 2 * 3;
//            rgb[key++] = 0xFF;
//            rgb[key++] = 0x00;
//            rgb[key++] = 0x11;
//
//            rgb[key++] = 0xFF;
//            rgb[key++] = 0x00;
//            rgb[key++] = 0x11;
//
//            rgb[key++] = 0xFF;
//            rgb[key++] = 0x00;
//            rgb[key++] = 0x11;
            
            apply_row(dev, 3, total, rgb);
            kr = (*dev)->USBDeviceClose(dev);
            sleep(0.1);
//            kr = (*dev)->Release(dev);
            
//            i = 0;
//            while (i <= count) {
//                rgb[i++] = 0x00;
//                rgb[i++] = 0xFF;
//                rgb[i++] = 0x66;
//            }
            
            
            i = 0;
            i = setKey(i, rgb, 0x00, 0x00, 0xFF);
            i = setKey(i, rgb, 0x00, 0x33, 0x33);
            i = setKey(i, rgb, 0x00, 0x66, 0x44);
            i = setKey(i, rgb, 0x00, 0x99, 0x55);
            i = setKey(i, rgb, 0x00, 0xCC, 0x66);
            i = setKey(i, rgb, 0x00, 0xFF, 0x77);
            i = setKey(i, rgb, 0x00, 0xFF, 0x88);
            i = setKey(i, rgb, 0x00, 0xFF, 0x88);
            
            i = setKey(i, rgb, 0x00, 0xFF, 0x88);
            i = setKey(i, rgb, 0x00, 0xFF, 0x88);
            i = setKey(i, rgb, 0x00, 0xFF, 0x77);
            i = setKey(i, rgb, 0x00, 0xFF, 0x66);
            i = setKey(i, rgb, 0x00, 0xCC, 0x55);
            i = setKey(i, rgb, 0x00, 0x99, 0x44);
            i = setKey(i, rgb, 0x00, 0x66, 0x33);
            i = setKey(i, rgb, 0x00, 0x33, 0x33);
            
            key = 13 * 3;
            rgb[key++] = 0xFF;
            rgb[key++] = 0x00;
            rgb[key++] = 0x11;
            
            
//            key = 1 * 3;
//            rgb[key++] = 0xff;
//            rgb[key++] = 0x33;
//            rgb[key++] = 0x00;
//
//            key = 15 * 3;
//            rgb[key++] = 0xff;
//            rgb[key++] = 0x33;
//            rgb[key++] = 0x00;
            
            apply_row(dev, 4, total, rgb);
            kr = (*dev)->USBDeviceClose(dev);
            sleep(0.1);
            
//            kr = (*dev)->Release(dev);
            
//            i = 0;
//            while (i <= count) {
//                rgb[i++] = 0x77;
//                rgb[i++] = 0xFF;
//                rgb[i++] = 0x22;
//            }
            
            i = 0;
            
            i = setKey(i, rgb, 0xFF, 0, 0);
            i = setKey(i, rgb, 0x33, 0x88, 0x66);
            i = setKey(i, rgb, 0x55, 0xBB, 0x44);
            i = setKey(i, rgb, 0x77, 0xFF, 0x22);
            i = setKey(i, rgb, 0x77, 0xFF, 0x22);
            i = setKey(i, rgb, 0x77, 0xFF, 0x22);
            i = setKey(i, rgb, 0x77, 0xFF, 0x22);
            i = setKey(i, rgb, 0x77, 0xFF, 0x22);
            
            i = setKey(i, rgb, 0x77, 0xFF, 0x22);
            i = setKey(i, rgb, 0x77, 0xFF, 0x22);
            i = setKey(i, rgb, 0x77, 0xFF, 0x22);
            i = setKey(i, rgb, 0x77, 0xFF, 0x22);
            i = setKey(i, rgb, 0x77, 0xFF, 0x22);
            i = setKey(i, rgb, 0x77, 0xFF, 0x22);
            i = setKey(i, rgb, 0x77, 0xFF, 0x22);
            i = setKey(i, rgb, 0x33, 0x66, 0x66);
            
            
            key = 3 * 3;
            rgb[key++] = 0xFF;
            rgb[key++] = 0x00;
            rgb[key++] = 0x11;
            
            key = 12 * 3;
            rgb[key++] = 0xFF;
            rgb[key++] = 0x00;
            rgb[key++] = 0x11;
            rgb[key++] = 0xFF;
            rgb[key++] = 0x00;
            rgb[key++] = 0x11;
            rgb[key++] = 0xFF;
            rgb[key++] = 0x00;
            rgb[key++] = 0x11;
            
            
            apply_row(dev, 5, total, rgb);
            kr = (*dev)->USBDeviceClose(dev);
            sleep(0.1);
            
            
            int pulseCount = 3;
            char pulse[pulseCount];
            
            pulse[0] = 2;
            pulse[1] = 2;
            
            razer_attr_write_mode_pulsate(dev, pulse, pulseCount);
//            kr = (*dev)->Release(dev);
            
//            rgb[i++] = 0x00;
            
//            struct razer_report report = get_razer_report(0x03, 0x0A, 0x02);
//            report.arguments[0] = 0x05; // Effect ID
////
////            //            report.arguments[1] = variable_storage; // Data frame ID
//            report.arguments[1] = 0x01; // Data frame ID
//            report.arguments[2] = 1;
//            report.arguments[3] = 0;
//            report.arguments[4] = total;
//            memcpy(&report.arguments[5], rgb, (total) * 3);
            
//            report.arguments[1] = 0x02;
//            report.arguments[2] = 0x00;
//            report.arguments[3] = 0x15;
//            memcpy(&report.arguments[4], rgb, (total + 1) * 3);
            
//            razer_attr_write_matrix_custom_frame(dev, rgb);
//            struct razer_report report = razer_chroma_standard_matrix_set_custom_frame(0, 0, total, rgb);
//
//            razer_send_payload(dev, &report);
            

            
            //Close this device and release object
//            kr = (*dev)->USBDeviceClose(dev);
//            kr = (*dev)->Release(dev);
        }
        
        /* Done, release the iterator */
        IOObjectRelease(iter);
        return 0;
    }
    
    return 0;
}


// perform the initial setup
void activate_effect(IOUSBDeviceInterface **usb_dev) {
    int total = 15;
    unsigned char rgb[total * 3];
    
    int i = 0;
    
    while (i <= (total * 3)) {
        rgb[i++] = 0x00;
        rgb[i++] = 0xFF;
        rgb[i++] = 0x00;
    }
    
    struct razer_report report = get_razer_report(0x03, 0x0A, 0x02);
    report.arguments[0] = 0x05; // Effect ID
    report.arguments[1] = 0x01; // Data frame ID
    report.arguments[2] = 1;
    report.arguments[3] = 0;
    report.arguments[4] = total;
    memcpy(&report.arguments[5], rgb, (total) * 3);
    
    razer_send_payload(usb_dev, &report);
}

// apply row styling
void apply_row(IOUSBDeviceInterface **usb_dev, int row_num, int total, const char *rgb) {
    struct razer_report report = razer_chroma_standard_matrix_set_custom_frame(row_num, 0, total, rgb);
    razer_send_payload(usb_dev, &report);
}
