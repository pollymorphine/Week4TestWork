//
//  BruteForceOperation.swift
//  Week3TestWork
//
//  Created by Polina on 22.04.2020.
//  Copyright © 2020 E-legion. All rights reserved.
//

import Foundation

final class BruteForceOperation: Operation {
    
    private let startString: String
    private let endString: String
    private let password: String
    private let characterArray = Consts.characterArray
    var result: String? {
        didSet {
            cancel()
        }
    }
    
    
    init(startString: String, endString: String, password: String) {
        self.startString = startString
        self.endString = endString
        self.password = password
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        let inputPassword = password
        var startIndexArray = [Int]()
        var endIndexArray = [Int]()
        let maxIndexArray = characterArray.count
        
        for char in startString {
            for (index, value) in characterArray.enumerated() where value == "\(char)" {
                startIndexArray.append(index)
            }
        }
        for char in endString {
            for (index, value) in characterArray.enumerated() where value == "\(char)" {
                endIndexArray.append(index)
            }
        }
        
        var currentIndexArray = startIndexArray
        
        while (!isCancelled) {
            
            let currentPass = self.characterArray[currentIndexArray[0]] + self.characterArray[currentIndexArray[1]] + self.characterArray[currentIndexArray[2]] + self.characterArray[currentIndexArray[3]]
            
            if currentPass == inputPassword {
                result = currentPass
            } else {
                if currentIndexArray.elementsEqual(endIndexArray) {
                    break
                    // cancel()
                }
                
                for index in (0 ..< currentIndexArray.count).reversed() {
                    guard currentIndexArray[index] < maxIndexArray - 1 else {
                        currentIndexArray[index] = 0
                        continue
                    }
                    currentIndexArray[index] += 1
                    break
                    
                }
            }
        }
    }
}


