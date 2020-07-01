//
//  ViewController.swift
//  MapDistance
//
//  Created by Arunkumar Nachimuthu on 2020-06-17.
//  Copyright © 2020 Arunkumar Nachimuthu. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet private var mapview: MKMapView!
    
    @IBOutlet weak var addPlaceText: UITextField!
    var count:Int = 0;
    var lats:[Double] = [Double]()
    var longs:[Double] = [Double]()
    var distances:[Double] = [Double]()
    var pinNames:[String] = ["A", "B", "C", "D", "E", "F", "G"]
    
    @IBOutlet weak var zoomStepper: UIStepper!
    var zoomStepperVal:Double = 0
    
    
    @IBOutlet weak var allowedSlider: UISlider!
    
    @IBOutlet weak var allowedLabel: UILabel!
    
    var lastLatLong:Int=0;
    
    var polyCoor:[CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    
    var polygon: MKPolygon? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapview.delegate = self
     }
    

      override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Let's put in a log statement to see the order of events
        
        for touch in touches {
            let touchPoint = touch.location(in: self.mapview)
            let location = self.mapview.convert(touchPoint, toCoordinateFrom: self.mapview)
            //print ("\(location.latitude), \(location.longitude)")
            updateMap(location:location,titleForPin:pinNames[count])
    }

    }
    
    func markLocation(pinName:String)->CustomAnnotation    {
        let annotation = CustomAnnotation()
        annotation.title = pinName
        //You can also add a subtitle that displays under the annotation such as
        //annotation.subtitle = "One day I'll go here..."
        annotation.coordinate = CLLocationCoordinate2D(latitude: lats[count], longitude: longs[count])
        //annotation = UIColor.green
        annotation.label = "point";
        mapview.addAnnotation( annotation)
        return annotation
    }
    
    func findDistance(loc1:CLLocation, loc2:CLLocation)->Double    {
       
        return loc1.distance(from: loc2)
    }
    
    
   
    
    func createPolyline(point1:CLLocationCoordinate2D,point2:CLLocationCoordinate2D, dis:Double) {
        

        let points: [CLLocationCoordinate2D]
        points = [point1, point2]

        let poly = MKPolyline(coordinates: points, count: 2)
        mapview.addOverlay(poly)
        var temp:Int = Int(dis/1000)
        let annotation = CustomAnnotation()
        annotation.label = "distance"
        var title:String = " \(temp) KM"
        annotation.title = NSLocalizedString(title, comment: "")
        annotation.coordinate = CLLocationCoordinate2D(latitude: (point1.latitude+point2.latitude)/2, longitude:(point1.longitude+point2.longitude)/2)
        
        
        mapview.addAnnotation(annotation)
        
        
    }
    
    func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
           if overlay is MKPolyline {
               let polylineRenderer = MKPolylineRenderer(overlay: overlay)
               polylineRenderer.strokeColor = UIColor.blue
               polylineRenderer.lineWidth = 5
               return polylineRenderer
           }
            if let _ = overlay as? MKPolygon{
                let renderer = MKPolygonRenderer(polygon: polygon!)
                renderer.fillColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.5)
                return renderer
            
            }


           return nil
       }
    
    func updateDistance()
    {
        let sum:Int = Int(distances.reduce(0, +))
        
        if(count == Int(allowedSlider.value))
        {
            updateCenter(sum:sum)
            addPolygon()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {return nil }
        
        let temp = annotation as! CustomAnnotation
        var sticker:UILabel!
        if(temp.label == "point")
        {
            sticker = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            sticker.textColor = getRandomColor()
        }
        else if(temp.label == "distance")
        {
            sticker = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 70))
        }
        else
        {
            sticker = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 70))
        }
        sticker.text = temp.title
        //print(sticker)
        
        
        let annotationIdentifier = "restAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView

            if(temp.label == "point")
            {
                 var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView?.pinTintColor = sticker.textColor
                annotationView?.canShowCallout = true
                annotationView?.addSubview(sticker)
                annotationView?.frame = sticker.frame
                annotationView?.annotation = annotation
                
                return annotationView
                
            }
            else
            {
                 var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView?.canShowCallout = true
                annotationView?.addSubview(sticker)
                annotationView?.frame = sticker.frame
                annotationView?.annotation = annotation
                
                return annotationView

            }
            
    }
    func getRandomColor() -> UIColor {
         //Generate between 0 to 1
         let red:CGFloat = CGFloat(drand48())
         let green:CGFloat = CGFloat(drand48())
         let blue:CGFloat = CGFloat(drand48())

         return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
    }
    
    func updateCenter(sum:Int)
    {
        let annotation = CustomAnnotation()
        annotation.label = "total"
            let title:String = "Total: \(sum/1000) KM"
        annotation.title = NSLocalizedString(title, comment: "")
        //annotation.coordinate = CLLocationCoordinate2D(latitude: (lats[0]+lats[2])/2, longitude:(longs[0]+longs[2])/2)
        annotation.coordinate = CLLocationCoordinate2D(latitude: (((lats[0]+lats[2])/2)+(lats[1]+lats[3])/2)/2, longitude:(((longs[0]+longs[2])/2)+((longs[1]+longs[3])/2))/2)
            mapview.addAnnotation(annotation)
    }
    
   
    
    func addPolygon() {
        polyCoor.append(polyCoor[polyCoor.count - 1])
        let polygon = MKPolygon(coordinates: polyCoor, count: polyCoor.count)
        self.polygon = polygon
        mapview.addOverlay(polygon)
    }
    
    
    @IBAction func addPlace(_ sender: UIButton) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = addPlaceText.text!
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error")
                return
            }
//            let annot = CustomAnnotation()
//            annot.title = self.addPlaceText.text
//            annot.label = "point"
//            let lat = response.boundingRegion.center.latitude
//            let lon = response.boundingRegion.center.longitude
//            annot.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
//            self.mapview.addAnnotation(annot)
            self.updateMap(location: response.boundingRegion.center,titleForPin:self.addPlaceText.text!)
        }
    }
    
    func updateMap(location:CLLocationCoordinate2D,titleForPin:String)
    {
        if(count<Int(allowedSlider.value))
            {
                
                lats.append(location.latitude)
                longs.append(location.longitude)
                var lastAnnotation = markLocation(pinName: titleForPin)
                if(count==0)
                {
                    polyCoor.append(location)
                }
                if(count != 0)
                {
                   var dis = findDistance(loc1: CLLocation(latitude: lats[lastLatLong], longitude: longs[lastLatLong]), loc2: CLLocation(latitude: lats[count], longitude: longs[count]))
                    if(dis>100000)
                    {
                    distances.append(dis)
                    createPolyline(point1: CLLocationCoordinate2DMake(lats[lastLatLong],longs[lastLatLong]), point2:  CLLocationCoordinate2DMake( lats[count],longs[count]), dis: dis)
                        polyCoor.append(location)
                        lastLatLong = count
                    }
                    else{
                        mapview.removeAnnotation(lastAnnotation)
                    }
                }
                count+=1
                if(count==Int(allowedSlider.value))
                {
                    var dis = findDistance(loc1: CLLocation(latitude: lats[count-1], longitude: longs[count-1]), loc2: CLLocation(latitude: lats[0], longitude: longs[0]))
                    distances.append(dis)
                    createPolyline(point1: CLLocationCoordinate2DMake(lats[lastLatLong], longs[lastLatLong]), point2:  CLLocationCoordinate2DMake( lats[0],longs[0]), dis: dis)
                }
                updateDistance()
                

            }
        }
 
}

