public enum MyRegex {
    case char(Character)
    case epsilon
    case empty
    indirect case concat(MyRegex,MyRegex)
    indirect case or(MyRegex,MyRegex)
    indirect case star(MyRegex)
}

extension MyRegex {
    func canAcceptEpsilon() -> Bool {
        switch self {
        case .char(_):
            return false
        case .epsilon:
            return true
        case .empty:
            return false
        case .concat(let r1, let r2):
            return r1.canAcceptEpsilon() && r2.canAcceptEpsilon()
        case .or(let r1, let r2):
            return r1.canAcceptEpsilon() || r2.canAcceptEpsilon()
        case .star(_):
            return true
        }
    }
}

extension MyRegex {
    func delta() -> MyRegex {
        return canAcceptEpsilon() ? .epsilon : .empty
    }
}

extension MyRegex {
    func derivative(by char:Character) -> MyRegex {
        switch self {
        case .char(let c):
            return (char == c) ? .epsilon : .empty
        case .epsilon:
            return .empty
        case .empty:
            return .empty
        case .concat(let r1, let r2):
            return  s_or(s_concat(r1.derivative(by: char), r2), s_concat(r1.delta(), r2.derivative(by: char)))
//            return .or(.concat(r1.derivative(by: char), r2), .concat(r1.delta(),  r2.derivative(by: char)))
        case .or(let r1, let r2):
            return s_or(r1.derivative(by: char), r2.derivative(by: char))
//            return .or( r1.derivative(by: char), r2.derivative(by: char))
        case .star(let r):
            return s_concat(r.derivative(by: char), .star(r))
//            return .concat(r.derivative(by: char), .star(r))
        }
    }
}

extension MyRegex {
    func wholeMatch(in string: String) -> Bool {
        var result : MyRegex = self
        for c in string {
            result = result.derivative(by: c)
            debug(result)
        }
        return result.canAcceptEpsilon()
//        return string.reduce( self ) { $0.derivative(by: $1) }.canAcceptEpsilon()
    }
}

func debug(_ r:MyRegex, depth: Int = 0) {
    let tab = repeatElement("  ", count: depth).joined()
    switch r {
    case .char(let a):
        print(tab, "char(\"\(a)\")")
    case .epsilon:
        print(tab, "ε")
    case .empty:
        print(tab, "∅")
    case .concat(let r1, let r2):
        print(tab, "concat")
        debug(r1, depth: depth+1)
        debug(r2, depth: depth+1)
    case .or(let r1, let r2):
        print(tab, "or")
        debug(r1, depth: depth+1)
        debug(r2, depth: depth+1)
    case .star(let r):
        print(tab, "repeat")
        debug(r, depth: depth+1)
    }
}

// MARK: - Simplification Functions
// repeat
func s_star(_ r:MyRegex) -> MyRegex {
    if case .empty = r {
        return .epsilon
    }
    return .star(r)
}

// or
func s_or(_ lhs:MyRegex, _ rhs:MyRegex) -> MyRegex {
    if case .empty = lhs {
        return rhs
    }
    if case .empty = rhs {
        return lhs
    }
    return .or(lhs, rhs)
}

// concatinate
func s_concat(_ lhs:MyRegex, _ rhs:MyRegex) -> MyRegex {
    if case .epsilon = lhs {
        return rhs
    }
    if case .empty = lhs {
        return .empty
    }
    if case .epsilon = rhs {
        return lhs
    }
    if case .empty = rhs {
        return .empty
    }
    return .concat(lhs, rhs)
}

// Builder
public protocol MyRegexComponent {
    func toRegex() -> MyRegex
}

extension MyRegex : MyRegexComponent {
    public init(@MyRegexBuilder buildElements: @escaping () -> MyRegex) {
        self = buildElements()
    }
    
    public func toRegex() -> MyRegex {
        self
    }
}

extension String : MyRegexComponent {
    public func toRegex() -> MyRegex {
        self.reversed().reduce( .epsilon ) { .concat(.char($1), $0) }
    }
}

public struct ZeroOrMore : MyRegexComponent {
    let regex: MyRegex
    public init(@MyRegexBuilder buildComponents: @escaping () -> MyRegex) {
        regex = buildComponents()
    }
    
    public func toRegex() -> MyRegex {
        .star(regex)
    }
}

public struct Optionally : MyRegexComponent {
    let regex: MyRegex
    public init(@MyRegexBuilder buildComponents: @escaping () -> MyRegex) {
        regex = buildComponents()
    }
    
    public func toRegex() -> MyRegex {
        .or(.epsilon, regex)
    }
}

@resultBuilder
struct MyRegexBuilder {
    // この構成だとブロックを連結と決め打ちすることになるからChoiceOfなどが作れないからだめか
    static func buildExpression(_ expression: MyRegexComponent) -> MyRegex {
        expression.toRegex()
    }
    
    static func buildPartialBlock(first: MyRegexComponent) -> MyRegex {
        first.toRegex()
    }
    
    static func buildPartialBlock(accumulated: MyRegexComponent, next: MyRegexComponent) -> MyRegex {
        .concat(accumulated.toRegex(), next.toRegex())
    }
}
