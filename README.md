# TRT Order Manager

This repository contains the cross platform code of trt order manager for wordpress woocommerce apis'

## running on cp

flutter run -d chrome --dart-define=BASE_URL=https://cp.trttechnologies.net --dart-define=VERSION=wc/v3 --dart-define=CONSUMER_KEY=ck_70df5cda3fdde3c2483c2744d06cbc187e5c715e --dart-define=CONSUMER_SECRET=cs_7a1d987a63684bf3c326f2013c4f39ae5d611db9

flutter run -d linux --dart-define=BASE_URL=https://cp.trttechnologies.net --dart-define=VERSION=wc/v3 --dart-define=CONSUMER_KEY=ck_70df5cda3fdde3c2483c2744d06cbc187e5c715e --dart-define=CONSUMER_SECRET=cs_7a1d987a63684bf3c326f2013c4f39ae5d611db9

flutter build linux --dart-define=BASE_URL=https://cp.trttechnologies.net --dart-define=VERSION=wc/v3 --dart-define=CONSUMER_KEY=ck_70df5cda3fdde3c2483c2744d06cbc187e5c715e --dart-define=CONSUMER_SECRET=cs_7a1d987a63684bf3c326f2013c4f39ae5d611db9

## audioplayer cmake issue

sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev

## linux on system tray requires

```sh
sudo apt-get install appindicator3-0.1 libappindicator3-dev
```

## Deployment List

-   Ensure timezone format of `<country>/<city>`, i.e. `America/Regina`
-   Install the TRT Order Manager Api plugin
-   Enable online orders from plugin in `Woocommerce -> TRT Config`
-   Check Address at `Woocommerce -> Settings -> General`
