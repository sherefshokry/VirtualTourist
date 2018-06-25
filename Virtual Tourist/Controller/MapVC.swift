//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by SherifShokry on 6/12/18.
//  Copyright © 2018 SherifShokry. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage
import SwiftyJSON

class MapVC: UIViewController , UIGestureRecognizerDelegate{

    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius : Double = 1000
    var imageUrlArray = [String]()
    var photoArray = [Photo]()
    var popUpViewHeightConstraint : NSLayoutConstraint?
    
    
    
    lazy var myMap : MKMapView = {
        let map = MKMapView()
        map.isZoomEnabled = false
        map.isRotateEnabled = false
        map.showsCompass = false
        map.showsUserLocation = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDropPin(sender:)))
        gestureRecognizer.numberOfTapsRequired = 2
        gestureRecognizer.delegate = self
        map.addGestureRecognizer(gestureRecognizer)
        return map
    }()
    
    
    @objc func handleDropPin(sender : UITapGestureRecognizer) {
        handleRemovePin()
        removeSpinner()
        removeProgressLabel()
        cancelAllSetions()
        
        imageUrlArray = []
        photoArray = []
        
        collectionView.reloadData()
        
        
        animateViewUp()
        addSpinner()
        addProgressLabel()
        
    let touchPoint = sender.location(in: myMap)
    let touchCoordinate = myMap.convert(touchPoint, toCoordinateFrom: myMap)
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
       myMap.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0 , regionRadius * 2.0)
        myMap.setRegion(coordinateRegion, animated: true)
   
    
        let params : [String : String] =  ["api_key" : API_KEY , "lat" : String(annotation.coordinate.latitude) , "lon" : String(annotation.coordinate.longitude) , "radius" : "1" , "radius_units" : "mi" ,"per_page" : "15", "format" : "json" , "nojsoncallback" : "1"]
        requestApiJson(params)
  
    }
    
    func requestApiJson(_ parameter : [String : String] )
    {
        Alamofire.request(URL, method: .get, parameters: parameter ).responseJSON
            {
                response in
                if response.result.isSuccess
                {
                    let json = JSON(response.value!)
                    self.parseJsonData(json)
                }
        }
    }
    

    func parseJsonData(_ json : JSON)
    {
        imageUrlArray = []
        photoArray = []
       
        progressLabel.text = "0/15 photos downloaded"
        
        for index in 0..<15
        {
            // photo url
            let URL : String = "https://farm\(json["photos"]["photo"][index]["farm"].stringValue).staticflickr.com/\(json["photos"]["photo"][index]["server"].stringValue)/\(json["photos"]["photo"][index]["id"].stringValue)_\(json["photos"]["photo"][index]["secret"].stringValue)_h_d.jpg"
           
            imageUrlArray.append(URL)
        }
        
        downloadImages { (finished) in
            if finished {
                self.removeSpinner()
                self.removeProgressLabel()
                self.cancelAllSetions()
                self.collectionView.reloadData()
            }
        }
    }

    func downloadImages(completion : @escaping (_ status : Bool) -> ())
    {
        
        for url in imageUrlArray
        {

            Alamofire.request(url).responseImage {
                response in
                
                if response.error != nil {
                    print("Error URL : " , url)
                }
                
                guard let image = response.result.value else { return }
                
               
                 self.progressLabel.text = "\(self.photoArray.count + 1 )/15 photos downloaded"
                    let photo = Photo(photo: image)
                    self.photoArray.append(photo)
                if self.photoArray.count == self.imageUrlArray.count {
                    completion(true)
                }
                
            }
        }

    }
    
    
    func cancelAllSetions(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    
    func handleRemovePin(){
        for annotation in myMap.annotations{
            myMap.removeAnnotation(annotation)
        }
    }
    
    func animateViewUp(){
        popUpViewHeightConstraint?.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner(){
        collectionView.addSubview(spinner)
       spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: popUpView.centerYAnchor).isActive = true
        spinner.startAnimating()
       
    }
    func addProgressLabel(){
        collectionView.addSubview(progressLabel)
        
        progressLabel.anchor(top: spinner.bottomAnchor, bottom: nil, left: nil, right: nil, topPadding: 5, bottomPadding: 0, leftPadding: 0, rightPadding: 0, width: 0, height: 0)
        progressLabel.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).isActive = true
        
    }
    
    func removeSpinner(){
        spinner.removeFromSuperview()
    }
    
    func removeProgressLabel(){
      progressLabel.removeFromSuperview()
    }
    
    
    
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource  = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: cellId)
        return collectionView
    }()
    
    
    
    let progressLabel : UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    
    let topLabel : UILabel = {
        let label = UILabel()
        label.text = "Double-tap to drop a pin and view photos"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    
    lazy var locationButton : UIButton = {
    let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "locationButton"), for: .normal)
        button.addTarget(self, action: #selector(handleCenterMyLocation), for: .touchUpInside)
        return button
    }()
    
    
    
    
    @objc func handleCenterMyLocation() {
        
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
        
    }
    
    
    lazy var popUpView : UIView = {
       let view = UIView()
        view.backgroundColor = .white
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipe.direction = .down
        view.addGestureRecognizer(swipe)
        return view
    }()
    
    
    @objc func handleSwipeDown(){
        cancelAllSetions()
        removeSpinner()
        removeProgressLabel()
        popUpViewHeightConstraint?.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    let spinner : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.color = .black
       return indicator
    }()
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .white
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        myMap.delegate = self
        setupMapVCLayout()
        configureLocationServices()
        
        popUpView.addSubview(collectionView)
        collectionView.anchor(top: popUpView.topAnchor, bottom: popUpView.bottomAnchor, left: popUpView.leadingAnchor, right: popUpView.trailingAnchor, topPadding: 0, bottomPadding: 0, leftPadding: 0, rightPadding: 0, width: 0, height: 0)
        
    }

    
    
    
    
    
    
    fileprivate func  setupMapVCLayout(){
    
        view.addSubview(myMap)
        
        myMap.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.safeAreaLayoutGuide.leadingAnchor, right: view.safeAreaLayoutGuide.trailingAnchor, topPadding: 0, bottomPadding: 0, leftPadding: 0, rightPadding: 0, width: 0, height: 0)
        
        let topView = UIView()
        topView.backgroundColor = UIColor.rgb(red: 246, green: 166, blue: 35)
        myMap.addSubview(topView)
        
        topView.anchor(top: myMap.topAnchor, bottom: nil, left: myMap.leadingAnchor, right: myMap.trailingAnchor, topPadding: 0, bottomPadding: 0, leftPadding: 0, rightPadding: 0, width: 0, height: 70)
        
        topView.addSubview(topLabel)
        
        topLabel.anchor(top: nil, bottom: nil, left: topView.leadingAnchor, right: topView.trailingAnchor, topPadding: 0, bottomPadding: 0, leftPadding: 15, rightPadding: 15, width: 0, height: 30)
        topLabel.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        
        view.addSubview(popUpView)
        
        popUpView.anchor(top: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.safeAreaLayoutGuide.leadingAnchor, right: view.safeAreaLayoutGuide.trailingAnchor, topPadding: 0, bottomPadding: 0, leftPadding: 0, rightPadding: 0, width: 0, height: 0)
        popUpViewHeightConstraint = popUpView.heightAnchor.constraint(equalToConstant: 0)
        popUpViewHeightConstraint?.isActive = true
        
        view.addSubview(locationButton)
        locationButton.anchor(top: nil, bottom: popUpView.topAnchor, left: nil, right: view.safeAreaLayoutGuide.trailingAnchor, topPadding: 0, bottomPadding: 15, leftPadding: 0, rightPadding: 5, width: 50, height: 50)
        
        
    }


}








extension MapVC : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.tintColor  = UIColor.rgb(red: 246, green: 166, blue: 35)
        pinAnnotation.animatesDrop = true
        
        return pinAnnotation
    }
    
    
    
    func centerMapOnUserLocation() {
      
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0 , regionRadius * 2.0)
        myMap.setRegion(coordinateRegion, animated: true)
    
    }
    
    
}



extension MapVC : CLLocationManagerDelegate {
    
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        else {
           return
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
    
}




extension MapVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCell
        cell.photo = photoArray[indexPath.item]
        return cell
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 4) / 5
        return CGSize(width: width , height: 60)
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageController = ImageController()
        imageController.photo = photoArray[indexPath.item]
        present( imageController, animated: true, completion: nil)
    }
}





