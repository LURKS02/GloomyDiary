//
//  CacheTests.swift
//  GloomyDiaryTests
//
//  Created by 디해 on 1/14/25.
//

import XCTest
@testable import GloomyDiary

final class CacheTests: XCTestCase {
    func test_캐시_등록_조회() throws {
        let cache = Cache<String, String>()
        
        cache.setValue("value1", forKey: "key1")
        cache.setValue("value2", forKey: "key2")
        cache.setValue("value3", forKey: "key3")
        
        XCTAssertEqual(cache.value(forKey: "key1"), "value1")
        XCTAssertEqual(cache.value(forKey: "key2"), "value2")
        XCTAssertEqual(cache.value(forKey: "key3"), "value3")
        XCTAssertEqual(cache.value(forKey: "key4"), nil)
    }
    
    func test_캐시_비용제한_초과() throws {
        let cache = Cache<String, String>()
        
        cache.totalCostLimit = 10
        
        cache.setValue("value1", forKey: "key1", cost: 5)
        cache.setValue("value2", forKey: "key2", cost: 6)
        
        XCTAssertNil(cache.value(forKey: "key1"), "비용 제한 초과로 key1이 제거됩니다.")
        XCTAssertEqual(cache.value(forKey: "key2"), "value2")
    }
    
    func test_캐시_비용제한_초과시_비용이_0인_항목을_제외하고_제거() throws {
        let cache = Cache<String, String>()
        cache.totalCostLimit = 10
        
        cache.setValue("value1", forKey: "key1", cost: 0)
        cache.setValue("value2", forKey: "key2", cost: 5)
        cache.setValue("value3", forKey: "key3", cost: 6)
        
        XCTAssertNil(cache.value(forKey: "key2"), "cost가 0이 아닌 key2는 제거됩니다.")
        XCTAssertEqual(cache.value(forKey: "key1"), "value1", "key1은 cost가 0이므로 제거되지 않습니다.")
        XCTAssertEqual(cache.value(forKey: "key3"), "value3")
    }

    func test_캐시_항목개수제한_초과() throws {
        let cache = Cache<String, String>()
        cache.countLimit = 2
        
        cache.setValue("value1", forKey: "key1")
        cache.setValue("value2", forKey: "key2")
        cache.setValue("value3", forKey: "key3")
        
        XCTAssertNil(cache.value(forKey: "key1"), "개수 제한 초과로 key1이 제거됩니다.")
        XCTAssertEqual(cache.value(forKey: "key2"), "value2")
        XCTAssertEqual(cache.value(forKey: "key3"), "value3")
    }
    
    func test_최근_사용시간_갱신() throws {
        let cache = Cache<String, String>()
        cache.countLimit = 2
        
        cache.setValue("value1", forKey: "key1")
        cache.setValue("value2", forKey: "key2")
        
        XCTAssertEqual(cache.value(forKey: "key1"), "value1")
        
        cache.setValue("value3", forKey: "key3")
        
        XCTAssertNil(cache.value(forKey: "key2"), "LRU로 인해 key2가 제거됩니다.")
        XCTAssertEqual(cache.value(forKey: "key1"), "value1")
        XCTAssertEqual(cache.value(forKey: "key3"), "value3")
    }
    
    func test_특정_키_삭제() throws {
        let cache = Cache<String, String>()
        cache.setValue("value1", forKey: "key1")
        cache.setValue("value2", forKey: "key2")
        
        cache.removeValue(forKey: "key1")
        
        XCTAssertNil(cache.value(forKey: "key1"), "key1이 캐시에서 삭제되었습니다.")
        XCTAssertEqual(cache.value(forKey: "key2"), "value2")
    }
    
    func test_모든_키_삭제() throws {
        let cache = Cache<String, String>()
        cache.setValue("value1", forKey: "key1")
        cache.setValue("value2", forKey: "key2")
        
        cache.removeAllObjects()
        
        XCTAssertNil(cache.value(forKey: "key1"), "key1이 캐시에서 삭제되었습니다.")
        XCTAssertNil(cache.value(forKey: "key2"), "key2가 캐시에서 삭제되었습니다.")
    }
}
