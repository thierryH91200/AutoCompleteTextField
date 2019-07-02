//
//  MainWindowController.swift
//  AutoCompleteTextField
//
//  Created by thierryH24 on 03/07/2018.
//  Copyright © 2018 thierryH24. All rights reserved.
//

import AppKit
import MapKit
import Contacts

class MainWindowController: NSWindowController {
    
    @IBOutlet weak var searchField: AutoCompleteTextField!
    @IBOutlet weak var tableViewCity: NSTableView!
    @IBOutlet weak var mapView: MKMapView!

    
    var autoCompleteFilterArray : [Cities1] = []
    var cities = [Cities1]()
    var arrayCity = [Cities1]()
    
    let Defaults = UserDefaults.standard
    var location = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    override var windowNibName: NSNib.Name? {
        return NSNib.Name( "MainWindowController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        searchField.tableViewDelegate = self
        DispatchQueue.global().async {
            self.cities = self.loadJson()
        }
        self.arrayCity = self.loadCity()
        tableViewCity.reloadData()
    }
    
    // MARK: - Util
    func loadJson() -> [Cities1]
    {
        var model = [Cities1]()
        
        let url = Bundle.main.url(forResource: "city.list", withExtension: "json")
        do {
            let data = try Data(contentsOf: url!)
            let decoder = JSONDecoder()
            model = try decoder.decode(Array<Cities1>.self, from: data)
            return model
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        return []
    }
    
    func loadCity() -> [Cities1] {
        var model = [Cities1]()
        let json = UserDefaults.standard.data(forKey: "cities")
        if let json = json {
            do {
                let decoder = JSONDecoder()
                model = try decoder.decode(Array<Cities1>.self, from: json)
                return model
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }
        return []

    }
    
    func saveCity()
    {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(arrayCity)
            Defaults.set(data, forKey: "cities")
            
        } catch {
            print("error: ", error)
        }
    }

    // MARK: - MapKit
    func addressEntered(_ latLong: CLLocation, info: String)
    {
        var addresses = [String]()
        let currentLocation = latLong
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler:
            { (placemarks, error)  in
                if let placemarks = placemarks
                {
                    for placemark in placemarks
                    {
                        addresses.append(self.formatAddressFromPlacemark(placemark))
                    }
                    
                    let coord = placemarks[0].location?.coordinate
                    self.pointAnnotaion(coord!, addresse: addresses, info: info)
                    
                    let latitude = placemarks[0].location!.coordinate.latitude
                    let longitude = placemarks[0].location!.coordinate.longitude
                    self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    
                    let spanX = 0.0725
                    let spanY = 0.0725
                    let span = MKCoordinateSpan (latitudeDelta: spanX, longitudeDelta: spanY)
                    let region = MKCoordinateRegion(center: self.location, span: span)
                    
                    self.mapView.setRegion(region, animated: true)
                }
                else
                {
                    print ("Address not found. : \(String(describing: error))")
                }
        }  )
    }
    
    func formatAddressFromPlacemark(_ placemark: CLPlacemark) -> String
    {
        let postalAddress = placemark.postalAddress
        let adresse = CNPostalAddressFormatter.string(from:postalAddress!, style: .mailingAddress)
        return adresse
    }
    
    func pointAnnotaion(_ coordinate: CLLocationCoordinate2D, addresse: [String], info: String)
    {
        var currentTextField = ""
        for i in 0..<addresse.count
        {
            currentTextField = currentTextField + addresse[i]
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = info
        annotation.subtitle = currentTextField
        self.mapView.addAnnotation(annotation)
    }
    
    func tableViewSelection(_ notification: Notification)
    {
        let tableView = notification.object as! NSTableView
        let row = tableView.selectedRow
        guard row != -1 else {  return }
        
        let latitude = autoCompleteFilterArray[row].coord.latitude
        let longitude = autoCompleteFilterArray[row].coord.longitude
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        mapView.removeAnnotations(mapView.annotations)
        addressEntered(location, info: "City")
    }

    // MARK: - Actions
    @IBAction func addItem(_ sender: NSButton)
    {
        let selectedRow = Defaults.integer(forKey: "selectedRow")
        guard selectedRow != -1 else { return }
        
        // tableView
        let city = self.autoCompleteFilterArray[selectedRow]
        let cityExist = arrayCity.filter { $0.id == city.id }.count
        guard cityExist == 0 else { return }
        
        arrayCity.append(city)
        
        tableViewCity.reloadData()
        
        tableViewCity.scrollRowToVisible(arrayCity.count - 1 )
        tableViewCity.selectRowIndexes(IndexSet(integer: arrayCity.count - 1), byExtendingSelection: false)
        
        saveCity()
    }
    
    @IBAction func removeItem(_ sender: NSButton)
    {
        // tableView
        let selectedRow = tableViewCity.selectedRow
        arrayCity.remove(at: selectedRow)
        
        tableViewCity.reloadData()
        
        tableViewCity.scrollRowToVisible(selectedRow - 1 )
        tableViewCity.selectRowIndexes(IndexSet(integer: selectedRow - 1), byExtendingSelection: false)
        
        saveCity()
    }
    
}

// MARK: - NSTableViewDataSource
extension MainWindowController: NSTableViewDataSource
{
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return arrayCity.count
    }
}

// MARK: - NSTableViewDelegate
extension MainWindowController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        let cellView: NSTableCellView?
        let identifier = tableColumn!.identifier
        cellView = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView
        
        switch identifier
        {
        case .nameCell:
            cellView?.textField?.stringValue = arrayCity[row].name
            
        case .countryCell:
            cellView?.textField?.stringValue = arrayCity[row].country
            
        case .flagCell:
            cellView?.textField?.stringValue = Flag.of(code:arrayCity[row].country)
            cellView?.textField?.alignment = .center
            
        default:
            cellView?.textField?.stringValue = arrayCity[row].name
        }
        
        return cellView
    }
    
     func tableViewSelectionDidChange(_ notification: Notification)
    {
        let tableView = notification.object as! NSTableView
        
        let row = tableView.selectedRow
        guard row != -1 else { return }
        
        let latitude = arrayCity[row].coord.latitude
        let longitude = arrayCity[row].coord.longitude
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        mapView.removeAnnotations(mapView.annotations)
        addressEntered(location, info: "City")
    }

}


// MARK: - AutoCompleteTableViewDelegate
extension MainWindowController  : AutoCompleteTableViewDelegate {
    
    func textField1(_ textField: NSTextField, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: Int) -> [String] {
        
        let searchString = searchField.stringValue
        
//        autoCompleteFilterArray = cities.filter{ $0.name.hasPrefix(searchString) || $0.country.contains( searchString )}
        autoCompleteFilterArray = cities.filter{ $0.name.hasPrefix(searchString) }

        let matches = (0..<autoCompleteFilterArray.count).map { (i) -> String in
            return autoCompleteFilterArray[i].name + ", " + autoCompleteFilterArray[i].country
        }
        return matches
    }
    
}

// MARK: -
extension NSUserInterfaceItemIdentifier {
    static let nameCell       = NSUserInterfaceItemIdentifier("name")
    static let countryCell       = NSUserInterfaceItemIdentifier("country")
    static let flagCell       = NSUserInterfaceItemIdentifier("flag")
}


// MARK: -
struct Flag {
    private static let map = [
        "A":"\u{1F1E6}",
        "B":"\u{1F1E7}",
        "C":"\u{1F1E8}",
        "D":"\u{1F1E9}",
        "E":"\u{1F1EA}",
        "F":"\u{1F1EB}",
        "G":"\u{1F1EC}",
        "H":"\u{1F1ED}",
        "I":"\u{1F1EE}",
        "J":"\u{1F1EF}",
        "K":"\u{1F1F0}",
        "L":"\u{1F1F1}",
        "M":"\u{1F1F2}",
        "N":"\u{1F1F3}",
        "O":"\u{1F1F4}",
        "P":"\u{1F1F5}",
        "Q":"\u{1F1F6}",
        "R":"\u{1F1F7}",
        "S":"\u{1F1F8}",
        "T":"\u{1F1F9}",
        "U":"\u{1F1FA}",
        "V":"\u{1F1FB}",
        "W":"\u{1F1FC}",
        "X":"\u{1F1FD}",
        "Y":"\u{1F1FE}",
        "Z":"\u{1F1FF}"]
    
    static func of(code:String)->String {
        var flagStr = ""
        for c in code.uppercased() {
            if let s = map["\(c)"] {
                flagStr += s
            }
        }
        return flagStr
    }
}



