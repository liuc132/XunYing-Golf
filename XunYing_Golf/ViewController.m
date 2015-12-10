//
//  ViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/8/27.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "XunYingPre.h"


#define CLIENT_ID   @"gKbc4lH2K27McsAe"


typedef struct GPSInf{
    double latitude;
    double longtitude;
    double altitude;
}GPSPoint;

GPSPoint currentGPS;

@interface ViewController ()<AGSQueryTaskDelegate,AGSLayerDelegate,AGSCalloutDelegate>


- (IBAction)switchMapFunction:(UISegmentedControl *)sender;
@property (strong, nonatomic) IBOutlet UIView *chooseHoleView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *switchMapFunView;





@property(strong, nonatomic) AGSGDBFeatureTable     *localFeatureTable;
@property(strong, nonatomic) AGSFeatureTableLayer   *localFeatureTableLayer;
@property(strong, nonatomic) AGSGDBFeatureTable     *localHoleFeatureTable;
@property(strong, nonatomic) AGSFeatureTableLayer   *localHoleFeatureTableLayer;
@property(strong, nonatomic) AGSGraphicsLayer       *graphicLayer;
@property(strong, nonatomic) AGSSymbol              *gpsSymbol;
@property(strong, nonatomic) AGSMapViewBase         *mapViewBase;

@property(strong, nonatomic) AGSMutablePolyline     *route;

//location
//@property(strong, nonatomic) CLLocationManager *locationManager;

@property(strong, nonatomic) AGSLocator *locator;

//heartBeat
@property(strong, nonatomic) NSTimer *heartBeat;

@property (strong, nonatomic) AGSQuery *query;
@property (strong, nonatomic) AGSQueryTask *queryTask;
@property (strong, nonatomic) AGSLocationDisplay *locationDis;

@property (strong, nonatomic) AGSGeometryEngine *geometryEngineLocal;
@property (strong, nonatomic) AGSPoint          *startPoint;


- (IBAction)whichButton:(UIButton *)sender;



@end

@implementation ViewController
FixedPoint gpsScreenPoint;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"enter ViewController");
    
    NSError *error;
    [AGSRuntimeEnvironment setClientID:CLIENT_ID error:&error];
    if(error){
        NSLog(@"Error using client ID:%@",[error localizedDescription]);
    }
    //enable standard level functionality in your app using your license code 这句话是将eris的logo给去掉
    AGSLicenseResult result = [[AGSRuntimeEnvironment license] setLicenseCode:@"runtimestandard,101,rux00000,none,gKbc4lH2K27McsAe"];
    NSLog(@"%ld",(long)result);
    
    
    //add tiled layer  step1
    NSString *path = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapData.bundle/xunying.tpk"];
    AGSLocalTiledLayer *layer = [AGSLocalTiledLayer localTiledLayerWithPath:path];
    //如果层被合适的初始化了之后，添加到地图
    if(layer != nil && !layer.error)
    {
        [self.mapView addMapLayer:layer withName:@"Local Tiled Layer"];
    }
    else
    {
        [[[UIAlertView alloc]initWithTitle:@"could not load tile package" message:[layer.error localizedDescription] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil]show];
        
    }
    
//    NSURL *mapUrl = [NSURL URLWithString:@"http://services.arcgisonline.com/ArcGIS/rest/services/World_Shaded_Relief/MapServer"];
//    AGSTiledMapServiceLayer *tiledLyr = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:mapUrl];
//    [self.mapView addMapLayer:tiledLyr withName:@"Tiled Layer"];
//    
//    //Zooming to an initial envelope with the specified spatial reference of the map.
//    AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:102100];
//    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:-13639984
//                                                ymin:4537387
//                                                xmax:-13606734
//                                                ymax:4558866
//                                    spatialReference:sr];
//    [self.mapView zoomToEnvelope:env animated:YES];
    
//    Zooming to an initial envelope with the specified spatial reference of the map.
    AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:3857];
    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:11830220.9410906
                                                ymin:3439691.60124628
                                                xmax:11832488.6845279
                                                ymax:3438114.33915628
                                    spatialReference:sr];
    
    
    [self.mapView zoomToEnvelope:env animated:YES];
    //xunying_hole.geodatabase
    NSError *hole_error;
    NSString *holePath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapData.bundle/xunying_hole.geodatabase"];
    AGSGDBGeodatabase *gdbXunyinHole = [AGSGDBGeodatabase geodatabaseWithPath:holePath error:&hole_error];
    if(hole_error){
        NSLog(@"fail to open xunying_hole.geodatabase");
    }
    else{
        self.localHoleFeatureTable = [[gdbXunyinHole featureTables] objectAtIndex:0];
        self.localHoleFeatureTableLayer = [[AGSFeatureTableLayer alloc] initWithFeatureTable:self.localHoleFeatureTable];
        self.localHoleFeatureTableLayer.delegate = self;
        [self.mapView addMapLayer:self.localHoleFeatureTableLayer withName:@"Hole Feature Layer"];
    }
    //xunying.geodatabase
    NSError *xunyingError;
    NSString *xunyingPath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapData.bundle/xunying.geodatabase"];
    AGSGDBGeodatabase *gdb_xunying = [[AGSGDBGeodatabase alloc]initWithPath:xunyingPath error:&xunyingError];
    //
    if(xunyingError)
    {
        NSLog(@"open xunying.geodatabase error:%@",[xunyingError localizedDescription]);
    }
    else{
        //NSLog(@"open the geodatabase successfully");
        self.localFeatureTable = [[gdb_xunying featureTables] objectAtIndex:0];
        self.localFeatureTableLayer = [[AGSFeatureTableLayer alloc]initWithFeatureTable:self.localFeatureTable];
        self.localFeatureTableLayer.delegate = self;
        self.localFeatureTableLayer.opacity = 1;
        
        [self.mapView addMapLayer:self.localFeatureTableLayer withName:@"Xunying Fearue Layer"];
    }
    //add graphicLayer
    self.graphicLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.graphicLayer withName:@"graphic Layer"];
    
    self.queryTask = [[AGSQueryTask alloc] init];
    self.queryTask.delegate = self;
//    self.query = [AGSQuery query];
//    self.query.whereClause = @"QCM = '7'";//and leixing Not In ('发球台','果岭环')";//[NSString stringWithFormat:@"QCM = '2' and leixing Not In ('发球台','果岭环') and OBJECTID <>  id"];
    
//    __weak ViewController *weakSelf = self;
    //每个球洞中的要素（沙坑，果岭，球道，发球台）查询
//    [self.localFeatureTable queryResultsWithParameters:self.query completion:^(NSArray *results,NSError *error){
//        NSLog(@"results:%@; error:%@",results,error);
//    }];
//    //
//    [self.localFeatureTable queryFeatureWithObjectID:95 completion:^(AGSGDBFeature *feature, NSError *error){
//        NSDictionary *featureAttr = [feature allAttributes];
//        NSLog(@"featureAttr:%@",featureAttr);
//        //
//        AGSSimpleFillSymbol *fillSymbol = [[AGSSimpleFillSymbol alloc] initWithColor:[[UIColor purpleColor] colorWithAlphaComponent:0.25] outlineColor:[UIColor blackColor]];
//        AGSGraphic *leixingGraphic = [[AGSGraphic alloc] initWithGeometry:featureAttr[@"Shape"] symbol:fillSymbol attributes:nil];
//        //
//        [weakSelf.graphicLayer addGraphic:leixingGraphic];
//        
//    }];
    
    //球洞查询
//    [self.localHoleFeatureTable queryResultsWithParameters:self.query completion:^(NSArray *results, NSError *error){
//        NSLog(@"resultes:%@",results);
//        AGSGDBFeature *resultFeature = results[0];
//        NSLog(@"feature:%@",[resultFeature allAttributes]);
//        
//    }];
//    
//    [self.localHoleFeatureTable queryFeatureWithObjectID:18 completion:^(AGSGDBFeature *feature, NSError *error){
//        NSLog(@"feature:%@",feature);
//        NSDictionary *featureDic = [feature allAttributes];
//        NSLog(@"featureDic:%@",featureDic);
//        //
//        AGSSimpleFillSymbol *fillSymbol = [[AGSSimpleFillSymbol alloc] initWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.15] outlineColor:[UIColor blackColor]];
//        AGSGraphic *holeGraphic = [[AGSGraphic alloc] initWithGeometry:featureDic[@"Shape"] symbol:fillSymbol attributes:nil];
//        [weakSelf.graphicLayer addGraphic:holeGraphic];
//        
//        
//    }];
    
    
    self.confirmGetGPS = YES;
    //
    self.mapView.touchDelegate = self;
    //
    
    //地图中的当前GPS定位点的位置信息点的显示
    [self.mapView.locationDisplay addObserver:self forKeyPath:@"autoPanMode" options:(NSKeyValueObservingOptionNew) context:NULL];
    //
//    if(!self.mapView.locationDisplay.dataSourceStarted)
//        [self.mapView.locationDisplay startDataSource];
    
    //Listen to KVO notifications for map scale property
    [self.mapView addObserver:self
                   forKeyPath:@"location"
                      options:(NSKeyValueObservingOptionNew)
                      context:NULL];
    //显示的GPS位置的图形风格设置
    self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
    self.mapView.locationDisplay.wanderExtentFactor = 0.75;
    //callout的代理设置
    self.mapView.callout.delegate = self;
    
    
    //
    self.geometryEngineLocal = [[AGSGeometryEngine alloc] init];
    
    
}
//

//
-(BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint
{
    NSDictionary *featureAttr = [feature allAttributes];
    //先判断，是否是点击到了球洞中的相应要素
    if(featureAttr[@"leixing"])
    {
        AGSSimpleFillSymbol *fillSymbol = [[AGSSimpleFillSymbol alloc] initWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.15] outlineColor:[UIColor blackColor]];
        AGSGraphic *leixingGraphic = [[AGSGraphic alloc] initWithGeometry:featureAttr[@"Shape"] symbol:fillSymbol attributes:nil];
        [self.graphicLayer addGraphic:leixingGraphic];
        
        //clear the custom view
        self.mapView.callout.customView = nil;
        //give related data
        self.mapView.callout.title = [NSString stringWithFormat:@"%@%@%@",featureAttr[@"QCM"],@"号",featureAttr[@"leixing"]];
        
        self.mapView.callout.accessoryButtonHidden = YES;
        
        return YES;
    }
    return NO;
}
//
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
    if(self.mapView.locationDisplay.autoPanMode == AGSLocationDisplayAutoPanModeOff || self.mapView.locationDisplay.autoPanMode == AGSLocationDisplayAutoPanModeDefault){
        [self.mapView setRotationAngle:0 animated:YES];
    }
    //
    if([keyPath isEqual:@"location"]){
        NSLog(@"curLocation:%@",[self.mapView.locationDisplay mapLocation]);
    }
    //
    if([keyPath isEqual:@"mapScale"]){
        if(self.mapView.mapScale < 5000) {
            [self.mapView zoomToScale:50000 withCenterPoint:nil animated:YES];
            [self.mapView removeObserver:self forKeyPath:@"mapScale"];
        }
    }
}
//
//-(void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
//{
//    [self.localFeatureTableLayer clearSelection];
//    if(features)
//    {
//        for (AGSGDBFeature *feature in [features valueForKey:@"Xunying Fearue Layer"]) {
//            [self.localFeatureTableLayer setSelected:YES forFeature:feature];
//            NSLog(@"feature:%@",feature);
//            //
//            AGSProximityResult *myResults = [[AGSProximityResult alloc] init];
//            
//            myResults = [self.geometryEngineLocal nearestCoordinateInGeometry:[feature geometry] toPoint:mappoint];
//            NSLog(@"geometryEngineLocal:%@ and distance:%f",myResults,myResults.distance);
//        }
//    }
//    //
//    [self.localHoleFeatureTableLayer clearSelection];
//    if(features)
//    {
//        for (AGSGDBFeature *feature1 in [features valueForKey:@"Hole Feature Layer"]) {
//            [self.localHoleFeatureTableLayer setSelected:YES forFeature:feature1];
//            NSLog(@"feature1:%@",feature1);
//            NSDictionary *featureAttr = [[NSDictionary alloc] init];
//            featureAttr = [feature1 allAttributes];
//            //
//            
//            __weak ViewController *weakSelf = self;
//            
//            
//            NSLog(@"featureAttr:%@",featureAttr);
//            NSString *searchStr = [NSString stringWithFormat:@"QCM = '%@' and leixing Not In('发球台','果岭环') and OBJECTID <> '%@'",featureAttr[@"QCM"],featureAttr[@"OBJECTID"]];
//            self.query.whereClause = searchStr;
//            [self.localFeatureTable queryResultsWithParameters:self.query completion:^(NSArray *results, NSError *error){
//                AGSGDBFeature *resultFeature = results[0];
//                NSDictionary *resultFeatureAttr = [resultFeature allAttributes];
//                NSLog(@"geometry:%@",[resultFeature geometry]);
//                AGSProximityResult *myResults = [[AGSProximityResult alloc] init];
//                AGSPoint *testPoint = [[AGSPoint alloc] initWithX:106.28256131500 y:29.49389984490 spatialReference:[AGSSpatialReference wgs84SpatialReference]];
//                AGSGeometry *pointGeometry = [[AGSGeometry alloc] init];
//                pointGeometry = [weakSelf.geometryEngineLocal projectGeometry:testPoint toSpatialReference:weakSelf.mapView.spatialReference];
//                
//                double distanceValue;
//                distanceValue = [weakSelf.geometryEngineLocal distanceFromGeometry:pointGeometry toGeometry:[resultFeature geometry]];
//                NSLog(@"distanceValue:%.10f",distanceValue);
//                
//                myResults = [weakSelf.geometryEngineLocal nearestCoordinateInGeometry:[resultFeature geometry] toPoint:testPoint];
//                NSLog(@"geometryEngineLocal:%@ and distance:%f and featureAttr:%@",myResults,myResults.distance,resultFeatureAttr);
//                
//                
//            }];
//            
//        }
//        //
////        for (AGSGDBFeature *feature in [features valueForKey:@"Xunying Fearue Layer"]) {
////            [self.localFeatureTableLayer setSelected:YES forFeature:feature];
////            NSLog(@"feature:%@",feature);
////            //
////            AGSProximityResult *myResults = [[AGSProximityResult alloc] init];
////            
////            myResults = [self.geometryEngineLocal nearestCoordinateInGeometry:[feature geometry] toPoint:mappoint];
////            NSLog(@"geometryEngineLocal:%@ and distance:%f",myResults,myResults.distance);
////        }
//        
//    }
//}

//
-(BOOL)mapView:(AGSMapView *)mapView shouldProcessClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    [self.graphicLayer removeAllGraphics];
    AGSSimpleMarkerSymbol *markSymbol = [[AGSSimpleMarkerSymbol alloc] initWithColor:[UIColor redColor]];
    //
//    AGSSimpleLineSymbol *simpleLineSymbol = [[AGSSimpleLineSymbol alloc] initWithColor:[UIColor blueColor] width:1.0f];
    AGSGraphic *myLineSymbol = [[AGSGraphic alloc] initWithGeometry:mappoint symbol:markSymbol attributes:nil];
    AGSGraphic *myStartSymbol = [[AGSGraphic alloc] initWithGeometry:self.startPoint symbol:markSymbol attributes:nil];
    [self.graphicLayer addGraphic:myLineSymbol];
    [self.graphicLayer addGraphic:myStartSymbol];
//    NSLog(@"enter showProcessClickAtPoint");
    NSLog(@"currentLocation,altitude:%f;latitude:%f;longtitude:%f",currentGPS.altitude,currentGPS.latitude,currentGPS.longtitude);
    
    NSLog(@"mappoint  latitude:%f,longitude:%f",mappoint.x,mappoint.y);
    
    AGSPoint *gpsPoint = [[AGSPoint alloc]initWithX:currentGPS.latitude y:currentGPS.longtitude spatialReference:[AGSSpatialReference wgs84SpatialReference]];
//    AGSPoint *gpsPoint = [[AGSPoint alloc]initWithX:mappoint.x y:mappoint.y spatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    NSLog(@"gpsPoint latitude:%f,longitude:%f",gpsPoint.x,gpsPoint.y);
    
    //print current location
    NSLog(@"curLocation:%@",[self.mapView.locationDisplay mapLocation]);
    
//    AGSGeometryEngine *geometryEngine = [AGSGeometryEngine defaultGeometryEngine];
    //如下是手动测距的方法，不过还得继续优化，添加两点之间的连接线，同时标记起点，终点以及把几个点击点给连接起来
    if(self.startPoint)
    {
        NSLog(@"distance:%f",[self.geometryEngineLocal distanceFromGeometry:self.startPoint toGeometry:mappoint]);
        NSLog(@"startPoint:%@",self.startPoint);
    }
    else{
        self.startPoint = mappoint;
        
    }
    __weak ViewController *weakSelf = self;
    //test query function  从第376行到392行是查询相应的障碍物，并测试了相应的两个障碍物之间的距离，同时如果想要查询一个定位点则通过[self.mapView.locationDisplay mappoint]获取到，在通过组装成AGSGeometry类型，再通过测距（相应的方法是：- (double)distanceFromGeometry:(AGSGeometry *)geometry1 toGeometry:(AGSGeometry *)geometry2）来得到距离结果！
    self.query.whereClause = @"QCM = '7'";
    [self.localFeatureTable queryResultsWithParameters:self.query completion:^(NSArray *results, NSError *err){
//        NSLog(@"results:%@ and count:%lu",results,(unsigned long)[results count]);
        static unsigned char totalCount;
        if(totalCount < [results count])
            totalCount++;
        else
            totalCount = 0;
        AGSGDBFeature *featureLoc = results[0];
        AGSGDBFeature *featureLoc1  = results[totalCount];
        NSLog(@"featureLoc:%@ and totalCount:%d",featureLoc1,totalCount);
        AGSGeometry *geometry1 = [featureLoc geometry];
        AGSGeometry *geometry2 = [featureLoc1 geometry];
        
//        [self.geometryEngineLocal distanceFromGeometry:geometry1 toGeometry:geometry2];
        NSLog(@"the distance is :%f",[weakSelf.geometryEngineLocal distanceFromGeometry:geometry1 toGeometry:geometry2]);
        NSLog(@"finish measuring the distance");
        
    }];
    
    
    
    return YES;
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return (UIInterfaceOrientationLandscapeRight);
}

#pragma -mark orientation
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma -mark prefersStatus
-(BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma -mark GPS_viewDidAppear
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.locationManager stopUpdatingLocation];
}
#pragma -mark GPS_viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
    self.navigationController.navigationBarHidden = YES;
}
#pragma -mark mapViewDidLoad
/**
 *  mapViewDidLoad
 *
 *  @param mapView current mapView
 */
-(void)mapViewDidLoad:(AGSMapView *)mapView
{
//    NSLog(@"enter mapViewDidLoad");
    //地图加载完成之后才调用下边的方法，否则会出现底图飘出当前可见的屏幕范围之外去，但是去掉了viewDidload中执行如下边的两条语句的时候，GPS点将不会显示出来！所以在上边的方法中依然调用了下边的语句，先完成再完善
    if(!self.mapView.locationDisplay.dataSourceStarted)
        [self.mapView.locationDisplay startDataSource];
}
#pragma -mark switchMapFunction
- (IBAction)switchMapFunction:(UISegmentedControl *)sender {
    NSLog(@"segment's index:%ld",(long)sender.selectedSegmentIndex);
    NSInteger index = sender.selectedSegmentIndex;
    sender.selected = NO;
    switch (index) {
        case 0: //自动测距
            
            break;
            //
        case 1: //选择球洞
            //此处加载选择球洞的视图
            [self.chooseHoleView setFrame:CGRectMake(10, self.navView.frame.size.height+80, ScreenWidth-20, self.chooseHoleView.frame.size.height)];
            [self.view addSubview:self.chooseHoleView];
            
            break;
            //
        case 2: //手动测距
            
            break;
        default:
            break;
    }
    
}

- (IBAction)whichButton:(UIButton *)sender {
    [self.chooseHoleView removeFromSuperview];
//    NSLog(@"curButton:%ld",[sender.titleLabel.text integerValue]);
    //
    [self.graphicLayer removeAllGraphics];
    //construct query SQL
    NSString *querySQL;
    querySQL = [NSString stringWithFormat:@"QCM = '%ld'",[sender.titleLabel.text integerValue]];
    //
    self.query = [AGSQuery query];
    self.query.whereClause = querySQL;
    //
    __block NSDictionary *curDic = [[NSDictionary alloc] init];
    __weak ViewController *weakSelf = self;
    [self.localHoleFeatureTable queryResultsWithParameters:self.query completion:^(NSArray *results, NSError *error){
        AGSGDBFeature *curFeatrue = results[0];
        curDic = [curFeatrue allAttributes];
        
        AGSSimpleFillSymbol *fillSymbolView = [[AGSSimpleFillSymbol alloc] initWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.15] outlineColor:[UIColor blueColor]];
        AGSGraphic *holeGraphic = [[AGSGraphic alloc] initWithGeometry:curDic[@"Shape"] symbol:fillSymbolView attributes:nil];
        [weakSelf.graphicLayer addGraphic:holeGraphic];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//构建模拟路径
-(void)constructPolyline
{
    //
    [self.route addPathToPolyline];
    //
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28256131500 y:29.49389984490 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28256669700 y:29.49432700910 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28281553500 y:29.49458953090 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28298506800 y:29.49505329810 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28341349200 y:29.49527828640 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28296532100 y:29.49592164420 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28253196400 y:29.49611735560 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28209158900 y:29.49624332170 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28165696300 y:29.49617591050 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28128793600 y:29.49595571510 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28105536100 y:29.49573897710 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28060691900 y:29.49565737550 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28037981600 y:29.49538747980 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.27988107400 y:29.49521089300 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.27950619300 y:29.49490423120 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
}

@end
