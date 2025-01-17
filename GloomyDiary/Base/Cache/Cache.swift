//
//  Cache.swift
//  GloomyDiary
//
//  Created by 디해 on 1/14/25.
//

import Foundation

class CacheEntry<Key: Hashable, Value> {
    var key: Key
    var value: Value
    var cost: Int
    var lastAccessTime: TimeInterval
    var prev: CacheEntry?
    var next: CacheEntry?
    
    init(key: Key, value: Value, cost: Int) {
        self.key = key
        self.value = value
        self.cost = cost
        self.lastAccessTime = Date().timeIntervalSince1970
    }
}

class Cache<Key: Hashable, Value> {
    private var _entries = Dictionary<Key, CacheEntry<Key, Value>>()
    private let _lock = NSLock()
    private var _totalCost = 0
    private var _head: CacheEntry<Key, Value>?
    private var _tail: CacheEntry<Key, Value>?
    
    var totalCostLimit: Int = 0
    var countLimit: Int = 0
    
    init() { }
    
    func value(forKey key: Key) -> Value? {
        var value: Value?
        
        _lock.lock()
        if let entry = _entries[key] {
            entry.lastAccessTime = Date().timeIntervalSince1970
            remove(entry)
            insert(entry)
            value = entry.value
        }
        _lock.unlock()
        
        return value
    }
    
    func setValue(_ value: Value, forKey key: Key) {
        setValue(value, forKey: key, cost: 0)
    }
    
    private func remove(_ entry: CacheEntry<Key, Value>) {
        let oldPrev = entry.prev
        let oldNext = entry.next
        
        oldPrev?.next = oldNext
        oldNext?.prev = oldPrev
        
        if entry === _head {
            _head = oldNext
        }
        
        if entry === _tail {
            _tail = oldPrev
        }
    }
    
    private func insert(_ entry: CacheEntry<Key, Value>) {
        guard var currentElement = _head else {
            entry.prev = nil
            entry.next = nil
            
            _head = entry
            _tail = entry
            return
        }
        
        let tailElement = _tail
        tailElement?.next = entry
        entry.prev = tailElement
        _tail = entry
    }
    
    func setValue(_ value: Value, forKey key: Key, cost g: Int) {
        let g = max(g, 0)
        
        _lock.lock()
        
        let costDiff: Int
        
        if let entry = _entries[key] {
            costDiff = g - entry.cost
            entry.cost = g
            entry.value = value
            entry.lastAccessTime = Date().timeIntervalSince1970
            remove(entry)
            insert(entry)
        } else {
            let entry = CacheEntry(key: key, value: value, cost: g)
            _entries[key] = entry
            insert(entry)
            
            costDiff = g
        }
        
        _totalCost += costDiff
        
        var purgeAmount = (totalCostLimit > 0) ? (_totalCost - totalCostLimit) : 0
        while purgeAmount > 0 {
            if let entry = _head {
                if entry.cost == 0 {
                    _head = entry.next
                    continue
                }
                
                _totalCost -= entry.cost
                purgeAmount -= entry.cost
                
                remove(entry)
                _entries[entry.key] = nil
            } else {
                break
            }
        }
        
        var purgeCount = (countLimit > 0) ? (_entries.count - countLimit) : 0
        while purgeCount > 0 {
            if let entry = _head {
                _totalCost -= entry.cost
                purgeCount -= 1
                
                remove(entry)
                _entries[entry.key] = nil
            } else {
                break
            }
        }
        
        _lock.unlock()
    }
    
    func removeValue(forKey key: Key) {
        _lock.lock()
        if let entry = _entries.removeValue(forKey: key) {
            _totalCost -= entry.cost
            remove(entry)
        }
        _lock.unlock()
    }
    
    func removeAllObjects() {
        _lock.lock()
        _entries.removeAll()
        
        while let currentElement = _head {
            let nextElement = currentElement.next
            
            currentElement.prev = nil
            currentElement.next = nil
            
            _head = nextElement
        }
        _tail = nil
        _totalCost = 0
        _lock.unlock()
    }
}
