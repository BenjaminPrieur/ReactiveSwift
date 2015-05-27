//
//  IOWeather.swift
//  ReactiveSwift
//
//  Created by ben on 25/05/2015.
//
//

import UIKit

class IOWeather: NSObject {
   
    dynamic var name    :String!
    var id              :Double!
    var base            :String!
    var weather         :Array<AnyObject?>?
    dynamic var temp    :NSNumber!
    dynamic var temp_min:NSNumber!
    dynamic var temp_max:NSNumber!
    dynamic var dateSunRise :NSDate!
    dynamic var dateSunSet  :NSDate!
    
    override init() {
        super.init()
    }
    
    func parseWeatherFromDictionary(dic:Dictionary<String,AnyObject>) {
        
        name      = dic["name"] as! String
        id        = dic["id"] as! Double
        base      = dic["base"] as! String
        weather   = dic["weather"] as? Array
        temp      = (dic["main"] as! Dictionary)["temp"]! as NSNumber
        temp_min  = (dic["main"] as! Dictionary)["temp_min"]! as NSNumber
        temp_max  = (dic["main"] as! Dictionary)["temp_max"]! as NSNumber
        
        println(((dic["sys"] as! Dictionary<String,AnyObject>)["sunrise"]! as! NSNumber).doubleValue)
        dateSunRise = NSDate(timeIntervalSince1970: ((dic["sys"] as! Dictionary<String,AnyObject>)["sunrise"]! as! NSNumber).doubleValue)
        dateSunSet = NSDate(timeIntervalSince1970: ((dic["sys"] as! Dictionary<String,AnyObject>)["sunset"]! as! NSNumber).doubleValue)
        
        println("Weather parsed")
//        println("--------------------------")
//        println(dic)
//        println("--------------------------")
    }
}
