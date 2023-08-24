import XCTest
@testable import MyRegex

final class TestTests: XCTestCase {
    func testMatch() throws {
        let ab : MyRegex = .concat(.char("a"), .char("b")) // ab
        XCTAssertFalse(ab.wholeMatch(to: ""))
        XCTAssertTrue(ab.wholeMatch(to: "ab"))
        XCTAssertFalse(ab.wholeMatch(to: "a"))
        XCTAssertFalse(ab.wholeMatch(to: "ba"))
        
        let ba : MyRegex = .concat( .char("b"), .char("a")) // ba
        XCTAssertFalse(ba.wholeMatch(to: ""))
        XCTAssertTrue(ba.wholeMatch(to: "ba"))
        XCTAssertFalse(ba.wholeMatch(to: "b"))
        XCTAssertFalse(ba.wholeMatch(to: "ab"))
        
        let ab_or_ba : MyRegex = .or(ab, ba) // ab|ba
        XCTAssertFalse(ab_or_ba.wholeMatch(to: ""))
        XCTAssertTrue(ab_or_ba.wholeMatch(to: "ab"))
        XCTAssertTrue(ab_or_ba.wholeMatch(to: "ba"))
        XCTAssertFalse(ab_or_ba.wholeMatch(to: "aa"))
        XCTAssertFalse(ab_or_ba.wholeMatch(to: "bb"))
        
        let repeat_ab_or_ba : MyRegex = .star(ab_or_ba) // (ab|ba)*
        XCTAssertTrue(repeat_ab_or_ba.wholeMatch(to: ""))
        XCTAssertFalse(repeat_ab_or_ba.wholeMatch(to: "a"))
        XCTAssertFalse(repeat_ab_or_ba.wholeMatch(to: "b"))
        XCTAssertTrue(repeat_ab_or_ba.wholeMatch(to: "ab"))
        XCTAssertTrue(repeat_ab_or_ba.wholeMatch(to: "ba"))
        XCTAssertTrue(repeat_ab_or_ba.wholeMatch(to: "abab"))
        XCTAssertTrue(repeat_ab_or_ba.wholeMatch(to: "abba"))
        XCTAssertTrue(repeat_ab_or_ba.wholeMatch(to: "baab"))
        XCTAssertTrue(repeat_ab_or_ba.wholeMatch(to: "baba"))
        XCTAssertFalse(repeat_ab_or_ba.wholeMatch(to: "aaaa"))
        XCTAssertFalse(repeat_ab_or_ba.wholeMatch(to: "bbbb"))
        
        let c_repeat_ab_or_ba : MyRegex = .concat(.char("c"), repeat_ab_or_ba) // c(ab|ba)*
        XCTAssertTrue(c_repeat_ab_or_ba.wholeMatch(to: "c"))
        XCTAssertFalse(c_repeat_ab_or_ba.wholeMatch(to: "a"))
        XCTAssertFalse(c_repeat_ab_or_ba.wholeMatch(to: "b"))
        XCTAssertFalse(c_repeat_ab_or_ba.wholeMatch(to: "ab"))
        XCTAssertFalse(c_repeat_ab_or_ba.wholeMatch(to: "bc"))
        XCTAssertFalse(c_repeat_ab_or_ba.wholeMatch(to: "ca"))
        XCTAssertTrue(c_repeat_ab_or_ba.wholeMatch(to: "cab"))

        let jojo : MyRegex = .star(.concat(.char("オ"), .char("ラ"))) // (オラ)*
        XCTAssertTrue(jojo.wholeMatch(to: "オラオラオラオラオラオラオラオラ"))
    }
    
    func testRecursive() throws {
        let epsilon : MyRegex = .epsilon
        let a : MyRegex = .char("a")
        let a_or_epsilon : MyRegex = .or(epsilon, a)
        let a_or_epsilon_repeat : MyRegex = .star(a_or_epsilon)
        
        XCTAssertTrue(a_or_epsilon_repeat.wholeMatch(to:"a"))
        XCTAssertTrue(a_or_epsilon_repeat.wholeMatch(to:"aa"))
        XCTAssertTrue(a_or_epsilon_repeat.wholeMatch(to:"aaa"))
        XCTAssertFalse(a_or_epsilon_repeat.wholeMatch(to: "b"))
        XCTAssertFalse(a_or_epsilon_repeat.wholeMatch(to: "bb"))
        XCTAssertFalse(a_or_epsilon_repeat.wholeMatch(to: "bbb"))
    }
    
    func testOperator() throws {
        let a : MyRegex = .char("a")
        let b : MyRegex = .char("b")
        let c : MyRegex = .char("c")
        let ab_or_c : MyRegex = .or(.concat(a,b), .star(c))
        XCTAssertTrue(ab_or_c.wholeMatch(to: "ab"))
        XCTAssertFalse(ab_or_c.wholeMatch(to: "ac"))
        XCTAssertTrue(ab_or_c.wholeMatch(to: "c"))
        XCTAssertTrue(ab_or_c.wholeMatch(to: "ccc"))
        
        let a_b_star : MyRegex = .concat(a, .star(b))
        XCTAssertTrue(a_b_star.wholeMatch(to: "ab"))
        XCTAssertTrue(a_b_star.wholeMatch(to: "abb"))
        XCTAssertFalse(a_b_star.wholeMatch(to: "abab"))
    }
    
    func testBuilderExpression() throws {
        // text
        let r = MyRegex {
            "iOSDC"
        }
        XCTAssertTrue(r.wholeMatch(to: "iOSDC"))
        XCTAssertFalse(r.wholeMatch(to: ""))
    }
    
    func testBuilderBlock() throws {
        let r = MyRegex {
            "iOS"
            "DC"
        }
        XCTAssertTrue(r.wholeMatch(to: "iOSDC"))
        XCTAssertFalse(r.wholeMatch(to: "iOS"))
        XCTAssertFalse(r.wholeMatch(to: "DC"))
    }
    
    func testBuilderChoiceOf() throws {
        let r = MyRegex {
            ChoiceOf {
                "iOSDC"
                "WWDC"
            }
        }
        
        XCTAssertTrue(r.wholeMatch(to: "iOSDC"))
        XCTAssertTrue(r.wholeMatch(to: "WWDC"))
        XCTAssertFalse(r.wholeMatch(to: "iOSDCWWDC"))
    }
    
    func testBuilderZeroOrMore() throws {
        let r = MyRegex {
            ZeroOrMore {
                "w"
            }
        }
        
        XCTAssertTrue(r.wholeMatch(to: ""))
        XCTAssertTrue(r.wholeMatch(to: "w"))
        XCTAssertTrue(r.wholeMatch(to: "ww"))
        XCTAssertTrue(r.wholeMatch(to: "wwwwwwwwww"))
    }
    
    func testBuilderOneOrMore() throws {
        let r = MyRegex {
            OneOrMore {
                "w"
            }
        }
        
        XCTAssertFalse(r.wholeMatch(to: ""))
        XCTAssertTrue(r.wholeMatch(to: "w"))
        XCTAssertTrue(r.wholeMatch(to: "ww"))
        XCTAssertTrue(r.wholeMatch(to: "wwwwwwwwww"))
    }
    
    func testBuilderRepeatCount() throws {
        let r = MyRegex {
            Repeat(count: 3) {
                "w"
            }
        }
        XCTAssertFalse(r.wholeMatch(to: ""))
        XCTAssertFalse(r.wholeMatch(to: "w"))
        XCTAssertFalse(r.wholeMatch(to: "ww"))
        XCTAssertTrue(r.wholeMatch(to: "www"))
        XCTAssertFalse(r.wholeMatch(to: "wwww"))
        XCTAssertFalse(r.wholeMatch(to: "wwwww"))
    }
    
    func testBuilderRepeatRange() throws {
        let r = MyRegex {
            Repeat(2...4) {
                "w"
            }
        }
        XCTAssertFalse(r.wholeMatch(to: ""))
        XCTAssertFalse(r.wholeMatch(to: "w"))
        XCTAssertTrue(r.wholeMatch(to: "ww"))
        XCTAssertTrue(r.wholeMatch(to: "www"))
        XCTAssertTrue(r.wholeMatch(to: "wwww"))
        XCTAssertFalse(r.wholeMatch(to: "wwwww"))
    }
}
