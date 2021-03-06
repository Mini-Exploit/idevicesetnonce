//
//  usb.m
//  idevicesetnonce
//
//  Created by MiniExploit on 5/31/22.
//

#include "usb.hpp"

int usb::open_connection() {
    for(int i = 1; i <= 20; i++) {
        debug("attempting to connect %d/20", i);
        irecv_error_t err = irecv_open_with_ecid(&client, 0);
        if (err == IRECV_E_SUCCESS) {
            debug("connected %d/20", i);
            irecv_devices_get_device_by_client(client, &device);
            _productType = device -> product_type;
            _boardConfig = device -> hardware_model;
            _chipID = device -> chip_id;
            return 0;
        }
        usleep(500000);
    }
    return -1;
}

void usb::close_connection() {
    irecv_close(client);
    client = NULL;
    device = NULL;
}

int usb::send_buffer(char *buffer, size_t len) {
    if(!client) {
        close_connection();
        if(open_connection() != 0) {
            return -1;
        }
    }
    return (irecv_send_buffer(client, (unsigned char*)buffer, (unsigned int)len, 1) == IRECV_E_SUCCESS) ? 0 : -1;
}

int usb::send_cmd(std::string cmd) {
    if(!client) {
        close_connection();
        if(open_connection() != 0) {
            return -1;
        }
    }
    return (irecv_send_command(client, cmd.c_str()) == IRECV_E_SUCCESS) ? 0 : -1;
}

char* usb::get_mode() {
    int __block mode;
    if(irecv_get_mode(client, &mode) != IRECV_E_SUCCESS) return NULL;
    switch (mode) {
        case IRECV_K_DFU_MODE:
            return "DFU";
        case IRECV_K_RECOVERY_MODE_1:
        case IRECV_K_RECOVERY_MODE_2:
        case IRECV_K_RECOVERY_MODE_3:
        case IRECV_K_RECOVERY_MODE_4:
            return "Recovery";
        case IRECV_K_WTF_MODE:
            return "WTF";
    }
    return NULL;
}
