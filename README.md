#  Gespodo FootScan 3D

The structure and the flow of this app is same as the Android application.

login------------ 
                         \
                           \  
                             --> scan QR code ---------------------------> take 3D scans -> Take a picture -> end of scan
                        /   \                                                                 / 
rememberMe /      \--> List of patient --> select patient-->/
                      \                                                                    /   
                        \--> Create patient -------------------------/ 


The app is divided in two story boards : 

### Main:
The main story board contain the full workflow from the subscription and login to the end of the scan.

### Podo on the move:
The Podo on the move story board contain the new screens that allow a podologue to make scans while being on the move.


# Localization

In order to localize the project in english for example, the developper can produce localized story board and change all the string that are included in it.
To collect of the Localized string you can use the command in the bash at the level of the localizable.string :

```genstrings -o base.lproj */*.swift```

# Production

To put the project in production, select Build only iOS device in the dropdown of devices. Then in the Product menu, click on Archive and follow the procedure.
Then you should go on the app.store.connect.com to continue the procedure and release the app to development.


# Update the Astrivis SDK

In the git repository, open the submodule repository and pull the new changes.

# Possible problem / Problem history
7 May 2020 : Some downloaded STL were 0kb size. It was a bug in Astrivis server. If it happens again, check the result of the API call but in any cases contact Astrivis

```
curl --location --request POST 'https://cloud.astrivis.com/gespodo/api/data' --header 'Content-Type: application/json' --header 'Content-Type: text/plain' --header 'Cookie: PHPSESSID=ll4rl73r9n4fhc386e1v2cutj1' --data-raw '{
"key": "xoadieHae5iF0ChieZoowaes2sho2ep3",
"hash": "b_q5tDPAu6EPTWzZmk-0gQ=="
}
````


