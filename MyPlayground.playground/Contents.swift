import Foundation

public struct CodableDictionary<Key : Hashable, Value : Codable> : Codable where Key : CodingKey {

    public var decoded: [Key: Value]

    public init(_ decoded: [Key: Value]) {
        self.decoded = decoded
    }

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: Key.self)

        decoded = Dictionary(uniqueKeysWithValues:
            try container.allKeys.lazy.map {
                (key: $0, value: try container.decode(Value.self, forKey: $0))
            }
        )
    }

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: Key.self)

        for (key, value) in decoded {
            try container.encode(value, forKey: key)
        }
    }
}

public struct CodableEnumArray<T: CodableEnumArrayElement>: Codable {
    public var decoded: [T]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: T.CodingKeys.self)
        decoded = try T.CodingKeys.allCases.map { key in
            try T.init(from: container, key: key)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: T.CodingKeys.self)
        try decoded.forEach {
            try $0.encode(to: &container)
        }
    }

    subscript(_ key: T.CodingKeys) -> T {
        get {
            return decoded.first {
                $0.codingKey == key
            }!
        }
        set {
            let index = decoded.enumerated().first {
                $0.element.codingKey == key
            }!.offset
            decoded[index] = newValue
        }
    }
}

public protocol CodableEnumArrayElement {
    associatedtype CodingKeys: CodingKey & CaseIterable & Equatable
    init(from container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) throws
    func encode(to container: inout KeyedEncodingContainer<CodingKeys>) throws
    var codingKey: CodingKeys { get }
}

enum Enum: Hashable, CodableEnumArrayElement {
    case test1(Int?)
    case test2(String?)
    case test3(Bool?)

    enum CodingKeys: String, CodingKey, CaseIterable {
        case test1, test2, test3

        var toEnum: Enum {
            switch self {
            case .test1: return .test1(nil)
            case .test2: return .test2(nil)
            case .test3: return .test3(nil)
            }
        }
    }

    var codingKey: CodingKeys {
        switch self {
        case .test1(_): return .test1
        case .test2(_): return .test2
        case .test3(_): return .test3
        }
    }

    init(from container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) throws {
        switch key {
        case .test1:
            self = .test1(try container.decode(Int.self, forKey: .test1))
        case .test2:
            self = .test2(try container.decode(String.self, forKey: .test2))
        case .test3:
            self = .test3(try container.decode(Bool.self, forKey: .test3))
        }
    }

    func encode(to container: inout KeyedEncodingContainer<Enum.CodingKeys>) throws {
        switch self {
        case .test1(let value):
            try container.encode(value, forKey: .test1)
        case .test2(let value):
            try container.encode(value, forKey: .test2)
        case .test3(let value):
            try container.encode(value, forKey: .test3)
        }
    }
}

struct Struct: Codable {
    var test: CodableEnumArray<Enum>
}

let data = """
{
    "test": {
        "test1": 1,
        "test2": "2",
        "test3": true
    }
}
""".data(using: .utf8)!

var result = try! JSONDecoder().decode(Struct.self, from: data)
"\(result.test.decoded[1])"
let jsonData = try! JSONEncoder().encode(result)
let json = String(data: jsonData, encoding: .utf8)
let oneEnum = Enum.CodingKeys.test1.toEnum
result.test[oneEnum.codingKey] = oneEnum
result.test.decoded[0]
Mirror(reflecting: Enum.test1(10)).children.forEach {
    print($0)
}

let timeString = "2019-11-18T11:04:00Z"
JSONDecoder().dataDecodingStrategy
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
let date = dateFormatter.date(from: timeString)!
dateFormatter.string(from: date)

enum WeekDay: CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

struct Subject {
    var pointsForWeekDay: [WeekDay: Int]
}

var pointsForWeekDay = Dictionary(uniqueKeysWithValues:
    WeekDay.allCases.map { weekDay in
        return (weekDay, 20)
    }
)
var subject = Subject(pointsForWeekDay: pointsForWeekDay)

