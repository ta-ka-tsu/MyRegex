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
struct MyRegexBuilder {
    static public func buildBlock(_ components: MyRegexComponent...) -> [MyRegexComponent] {
        components
    }
}

extension MyRegex : MyRegexComponent {
    public init(@MyRegexBuilder buildElements: @escaping () -> [MyRegexComponent]) {
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
    public init(@MyRegexBuilder buildComponents: @escaping () -> [MyRegexComponent]) {
        components = buildComponents()
    }
    
    public func toRegex() -> MyRegex {
        .star(Concatinate(components:components).toRegex() )
    }
}

public struct OneOrMore : MyRegexComponent {
    let components: [MyRegexComponent]
    public init(@MyRegexBuilder buildComponents: @escaping () -> [MyRegexComponent]) {
        components = buildComponents()
    }
    
    public func toRegex() -> MyRegex {
        let r = Concatinate(components: components).toRegex()
        return .concat(r, .star(r))
    }
}

public struct Optionally : MyRegexComponent {
    let components: [MyRegexComponent]
    public init(@MyRegexBuilder buildComponents: @escaping () -> [MyRegexComponent]) {
        components = buildComponents()
    }
    
    public func toRegex() -> MyRegex {
        .or(.epsilon, Concatinate(components: components).toRegex())
    }
}

@resultBuilder
struct MyAlternationBuilder {
    static public func buildBlock(_ components: MyRegexComponent...) -> [MyRegexComponent] {
        components
    }
}

public struct ChoiceOf : MyRegexComponent {
    let components: [MyRegexComponent]
    public init(@MyAlternationBuilder buildComponents: @escaping () -> [MyRegexComponent]) {
        components = buildComponents()
    }
    
    public func toRegex() -> MyRegex {
        components.dropLast().reversed().reduce(components.last!.toRegex()) { .or($1.toRegex(), $0) }
    }
}
