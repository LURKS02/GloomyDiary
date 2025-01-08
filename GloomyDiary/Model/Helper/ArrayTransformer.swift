//
//  ArrayTransformer.swift
//  GloomyDiary
//
//  Created by 디해 on 1/9/25.
//

import Foundation

@objc(ArrayTransformer)
class ArrayTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [String] else {
            return nil
        }
        let nsArray = array as NSArray
        return try? NSKeyedArchiver.archivedData(withRootObject: nsArray, requiringSecureCoding: true)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        guard let nsArrayAny = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSString.self], from: data) else { return nil }
        guard let strings = nsArrayAny as? [String] else { return nil }
        return strings
    }
}

extension ArrayTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: ArrayTransformer.self))
    
    public static func register() {
        let transformer = ArrayTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
