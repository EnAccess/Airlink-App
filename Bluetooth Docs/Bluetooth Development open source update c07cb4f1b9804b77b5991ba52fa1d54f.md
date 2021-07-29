# Bluetooth Development open source update

## Range testing with BL652 (nRF51822)

We did some range testing with our BLE chip mainly to figure out the

1. Realistic maximum line of sight distance
2. Role of concrete walls on range

We used a Samsung Android phone and the BL652 development kit for this study. Here are the findings in pictures.

![Bluetooth%20Development%20open%20source%20update%20c07cb4f1b9804b77b5991ba52fa1d54f/768DFA45-AB63-408E-B84A-8A7F18BEFE90.jpeg](Bluetooth%20Development%20open%20source%20update%20c07cb4f1b9804b77b5991ba52fa1d54f/768DFA45-AB63-408E-B84A-8A7F18BEFE90.jpeg)

Effect of object shadows

![Bluetooth%20Development%20open%20source%20update%20c07cb4f1b9804b77b5991ba52fa1d54f/0CAA08AD-79CD-42BD-ADC3-AA65A3272E82.jpeg](Bluetooth%20Development%20open%20source%20update%20c07cb4f1b9804b77b5991ba52fa1d54f/0CAA08AD-79CD-42BD-ADC3-AA65A3272E82.jpeg)

Effect of Walled spaces

![Bluetooth%20Development%20open%20source%20update%20c07cb4f1b9804b77b5991ba52fa1d54f/20210614_085821_mfnr.jpg](Bluetooth%20Development%20open%20source%20update%20c07cb4f1b9804b77b5991ba52fa1d54f/20210614_085821_mfnr.jpg)

Effect of line of sight distance

## App Architecture snapshot

***Xamarin was found as best app-dev platform for device functions support and community***

![Bluetooth%20Development%20open%20source%20update%20c07cb4f1b9804b77b5991ba52fa1d54f/Screen_Shot_2021-06-29_at_12.53.31_PM.png](Bluetooth%20Development%20open%20source%20update%20c07cb4f1b9804b77b5991ba52fa1d54f/Screen_Shot_2021-06-29_at_12.53.31_PM.png)

![Bluetooth%20Development%20open%20source%20update%20c07cb4f1b9804b77b5991ba52fa1d54f/Untitled.png](Bluetooth%20Development%20open%20source%20update%20c07cb4f1b9804b77b5991ba52fa1d54f/Untitled.png)

The first library that we initially used to connect to BluetoothLE was "Quick.Xamarin.BLE" which is not able to get Advertised data directly. But with the combination of the above three libraries it is possible to get the advertised data.