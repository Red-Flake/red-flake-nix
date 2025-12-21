{ config
, lib
, pkgs
, ...
}:
{
  home.file.".config/kwinoutputconfig.json".text = ''
    [
        {
            "data": [
                {
                    "allowDdcCi": true,
                    "allowSdrSoftwareBrightness": true,
                    "autoRotation": "InTabletMode",
                    "brightness": 1,
                    "colorPowerTradeoff": "PreferEfficiency",
                    "colorProfileSource": "sRGB",
                    "connectorName": "DP-3",
                    "detectedDdcCi": false,
                    "edidHash": "20bc9a167c7a12c3206549a635f32eae",
                    "edidIdentifier": "GSM 30566 4591 4 2022 0",
                    "edrPolicy": "always",
                    "highDynamicRange": false,
                    "iccProfilePath": "",
                    "maxBitsPerColor": 0,
                    "mode": {
                        "height": 1440,
                        "refreshRate": 164956,
                        "width": 2560
                    },
                    "overscan": 0,
                    "rgbRange": "Automatic",
                    "scale": 1,
                    "sdrBrightness": 351,
                    "sdrGamutWideness": 0,
                    "transform": "Normal",
                    "uuid": "8b9bfbae-6187-4209-9206-679098d18720",
                    "vrrPolicy": "Never",
                    "wideColorGamut": false
                },
                {
                    "allowDdcCi": true,
                    "allowSdrSoftwareBrightness": true,
                    "autoRotation": "InTabletMode",
                    "brightness": 1,
                    "colorPowerTradeoff": "PreferEfficiency",
                    "colorProfileSource": "sRGB",
                    "connectorName": "HDMI-A-1",
                    "detectedDdcCi": false,
                    "edidHash": "4d3bd9c633a9c1c5c2808470cb90d00d",
                    "edidIdentifier": "AOC 9217 325232 43 2019 0",
                    "edrPolicy": "always",
                    "highDynamicRange": false,
                    "iccProfilePath": "",
                    "maxBitsPerColor": 0,
                    "mode": {
                        "height": 1080,
                        "refreshRate": 144001,
                        "width": 1920
                    },
                    "overscan": 0,
                    "rgbRange": "Automatic",
                    "scale": 1,
                    "sdrBrightness": 200,
                    "sdrGamutWideness": 0,
                    "transform": "Normal",
                    "uuid": "0bdbad0e-e33e-4724-8dfa-7c9def2566b0",
                    "vrrPolicy": "Never",
                    "wideColorGamut": false
                }
            ],
            "name": "outputs"
        },
        {
            "data": [
                {
                    "lidClosed": false,
                    "outputs": [
                        {
                            "enabled": true,
                            "outputIndex": 0,
                            "position": {
                                "x": 1920,
                                "y": 0
                            },
                            "priority": 0,
                            "replicationSource": ""
                        },
                        {
                            "enabled": true,
                            "outputIndex": 1,
                            "position": {
                                "x": 0,
                                "y": 75
                            },
                            "priority": 1,
                            "replicationSource": ""
                        }
                    ]
                },
                {
                    "lidClosed": false,
                    "outputs": [
                        {
                            "enabled": true,
                            "outputIndex": 1,
                            "position": {
                                "x": 0,
                                "y": 0
                            },
                            "priority": 0,
                            "replicationSource": ""
                        }
                    ]
                }
            ],
            "name": "setups"
        }
    ]
  '';
}
