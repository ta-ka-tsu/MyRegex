import XCTest
@testable import MyRegex

final class TestTests: XCTestCase {
    func testMatch() throws {
        let ab : MyRegex = .concat(.char("a"), .char("b")) // ab
        XCTAssertFalse(ab.wholeMatch(in: ""))
        XCTAssertTrue( ab.wholeMatch(in: "ab") )
        XCTAssertFalse( ab.wholeMatch(in: "a") )
        XCTAssertFalse( ab.wholeMatch(in: "ba") )
        
        let ba : MyRegex = .concat( .char("b"), .char("a")) // ba
        XCTAssertFalse(ba.wholeMatch(in: ""))
        XCTAssertTrue( ba.wholeMatch(in: "ba") )
        XCTAssertFalse( ba.wholeMatch(in: "b") )
        XCTAssertFalse( ba.wholeMatch(in: "ab") )
        
        let ab_or_ba : MyRegex = .or(ab, ba) // ab|ba
        XCTAssertFalse(ab_or_ba.wholeMatch(in: ""))
        XCTAssertTrue(ab_or_ba.wholeMatch(in: "ab"))
        XCTAssertTrue(ab_or_ba.wholeMatch(in: "ba"))
        XCTAssertFalse(ab_or_ba.wholeMatch(in: "aa"))
        XCTAssertFalse(ab_or_ba.wholeMatch(in: "bb"))
        
        let repeat_ab_or_ba : MyRegex = .star(ab_or_ba) // (ab|ba)*
        XCTAssertTrue(repeat_ab_or_ba.wholeMatch(in: ""))
        XCTAssertFalse(repeat_ab_or_ba.wholeMatch(in: "a"))
        XCTAssertFalse(repeat_ab_or_ba.wholeMatch(in: "b"))
        XCTAssertTrue(repeat_ab_or_ba.wholeMatch(in: "ab"))
        XCTAssertTrue(repeat_ab_or_ba.wholeMatch(in: "ba"))
        XCTAssertTrue(repeat_ab_or_ba.wholeMatch(in: "abab"))
        XCTAssertTrue(repeat_ab_or_ba.wholeMatch(in: "abba"))
        XCTAssertTrue(repeat_ab_or_ba.wholeMatch(in: "baab"))
        XCTAssertTrue(repeat_ab_or_ba.wholeMatch(in: "baba"))
        XCTAssertFalse(repeat_ab_or_ba.wholeMatch(in: "aaaa"))
        XCTAssertFalse(repeat_ab_or_ba.wholeMatch(in: "bbbb"))
        
        let c_repeat_ab_or_ba : MyRegex = .concat(.char("c"), repeat_ab_or_ba) // c(ab|ba)*
        XCTAssertTrue(c_repeat_ab_or_ba.wholeMatch(in: "c"))
        XCTAssertFalse(c_repeat_ab_or_ba.wholeMatch(in: "a"))
        XCTAssertFalse(c_repeat_ab_or_ba.wholeMatch(in: "b"))
        XCTAssertFalse(c_repeat_ab_or_ba.wholeMatch(in: "ab"))
        XCTAssertFalse(c_repeat_ab_or_ba.wholeMatch(in: "bc"))
        XCTAssertFalse(c_repeat_ab_or_ba.wholeMatch(in: "ca"))
        XCTAssertTrue(c_repeat_ab_or_ba.wholeMatch(in: "cab"))

        let jojo : MyRegex = .star(.concat(.char("オ"), .char("ラ")))
        debug(jojo)
        XCTAssertTrue(jojo.wholeMatch(in: "オラオラオラオラオラオラオラオラ"))
    }
    
    func testOperator() throws {
        let a : MyRegex = .char("a")
        let b : MyRegex = .char("b")
        let c : MyRegex = .char("c")
        let ab_or_c : MyRegex = .or(.concat(a,b), .star(c))
        XCTAssertTrue(ab_or_c.wholeMatch(in: "ab"))
        XCTAssertFalse(ab_or_c.wholeMatch(in: "ac"))
        XCTAssertTrue(ab_or_c.wholeMatch(in: "c"))
        XCTAssertTrue(ab_or_c.wholeMatch(in: "ccc"))
        
        let a_b_star : MyRegex = .concat(a, .star(b))
        XCTAssertTrue(a_b_star.wholeMatch(in: "ab"))
        XCTAssertTrue(a_b_star.wholeMatch(in: "abb"))
        XCTAssertFalse(a_b_star.wholeMatch(in: "abab"))
    }
    func testBuilder() throws {
        let r1 = MyRegex {
            "iOS"
            Optionally {
                "DC"
            }
        }
        
        XCTAssertTrue(r1.wholeMatch(in: "iOS"))
        XCTAssertTrue(r1.wholeMatch(in: "iOSDC"))
        XCTAssertFalse(r1.wholeMatch(in: "WWDC"))
        XCTAssertFalse(r1.wholeMatch(in: "iOSDCDC"))
    }
}
