#!/usr/bin/env xcrun swift

import Foundation


extension Optional {
    func getOrElse(defaultValue: T) -> T {
        switch(self) {
            case .None:
                return defaultValue
            case .Some(let value):
                return value
        }
    }
}

let path = "Karabiner/private"

let task = NSTask()
let pipe = NSPipe()

task.launchPath = "/bin/pwd"
task.standardOutput = pipe
task.launch()

let pwd = pipe.fileHandleForReading.readDataToEndOfFile()
let output: String? = NSString(data: pwd, encoding: NSUTF8StringEncoding)

println(output.getOrElse("no output for task \(task.launchPath)"))

var filePath = NSBundle.mainBundle().pathForResource(path, ofType:"xml")
switch filePath {
  case .None: println("no such file \(path)")
  case .Some(let string)  : 
    var data     = NSData(contentsOfFile:string)
    println(data)
}
