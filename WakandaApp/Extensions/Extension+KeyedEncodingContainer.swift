//
//  Extension+KeyedEncodingContainer.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 23/06/21.
//

import Foundation

extension KeyedEncodingContainer {
    
    public mutating func encode(_ value: Date, dateFormatter: DateFormatter, forKey key: KeyedEncodingContainer<K>.Key) throws {
        do {
            try encode(value == Date.zero ? nil : value.asString(dateFormatter: dateFormatter), forKey: key)
        } catch {
            print(key, error.localizedDescription)
        }
    }

    public mutating func encode(_ value: Bool, forKey key: KeyedEncodingContainer<K>.Key) throws {
        do {
            try encode(value.characterValue, forKey: key)
        } catch {
            print(key, error.localizedDescription)
        }
    }
    
    public mutating func encode(_ value: Double, forKey key: KeyedEncodingContainer<K>.Key) throws {
        do {
            try encode("\(value)", forKey: key)
        } catch {
            print(key, error.localizedDescription)
        }
    }
    
    public mutating func encodeNullIfEmpty(_ value: String, forKey key: KeyedEncodingContainer<K>.Key) throws {
        do {
            try encode(value.isEmpty ? nil : value, forKey: key)
        } catch {
            print(key, error.localizedDescription)
        }
    }
    
    public mutating func encodeNullIfZero(_ value: Int64, forKey key: KeyedEncodingContainer<K>.Key) throws {
        do {
            try encode(value != 0 ? value: nil, forKey: key)
        } catch {
            print(key, error.localizedDescription)
        }
    }
    
    public mutating func encode(_ value: [String], forKey key: KeyedEncodingContainer<K>.Key) throws {
        do {
            try encode(value.count != 0 ? value : nil, forKey: key)
        } catch {
            print(key, error.localizedDescription)
        }
    }
}
