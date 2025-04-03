//
//  GameData.swift
//  valsrevenge
//
//  Created by Tammy Coron on 7/4/2020.
//  Copyright © 2020 Just Write Code LLC. All rights reserved.
//

import Foundation

class GameData: NSObject, Codable {
    
    // MARK: - Properties
    var level: Int = 1
    
    var keys: Int = 0
    var treasure: Int = 0
    var playerLevel: Int = 1
    var playerExperience: Int = 0
    var playerExperienceToNextLevel: Int = 100
    
    // Set up a shared instance of GameData
    static let shared: GameData = {
        let instance = GameData()
        
        return instance
    }()
    
    // MARK: - Init
    private override init() {}
    
    // MARK: - Save & Load Locally Stored Game Data
    func saveDataWithFileName(_ filename: String) {
        let fullPath = getDocumentsDirectory().appendingPathComponent(filename)
        print("Fullpath: \(fullPath)\nFilename: \(filename)")
        do {
            let data = try PropertyListEncoder().encode(self)
            let dataFile = try NSKeyedArchiver.archivedData(withRootObject: data,
                                                            requiringSecureCoding: true)
            try dataFile.write(to: fullPath)
        } catch {
            print("Couldn't write Store Data file.")
        }
    }
    
    func loadDataWithFileName(_ filename: String) {
        let fullPath = getDocumentsDirectory().appendingPathComponent(filename)
        do { // unarchivedObject(ofClass:from:)
            let contents = try Data(contentsOf: fullPath)
            //if let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(contents) as? Data {
            if let data = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSData.self, from: contents) as? Data {
                let gd = try PropertyListDecoder().decode(GameData.self, from: data)
                print("GameData: \(gd)")
                // Restore data (properties)
                level = gd.level
                
                playerLevel = gd.playerLevel
                playerExperience = gd.playerExperience
                playerExperienceToNextLevel = gd.playerExperienceToNextLevel
                
                keys = gd.keys
                treasure = gd.treasure
                
            }
        } catch {
            print("Couldn't load Store Data file.")
        }
    }
    
    // Get the user's documents directory
    fileprivate func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
