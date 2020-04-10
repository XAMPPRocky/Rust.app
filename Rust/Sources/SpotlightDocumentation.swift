//
//  SpotlightDocumentation.swift
//  Rust
//
//  Created by Erin Power on 07/04/2020.
//  Copyright © 2020 Rust. All rights reserved.
//

import Foundation
import CoreSpotlight

class SpotlightDocumentation {
    static func generateDocumentationSpotlight() {
        //let fileManager = FileManager.default

        do {
            let resourceKeys : [URLResourceKey] = [.isDirectoryKey]
            let documentsURL = try! Rustup.documentationDirectory()
            let enumerator = FileManager.default.enumerator(at: documentsURL,
                                    includingPropertiesForKeys: resourceKeys,
                                    options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                print("directoryEnumerator error at \(url): ", error)
                                                                return true
            })!
            
            for case let fileURL as URL in enumerator {
                let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                if resourceValues.isDirectory! {
                    continue
                }
                
                let path = fileURL.absoluteString.dropFirst(documentsURL.absoluteString.count)

                createDocumentationItem(title: String(path))
            }
        } catch {
            print(error)
        }
    }
    
    static func createDocumentationItem(title: String) {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeHTML as String)
        attributeSet.title = title
        //attributeSet.contentDescription = desc

        let item = CSSearchableItem(uniqueIdentifier: "\(title)", domainIdentifier: "com.xampprocky", attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
    }
}
