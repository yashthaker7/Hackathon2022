//
//  Extension+KeyedDecodingContainer.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 26/05/21.
//

import Foundation

extension KeyedDecodingContainer {
    
    public func decodeReturnDefault(_ type: Int.Type, forKey key: KeyedDecodingContainer<K>.Key) -> Int {
        do {
            return try decodeIfPresent(type, forKey: key) ?? 0
        } catch {
            print(key, error.localizedDescription)
        }
        return 0
    }
    
    public func decodeReturnDefault(_ type: Int64.Type, forKey key: KeyedDecodingContainer<K>.Key) -> Int64 {
        do {
            return try decodeIfPresent(type, forKey: key) ?? 0
        } catch {
            print(key, error.localizedDescription)
        }
        return 0
    }
    
    public func decodeReturnDefault(_ type: String.Type, forKey key: KeyedDecodingContainer<K>.Key) -> String {
        do {
            return try decodeIfPresent(type, forKey: key) ?? ""
        } catch {
            print(key, error.localizedDescription)
        }
        return ""
    }
    
    public func decodeReturnDefault(_ type: [String].Type, forKey key: KeyedDecodingContainer<K>.Key) -> [String] {
        do {
            return try decodeIfPresent(type, forKey: key) ?? []
        } catch {
            print(key, error.localizedDescription)
        }
        return []
    }
    
    public func decodeReturnDefault(_ type: String.Type, forKey key: KeyedDecodingContainer<K>.Key) -> Bool {
        do {
            return try decodeIfPresent(type, forKey: key)?.booleanValue ?? false
        } catch {
            print(key, error.localizedDescription)
        }
        return false
    }
    
    public func decodeReturnDefault(_ type: String.Type, forKey key: KeyedDecodingContainer<K>.Key) -> Double {
        do {
            return Double(try decodeIfPresent(type, forKey: key) ?? "0") ?? 0
        } catch {
            print(key, error.localizedDescription)
        }
        return 0
    }
    
    public func decodeReturnDefault(_ type: String.Type, forKey key: KeyedDecodingContainer<K>.Key) -> Int64 {
        do {
            return Int64(try decodeIfPresent(type, forKey: key) ?? "0") ?? 0
        } catch {
            print(key, error.localizedDescription)
        }
        return 0
    }
    
    public func decodeReturnDefault(_ type: Date.Type, forKey key: KeyedDecodingContainer<K>.Key) -> Date {
        do {
            return try decodeIfPresent(type, forKey: key) ?? Date.zero
        } catch {
            print(key, error.localizedDescription)
        }
        return Date.zero
    }
}
