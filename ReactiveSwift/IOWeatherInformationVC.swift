//
//  IOWeatherInformationVC.swift
//  ReactiveSwift
//
//  Created by ben on 25/05/2015.
//
//

import UIKit
import ReactiveCocoa
import Alamofire

class IOWeatherInformationVC: UIViewController {

    @IBOutlet weak var lblState     :UILabel!
    @IBOutlet weak var lblTemp      :UILabel!
    @IBOutlet weak var lblTempMin   :UILabel!
    @IBOutlet weak var lblTempMax   :UILabel!
    @IBOutlet weak var lblSunRise   :UILabel!
    @IBOutlet weak var lblSunSet    :UILabel!
    
    var weather :IOWeather!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.weather = IOWeather()
        self.lblState.text = ""
        
        self.setupSignals()
        self.loadWeatherData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: Private
    
    func setupSignals() {
        
        let df:NSDateFormatter = NSDateFormatter()
        df.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let nameChangedSignal = self.weather!.rac_valuesForKeyPath("name", observer: self)
            .map { (newVal:AnyObject!) -> AnyObject! in
                if (newVal != nil) && ((newVal as! NSString).length > 3) {
                    return newVal
                }
                return ""
        }
        nameChangedSignal ~> RAC(self.lblState, "text")
        
        let tempMinChangedSignal = self.weather!.rac_valuesForKeyPath("temp_min", observer: self)
            .map { (newVal:AnyObject!) -> AnyObject! in
                if newVal != nil {
                    return NSString(format: "min %.f °C", newVal.floatValue)
                }
                return ""
        }
        tempMinChangedSignal ~> RAC(self.lblTempMin, "text")
        
        let tempMaxChangedSignal = self.weather!.rac_valuesForKeyPath("temp_max", observer: self)
            .map { (newVal:AnyObject!) -> AnyObject! in
                if newVal != nil {
                    return NSString(format: "max %.f °C", newVal.floatValue)
                }
                return ""
        }
        tempMaxChangedSignal ~> RAC(self.lblTempMax, "text")
        
        let tempChangedSignal = self.weather!.rac_valuesForKeyPath("temp", observer: self)
            .map { (newVal:AnyObject!) -> AnyObject! in
                if newVal != nil {
                    return NSString(format: "%.f °C", newVal.floatValue)
                }
                return ""
        }
        tempChangedSignal ~> RAC(self.lblTemp, "text")
        
        let sunRiseChangedSignal = self.weather!.rac_valuesForKeyPath("dateSunRise", observer: self)
            .map { (newVal:AnyObject!) -> AnyObject! in
                if let date = newVal as? NSDate {
                    return df.stringFromDate(date)
                }
                return ""
        }
        sunRiseChangedSignal ~> RAC(self.lblSunRise, "text")
        
        let sunSetChangedSignal = self.weather!.rac_valuesForKeyPath("dateSunSet", observer: self)
            .map { (newVal:AnyObject!) -> AnyObject! in
                if let date = newVal as? NSDate {
                    return df.stringFromDate(date)
                }
                return ""
        }
        sunSetChangedSignal ~> RAC(self.lblSunSet, "text")
    }
    
    //MARK: WebService
    
    func loadWeatherData() {
        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/weather?q=paris,fr&units=metric")
            .validate(statusCode: 200..<300)
            .responseJSON { (_, _, JSON, _) in
                
                if let dicJSON = JSON as? [String : AnyObject] {
                    self.weather.parseWeatherFromDictionary(dicJSON)
                }
        }
    }
}
