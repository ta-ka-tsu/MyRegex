# MyRegex
Regular expression engine by derivatives.

For presentation at [iOSDC Japan 2023](https://iosdc.jp/2023/).

**This is a sample for theoretical illustration only, not for practical use.**

# Usage

```swift
import MyRegex

let ios : MyRegex = .concat(.char("i"), .concat(.char("O"), .char("S"))) // "iOS"
let ww : MyRegex = .concat(.char("W"), .char("W")) // "WW"
let dc : MyRegex = .concat(.char("D"), .char("C")) // "DC"
let two_or_three : MyRegex = .or(.char("2"), .char("3")) // "2|3"
let twice_two_or_three : MyRegex = .concat(two_or_three, two_or_three) // "(2|3){2}"
let optional_twice_two_or_three : MyRegex = .or(.epsilon, twice_two_or_three) // ((2|3){2})?

// "(iOS|WW)DC((2|3){2}*)?"
let testRegex : MyRegex = .concat(.or(ios, ww), .concat(dc, optional_twice_two_or_three)) 

let result1 = testRegex.wholeMatch(to: "iOSDC")
print(result1) // true
let result2 = testRegex.wholeMatch(to: "WWDC22")
print(result2) // true
let result3 = testRegex.wholeMatch(to: "iOSDC23")
print(result3) // true
```

You can also use "RegexBuilder".

```swift
import MyRegex

// "(iOS|WW)DC((2|3){2})?"
let testRegex = MyRegex {
    ChoiceOf {
        "iOS"
        "WW"
    }
    "DC"
    Optionally {
        Repeat(count: 2) {
            ChoiceOf {
                "2"
                "3"
            }
        }
    }
}
let result1 = testRegex.wholeMatch(to: "iOSDC")
print(result1) // true
let result2 = testRegex.wholeMatch(to: "WWDC22")
print(result2) // true
let result3 = testRegex.wholeMatch(to: "iOSDC23")
print(result3) // true
```

The supported components are as follows
- ZeroOrMore
- OneOrMore
- Optionally
- ChoiceOf
- Repeat

CharacterClass is not supported.
