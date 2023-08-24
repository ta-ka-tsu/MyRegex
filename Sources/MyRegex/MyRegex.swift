public enum MyRegex {
    case char(Character) // アルファベット
    case epsilon // ε
    case empty // ∅
    indirect case concat(MyRegex,MyRegex) // 連接
    indirect case or(MyRegex,MyRegex) // 選択
    indirect case star(MyRegex) // 繰り返し
}

extension MyRegex {
    func matchToEmptyString() -> Bool {
        switch self {
        case .char(_):
            return false
        case .epsilon:
            return true
        case .empty:
            return false
        case .concat(let r1, let r2):
            return r1.matchToEmptyString() && r2.matchToEmptyString()
        case .or(let r1, let r2):
            return r1.matchToEmptyString() || r2.matchToEmptyString()
        case .star(_):
            return true
        }
    }
}

func delta(_ r:MyRegex) -> MyRegex {
    return r.matchToEmptyString() ? .epsilon : .empty
}

extension MyRegex {
    func derivative(with char:Character) -> MyRegex {
        switch self {
        case .char(let c):
            return (char == c) ? .epsilon : .empty
        case .epsilon:
            return .empty
        case .empty:
            return .empty
        case .concat(let r1, let r2):
//            return .or(.concat(r1.derivative(with: char), r2), .concat(delta(r1),  r2.derivative(with: char)))
            return  s_or(s_concat(r1.derivative(with: char), r2), s_concat(delta(r1), r2.derivative(with: char)))
        case .or(let r1, let r2):
//            return .or( r1.derivative(with: char), r2.derivative(with: char))
            return s_or(r1.derivative(with: char), r2.derivative(with: char))
        case .star(let r):
//            return .concat(r.derivative(with: char), .star(r))
            return s_concat(r.derivative(with: char), .star(r))
        }
    }
}

extension MyRegex {
    public func wholeMatch(to string: String) -> Bool {
        return string.reduce( self ) { $0.derivative(with: $1) }.matchToEmptyString()
    }
}

// MARK: - Simplification Functions
extension MyRegex : Equatable {
}

// or
func s_or(_ lhs:MyRegex, _ rhs:MyRegex) -> MyRegex {
    if lhs == rhs {
        return lhs // r|r = r
    }
    if case .empty = lhs {
        return rhs // ∅|r = r
    }
    if case .empty = rhs {
        return lhs // r|∅ = r
    }
    return .or(lhs, rhs)
}

// concatinate
func s_concat(_ lhs:MyRegex, _ rhs:MyRegex) -> MyRegex {
    if case .epsilon = lhs {
        return rhs // εr = r
    }
    if case .empty = lhs {
        return .empty // ∅r = ∅
    }
    if case .epsilon = rhs {
        return lhs // rε = r
    }
    if case .empty = rhs {
        return .empty // r∅ = ∅
    }
    return .concat(lhs, rhs)
}

// MARK: - For Debug Structure of Regex
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
