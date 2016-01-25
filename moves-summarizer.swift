#!/usr/bin/swift

import Foundation

let activities = ["walking", "transport", "underground", "ferry", "running", "bus", "airplane", "train", "boat"]

extension String {
    var lines: [String] {
        var result = [String]()
        enumerateLines { (line, stop) -> () in
            result.append(line)
        }
        return result
    }
}

func activityDataPerFile(activity: String, inFile file: String) -> (time: Float, distance: Float)
{
    do {
        let path = NSString(string: file).stringByExpandingTildeInPath
        let content = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
        let body = content.lines.dropFirst()
        
        for line in body {
            let parts = line.componentsSeparatedByString(",")
            
            if parts[1] == activity {
                let time = Float(parts[3])!
                let distance = Float(parts[4])!
                
                return (time, distance)
            }
        }
    }
    catch {}
    
    return (0, 0)
}

let args = Process.arguments

if args.count == 2 && args[1].characters.count > 0 {
    let path = args[1]
    
    for activity in activities {
        var total: (time: Float, distance: Float) = (0, 0)
        let files = NSFileManager().enumeratorAtPath(NSString(string: path).stringByExpandingTildeInPath)
        
        while let file = files?.nextObject() {
            let activityData = activityDataPerFile(activity, inFile: path + "/" + (file as! String))
            
            total.time += activityData.time
            total.distance += activityData.distance
        }
        
        let hours = String(format: "%.1f hours", total.time / 3600)
        let distance = String(format: "%.1f miles", total.distance)
        
        print("\(activity):\n  * \(hours)\n  * \(distance)")
    }
}
else {
    print("usage: moves-summarizer.swift [path to .csv files]")
}