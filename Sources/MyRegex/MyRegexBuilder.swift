//
//  MyRegexBuilder.swift
//  
//
//  Created by Youichi Takatsu on 2023/08/24.
//

public protocol MyRegexComponent {
    func toRegex() -> MyRegex
}

@resultBuilder
public struct MyRegexBuilder {
    static public func buildBlock(_ components: MyRegexComponent...) -> [MyRegexComponent] {
        components
    }
}

extension MyRegex : MyRegexComponent {
    public init(@MyRegexBuilder buildElements: () -> [MyRegexComponent]) {
        let components = buildElements()
        self.init(components)
    }
    
    public init(_ components: [MyRegexComponent]) {
        let concatinated = Concatinate(components: components)
        self = concatinated.toRegex()
    }
    
    public func toRegex() -> MyRegex {
        self
    }
}

struct Concatinate : MyRegexComponent {
    let components: [MyRegexComponent]
    public init(components : [MyRegexComponent]) {
        self.components = components
    }
    
    func toRegex() -> MyRegex {
        if components.count == 0 { return .epsilon }
        if components.count == 1 { return components[0].toRegex() }
        return components.dropLast().reversed().reduce(components.last!.toRegex()) { .concat($1.toRegex(), $0) }
    }
}

extension String : MyRegexComponent {
    public func toRegex() -> MyRegex {
        if self.count == 0 { return .epsilon }
        return self.dropLast().reversed().reduce(.char(self.last!)) { .concat(.char($1), $0) }
    }
}

public struct ZeroOrMore : MyRegexComponent {
    let components: [MyRegexComponent]
    public init(@MyRegexBuilder buildComponents: () -> [MyRegexComponent]) {
        components = buildComponents()
    }
    
    public func toRegex() -> MyRegex {
        .star(Concatinate(components:components).toRegex() )
    }
}

public struct OneOrMore : MyRegexComponent {
    let components: [MyRegexComponent]
    public init(@MyRegexBuilder buildComponents: () -> [MyRegexComponent]) {
        components = buildComponents()
    }
    
    public func toRegex() -> MyRegex {
        let r = Concatinate(components: components).toRegex()
        return .concat(r, .star(r))
    }
}

public struct Optionally : MyRegexComponent {
    let components: [MyRegexComponent]
    public init(@MyRegexBuilder buildComponents: () -> [MyRegexComponent]) {
        components = buildComponents()
    }
    
    public func toRegex() -> MyRegex {
        .or(.epsilon, Concatinate(components: components).toRegex())
    }
}

public struct Repeat : MyRegexComponent {
    let range : ClosedRange<Int>
    let component : MyRegexComponent
    public init(count: Int, @MyRegexBuilder buildComponents: () -> [MyRegexComponent]) {
        self.init(count...count, buildComponents: buildComponents)
    }
    
    public init(_ expression: ClosedRange<Int>, @MyRegexBuilder buildComponents: () -> [MyRegexComponent]) {
        range = expression
        component = Concatinate(components: buildComponents())
    }

    private func repeatConstant(_ component: MyRegexComponent, count: Int) -> MyRegex {
        precondition(count >= 0, "count must be greater than or equal to 0")
        switch count {
        case 0:
            return .epsilon
        case 1:
            return component.toRegex()
        default:
            return repeatElement(component, count: count - 1).reduce(component.toRegex()) { .concat($1.toRegex(), $0) }
        }
    }

    public func toRegex() -> MyRegex {
        return range.reversed().reduce( .empty ) { .or(repeatConstant(component, count: $1), $0) }
    }
}

@resultBuilder
public struct MyAlternationBuilder {
    static public func buildBlock(_ components: MyRegexComponent...) -> [MyRegexComponent] {
        components
    }
}

public struct ChoiceOf : MyRegexComponent {
    let components: [MyRegexComponent]
    public init(@MyAlternationBuilder buildComponents: () -> [MyRegexComponent]) {
        components = buildComponents()
    }
    
    public func toRegex() -> MyRegex {
        components.dropLast().reversed().reduce(components.last!.toRegex()) { .or($1.toRegex(), $0) }
    }
}
