    import XCTest
    @testable import BinaryCodable

    final class BinaryCodableTests: XCTestCase {
        
        func testExample() {
            let data = "{\"test\": true}".data(using: .utf8)
            let decoder = JSONDecoder()
            
            struct Test: Decodable {
                
                var test: Bool
                
                enum CodingKeys: CodingKey {
                    case test
                }
                
                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    test = try container.decode(Bool.self, forKey: .test)
                }
                
            }
            
            let test = try! decoder.decode(Test.self, from: data!)
            
        }
        
    }
