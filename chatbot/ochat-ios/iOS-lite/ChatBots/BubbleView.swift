//
//  BubbleView.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/13/16.
//  Copyright © 2016 Oracle. All rights reserved.
//

import UIKit
import MapKit

struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

class BubbleView: UIView, MKMapViewDelegate {

    var arrChoices:NSArray?

    var imageViewBG: UIImageView?
    var text: String?
    var labelChatText: UILabel?
    var listView: UITableView?
    var mapView: MKMapView?
    var btn:UIButton?
    
    func heightFor(constraintedWidth width: CGFloat, font: UIFont, txt:String) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = txt
        label.sizeToFit()
        return label.frame.height
    }
    
    init(data: ChatMessege, startY: CGFloat, choices:NSArray?, map:NSDictionary? ){
        
        let _map:NSDictionary? = map;
        super.init(frame: BubbleView.framePrimary(data.type, startY:startY))
        
        let padding: CGFloat = 10.0
        self.backgroundColor = UIColor.clear
        let lblHeight:CGFloat = heightFor(constraintedWidth: (self.frame.width - 2 * padding), font: UIFont.systemFont(ofSize: 12), txt: data.text!);
        
        if data.text != nil {

            let startX = padding
            let startY:CGFloat = 5.0

            labelChatText = UILabel(frame: CGRect(x: startX, y: startY, width: self.frame.width - 2 * startX , height: lblHeight))
            labelChatText?.textAlignment = data.type == .mineBubble ? .right : .left
            labelChatText?.font = UIFont.systemFont(ofSize: 14)
            labelChatText?.numberOfLines = 0 // Making it multiline
            labelChatText?.text = data.text
            
            if data.type == .mineBubble {
                labelChatText?.textColor = UIColor.white
            }
            else{
                labelChatText?.textColor = UIColor.black
            }
            
            labelChatText?.sizeToFit()
            self.addSubview(labelChatText!)
        }
        
        if ( choices != nil ) {
            
            arrChoices = choices;
            let startX = 0.0
            let startY:CGFloat = lblHeight < 25 ? 25 : lblHeight
            
            listView = UITableView(frame: CGRect(x: CGFloat(startX), y: startY, width: self.frame.width , height: (CGFloat((choices?.count)!*28)) ))
            listView?.tag = 1
            listView?.delegate = self
            listView?.dataSource = self
            listView?.isScrollEnabled = false
            listView?.separatorInset.left = 0
            self.addSubview(listView!)
        }
        

        var viewHeight: CGFloat = 0.0
        var viewWidth: CGFloat = 0.0
        viewHeight = labelChatText!.frame.maxY + padding/2
        viewWidth = labelChatText!.frame.width + labelChatText!.frame.minX + padding
        
        if ( choices != nil ) {
            viewHeight = lblHeight + 5.0 + (CGFloat((choices?.count)!*28))
            viewWidth = listView!.frame.maxX;
        }
        
        if ( _map != nil ) {
            
            let startY:CGFloat = lblHeight < 25 ? 25 : lblHeight
            let startX = 0.0
            
            let mapV:MKMapView = MKMapView.init(frame: CGRect(x: CGFloat(startX), y: startY, width: self.frame.width , height: 110))
            
            mapV.mapType = MKMapType.standard
            mapV.isZoomEnabled = true
            mapV.showsUserLocation = true
            mapV.delegate = self;
            self.addSubview(mapV)
            self.bringSubview(toFront: mapV)
            //mapView = mapV;
            
            let coord:CLLocationCoordinate2D;
            
            coord = CLLocationCoordinate2D.init(latitude: (map?.object(forKey: "lat") as! NSString).doubleValue , longitude: (map?.object(forKey: "long") as! NSString).doubleValue)
            
            addAnnotionFor(coord, name: map?.object(forKey: "name") as! String, mapV:mapV );

            viewHeight = lblHeight + 125.0;
            viewWidth = mapV.frame.maxX;
            if( viewWidth < 150 ){
                viewWidth = 150
            }
        }
        else{
            mapView = nil;
        }

        
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: viewWidth, height: viewHeight)
        
        // Adding the resizable bubble like shape
        let bubbleImageFileName = data.type == .mineBubble ? "chatBubbleMine" : "chatBubbleOpp"
        imageViewBG = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height))
        if data.type == .mineBubble {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(14, 14, 17, 28))
        } else {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(14, 22, 17, 20))
        }
        self.addSubview(imageViewBG!)
        self.sendSubview(toBack: imageViewBG!)
        
        // Create a frame with background bubble
        let repositionXFactor:CGFloat = data.type == .mineBubble ? 0.0 : -7.0
        let bgImageNewX = imageViewBG!.frame.minX + repositionXFactor
        let bgImageNewWidth =  imageViewBG!.frame.width + CGFloat(9.0)
        let bgImageNewHeight =  imageViewBG!.frame.height + CGFloat(5.0)
        imageViewBG?.frame = CGRect(x: bgImageNewX, y: 0.0, width: bgImageNewWidth, height: bgImageNewHeight)
        
        var newStartX:CGFloat = 0.0
        if data.type == .mineBubble{
            let extraWidthToConsider = imageViewBG!.frame.width
            newStartX = ScreenSize.SCREEN_WIDTH - extraWidthToConsider
        } else {
            newStartX = -imageViewBG!.frame.minX + 3.0
        }
        
        self.frame = CGRect(x: newStartX, y: self.frame.minY, width: frame.width, height: frame.height)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("coder: Not Implemented")
    }
    
    public class func framePrimary(_ type:BubbleType, startY: CGFloat) -> CGRect{
        let paddingFactor: CGFloat = 0.02
        let sidePadding = ScreenSize.SCREEN_WIDTH * paddingFactor
        let maxWidth = ScreenSize.SCREEN_WIDTH * 0.75
        
        let startX: CGFloat = type == .mineBubble ? ScreenSize.SCREEN_WIDTH * (CGFloat(1.0) - paddingFactor) - maxWidth : sidePadding
        return CGRect(x: startX, y: startY, width: maxWidth, height: 7)
    }
    
    func btnTapped() {
        print("btn tapped..");
    }
    
    func mapView(_ mapView: MKMapView, didUpdate
        userLocation: MKUserLocation) {
        mapView.centerCoordinate = userLocation.location!.coordinate
    }
    
    func addAnnotionFor(_ coordinate:CLLocationCoordinate2D, name:String, mapV:MKMapView) -> Void {
        
        let annotation = MKPointAnnotation()
        annotation.title = "Pin Title"
        annotation.subtitle = name
        annotation.coordinate = coordinate
        
        mapV.addAnnotation(annotation)
        
        let region = MKCoordinateRegionMakeWithDistance(
            (coordinate), 2000, 2000)
        
        mapV.setRegion(region, animated: true)
    }

    func zoomInToUserLocation(_ sender: AnyObject) {
        
        let userLocation = mapView?.userLocation
        
        let region = MKCoordinateRegionMakeWithDistance(
            (userLocation?.location!.coordinate)!, 1000, 1000)
        
        mapView?.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        let annotationIdentifier = "aPin"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        annotationView!.image = UIImage(named: "map-pin")
        
        return annotationView
    }
}
