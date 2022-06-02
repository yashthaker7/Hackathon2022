//
//  Extension+FileManager.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 16/06/21.
//

import UIKit

extension FileManager {
    
    var documentDirectory: URL {
        return urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func createURLInDD(_ name: String) -> URL {
        return documentDirectory.appendingPathComponent(name)
    }
    
    func removeFileIfExists(_ fileURL: URL) {
        guard fileExists(atPath: fileURL.path) else { return }
        do {
            try removeItem(at: fileURL)
        } catch {
            print("Could not delete file at \(fileURL)")
        }
    }
    
    func removeImageIfExists(_ imageName: String) {
        var localImageURL = createURLInDD("\(imageName).jpeg")
        if imageName.contains(".jpeg") {
            localImageURL = createURLInDD(imageName)
        }
        removeFileIfExists(localImageURL)
    }
    
    func checkImageExistsInDD(imageName: String) -> Bool {
        var localImageURL = createURLInDD("\(imageName).jpeg")
        if imageName.contains(".jpeg") {
            localImageURL = createURLInDD(imageName)
        }
        return fileExists(atPath: localImageURL.path)
    }
    
    @discardableResult func saveImageInDDIfNotExists(imageName: String, image: UIImage, compressionQuality: CGFloat = 1.0) -> URL? {
        guard let jpegData = image.jpegData(compressionQuality: compressionQuality) else { return nil }

        let localImageURL = createURLInDD("\(imageName).jpeg")

        if fileExists(atPath: localImageURL.path) {
            return localImageURL
        }
        do {
            try jpegData.write(to: localImageURL)
        } catch {
            print("error saving file:", error)
        }
        return localImageURL
    }
    
    func removeAllFilesFromDD() {
        do {
            let files = try self.contentsOfDirectory(atPath: documentDirectory.path)
            for file in files {
                let filePath = URL(fileURLWithPath: documentDirectory.path).appendingPathComponent(file).absoluteURL
                try removeItem(at: filePath)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension URL {
    
    func nameWithoutExtension() -> String {
        return self.deletingPathExtension().lastPathComponent
    }
}
