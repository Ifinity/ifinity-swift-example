# IfinitySDK for iOS

## Installation

The easiest way to install IfinitySDK is by using CocoaPods.

```
pod 'IfinitySDK'
```

If you want to install IfinitySDK manually, you need to follow these steps:

1. Add following frameworks to your project: 'MapKit', 'CoreLocation', 'CoreData', 'Security', 'CoreBluetooth', 'libz', 'sqlite3'
2. Drag `ifinitySDK.framework` to the Framework's group of your project. Make sure "Copy items into destination group's folder" is selected.
3. Right-click 'ifinitySDK.framework' in your project, and select Show In Finder.
4. Drag the ifinityDB.bundle and ifinityImages.bundle from the Resources folder to your project. We suggest putting it into the Frameworks group. Make sure "Copy items into destination group's folder" is not selected.
5. Set the value of the Other Linker Flags build setting to $(OTHER_LDFLAGS) -ObjC as described in  [Apple Technical Q&A QA1490](https://developer.apple.com/library/mac/qa/qa1490/_index.html)


# Quick Start

## Authentication

Authentication is a must have for using the IfinitySDK. Without it, SDK won’t work or it will keep throwing exceptions. Every next step in this tutorial requires authorization. Every launch of your app will need to begin with the process showed below.


```
// obtain those parameters at the geos.zone website
let GEOS_APP_ID = "..."
let GEOS_SECRET = "..."

func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    IFDataManager.sharedManager().setClientID(GEOS_APP_ID, secret:GEOS_SECRET);
    return true;
}

func authenticate() {
    IFDataManager.sharedManager().authenticateWithSuccess({credential in
        // Authentication successful 
        }, failure: {error in
            // Invalid authentication
    })
}
```


## Loading venue data

After authenticating with our API, you can load venues from geos.zone. You can do this by using single instance of `IFDataManager`, passing your current or needed location, radius and choose public or not public venue.

```
IFDataManager.sharedManager().loadDataForLocation(CLLocation(latitude: 52, longitude: 21), distance: 1000, withPublicVenues: true, successBlock: { (venues) -> Void in
        // ... 
    }) { (error) -> Void in
        // ...
}

```


## Accessing local database

After determining that your data was successfully loaded, you can easily access it from your local database storage. To achieve that you need to call the data access methods of the single `DataManager` instance.

```
// fetch all venues from database
IFDataManager.sharedManager().fetchVenuesFromCacheWithBlock { venues in ... }

// fetch floor for specific venue
IFDataManager.sharedManager().fetchFloorsFromCacheForVenueId(venueId, block: { floors in ... })

// fetch areas for specific floor
IFDataManager.sharedManager().fetchAreasFromCacheForFloorId(floorplanId, block: { areas in ... }];

// fetch areas for specific venue
IFDataManager.sharedManager().fetchAreasFromCacheForVenueId(venueId, block: { areas in ... }];

// get beacons for specific floor
floorplan.beacons.enumerate();

// get content for specific area
IFDataManager.sharedManager().fetchContentForAreaId(areaId, block: { content in ... }];

// get content for specific venue
IFDataManager.sharedManager().fetchContentForVenueId(venueId, block: { content in ... });

// fetch all push from database
IFPushManager.sharedManager().fetchAll()
```


## Entering the venue

For detection of venues in physical world you need to access the single instance of the `IFBluetoothManager` class. This class will provide you with the information about nearby beacons state, venues you’re in, and the floor you’re on.

## Detecting many-beacons venue floor

```
override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    IFBluetoothManager.sharedManager().startManager()
    IFBluetoothManager.sharedManager().delegate = self
}

override func viewWillDisappear(animated: Bool) {
    super.viewWillAppear(animated)
    IFBluetoothManager.sharedManager().stopManager()
    IFBluetoothManager.sharedManager().delegate = nil
}


//MARK: - IFBluetoothManagerDelegate

func manager(manager: IFBluetoothManager, didDiscoverActiveBeaconsForVenue venue: IFMVenue?, floorplan: IFMFloorplan) {
   self.indoorLocationManager.startCheckingAreasForFloorplan(floorplan)
}

func manager(manager: IFBluetoothManager, didLostAllBeaconsForVenue venue: IFMVenue) {
}

func manager(manager: IFBluetoothManager, didLostAllBeaconsForFloorplan floorplan: IFMFloorplan) {
}
```


## Detecting indoor location

IfinitySDK can provide you with a specific data about the user location inside a venue: his/her position and area he/she is inside. To obtain this information, you need to get a single instance of the `IndoorLocationManager` and register the listeners for the events you want to handle.
To use the `IFIndoorLocationManager`, the `IFBluetoothManager` must be started first.

```
override func viewDidLoad() {
    super.viewDidLoad()

    self.indoorLocationManager = IFIndoorLocationManager()
    self.indoorLocationManager.delegate = self
}

- (void)viewWillAppear:(BOOL)animated
{
    IFBluetoothManager.sharedManager().startManager()
    IFBluetoothManager.sharedManager().delegate = self
    self.indoorLocationManager.startUpdatingIndoorLocation()
    super.viewWillAppear(animated)
}

- (void)viewWillDisappear:(BOOL)animated
{
    super.viewWillDisappear(animated)
    IFBluetoothManager.sharedManager().stopManager();
    IFBluetoothManager.sharedManager().delegate = nil
    self.indoorLocationManager?.stopUpdatingIndoorLocation()
}

//MARK: - IFIndoorLocationManagerDelegate

func manager(manager: IFIndoorLocationManager, didUpdateIndoorLocation location: CLLocation) {
}

func manager(manager: IFIndoorLocationManager, didEnterArea area: IFMArea) {
}

func manager(manager: IFIndoorLocationManager, didExitArea area: IFMArea) {
}
```


## Push Manager

IfinitySDK allows usage of background push notification in your app easily. To do that, you need to add obeservers to NSNotificationCenter.

```
NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPush:", name: IFPushManagerNotificationPushAdd, object: nil)
NSNotificationCenter.defaultCenter().addObserver(self, selector: "deletePush:", name: IFPushManagerNotificationPushDelete, object: nil)
    
func addPush(sender: AnyObject) {
    let dict: [NSObject : AnyObject] = sender.userInfo
    let push: IFMPush = dict["push"] as! IFMPush
}

func deletePush(sender: AnyObject){
    let dict: [NSObject : AnyObject] = sender.userInfo
    let push: IFMPush = dict["push"] as! IFMPush
}
```


## Background notifications 

To make use of background notifications, you will need to enable background location updates in Xcode. You can do this by enabling Capabilities -> Background Modes -> Location updates on project settings tab. Then you need to create a new instance of `IFBackgroundGeosController` and pass him an instance of CLLocationManagera.

```
override func viewDidLoad() {
    super.viewDidLoad()
    self.locationManager = CLLocationManager()
    self.backgroundGeosController = IFBackgroundGeosController(locationManager: locationManager)
    self.backgroundGeosController.enableNotifications = true
    if CLLocationManager.authorizationStatus() == kCLAuthorizationStatusNotDetermined {
        locationManager.requestAlwaysAuthorization()
    }
    self.locationManager.delegate = backgroundGeosController
    locationManager.startUpdatingLocation()
}
```


If you want to handle background push notifications, you will need to add some additional observers to NSNotificationCenter.



```
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
{
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPush:", name: IFPushManagerNotificationPushAreaBackgroundAdd, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPush:", name: IFPushManagerNotificationPushVenueBackgroundAdd, object: nil)
    
    if launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] != nil {
        var localNotification: UILocalNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]
        IFPushManager.sharedManager().addReceiveLocalNotification(localNotification.userInfo)
    }
    return true;
}

func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    IFPushManager.sharedManager().addReceiveLocalNotification(notification.userInfo)
}

func addPush(sender: AnyObject) {
    let dict: [NSObject : AnyObject] = sender.userInfo
    let push: IFMPush = dict["push"] as! IFMPush
}
```



## Sample project

Project described above will be available shortly on our github account