// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

library CommonType {
    struct Geolocation {
        bytes2 regionCode;
        bytes2 countryCode;
        bytes2 cityCode;
    }

    struct StorageProvider {
        string nodeId;
        string organization;
    }
}
