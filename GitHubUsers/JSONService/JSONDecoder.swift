//
//  JSONDecoder.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 19/12/2022.
//

import Foundation
import CoreData

// MARK: - Extensions for Adding CoreData Capability to JSONDecoder

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}

extension JSONDecoder {
    convenience init(context: NSManagedObjectContext) {
        self.init()
        self.userInfo[.context] = context
    }
}


// MARK: - JSONDecoderService

/// CoreData aware generic JSON decoder.
///
/// This class is a JSONDecoder wrapper that adds CoreData functions to JSON decoding. It's aim is to provide JSON decoding
/// service to other code base where JSON decoding and it's relation with CoreData is a distraction.
class JSONDecoderService<T> where T: Decodable {

    private var context: NSManagedObjectContext
    private var coreDataStack: CoreDataStack

    /// Computed property for a JSONDecoder instance
    ///
    /// This JSONDecoder instance is configured to convert from snake\_case to camelCase.
    private var decoderWithSnakeCaseConvert: JSONDecoder {
        let decoder = JSONDecoder(context: context)
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }

    /// Initializer
    ///
    /// - Parameters:
    ///   - context: The NSManagedObjectContext the decoder operates in.
    ///   - coreDataStack: The CoreData stack class to provide CoreData functions.
    init(context: NSManagedObjectContext, coreDataStack: CoreDataStack) {
        self.context = context
        self.coreDataStack = coreDataStack
    }

    /// Generic JSON decoding method
    ///
    /// This decoder will decode into any CoreData model that is configured during the initialization for this instance
    /// of JSONDecoderService class. The data is saved in CoreData if the decoding is successful.
    /// - Parameters:
    ///   - data: The JSON data to decode.
    /// - Returns: The decoded model instance or nil if decoding or saving to CoreData failed.
    func decode(data: Data) -> T? {
        let decoded: T
        do {
            decoded = try decoderWithSnakeCaseConvert.decode(T.self, from: data)
            coreDataStack.saveContext(context)

        } catch {
            print(String(describing: error))
            return nil
        }

        return decoded
    }
    
}

