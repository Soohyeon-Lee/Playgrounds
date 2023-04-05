# AttributedString with Emoji (String과 NSString, 그리고 UnicodeScalar와 UTF16)

문자열에 다양한 textAttributes를 적용하는 과정에서 이모지가 포함된 문자열이 꺠지는 현상이 발생했다.

왜 잘 돌아가던 코드가 이모지만 포함되면 깨지는걸까?

## 문제 발생

textAttributes 적용 범위(Range)를 optional로 받도록 구현했고, 범위 값이 주어지지 않을 경우에는 전체 문자열에 적용되도록 아래와 같이 구성했다.


```swift
var attributedString = NSMutableAttributedString(string: "입력 값")

func foregroundColor(
  value: UIColor, 
  in range: NSRange = NSRange(location: 0, length: attributedString.string.count)
) {
  ...
  attributedString.addAttribute(.foregroundColor, value: value, range: range)
  ...
}
```
이모지가 포함된 경우는 아래와 같이 깨지는 현상이 나타난다.
```swift
var attributedString = NSMutableAttributedString(string: "🐿🐿🐿")
foregroundColor(value: .blue)

textLabel.attributedText = attributedString // Label에 나타난 모습 = 🐿��🐿
```
## 해결

관련 글을 검색해보니 NSRange를 설정할 때, String 기반 count를 쓰면 안된다고 한다?
NSString의 length를 사용하거나 String을 utf16으로 변환 후 count를 호출하라고 한다.
일단 시키는대로 해보니 정상적으로 이모지가 출력되는 것을 확인했다.
```swift
var text = "입력 값"
var attributedString = NSMutableAttributedString(string: text)

// 1. NSString의 length
NSRange(location: 0, length: (text as NSString).length)

// 2. String을 utf16으로 변환
NSRange(location: 0, length: text.utf16.count)

textLabel.attributedText = attributedString // Label에 나타난 모습 = 🐿🐿🐿
```

## 분석

이모지가 없는 텍스트에서는 문제 없던 코드가 왜 작동하지 않았을까?

문자열만으로 구성된 String의 길이를 출력해보았다.
```swift
let text = "Hello"

print(text.count) // 5
print((text as NSString).length) // 5
print(text.utf16.count) // 5
```
차이가 없다.
그렇다면 이모지가 포함되면?
```swift
let text = "Hello🐿"

print(text.count) // 6
print((text as NSString).length) // 7
print(text.utf16.count) // 7

let text = "Hello👨‍👩‍👧‍👧"

print(text.count) // 6
print((text as NSString).length) // 16
print(text.utf16.count) // 16
```
도대체 1은 어디서 온걸까? 그리고 이모지만 바꿨는데 왜 숫자가 또 다르지?

### String과 NSString

String과 NSString은 문자열 데이터가 어떻게 구성되어있을까?

String은 Character의 집합(BidirectionalCollection)으로 count를 호출하면 Character들을 하나씩 순회하며 카운트를 한 후 count 값을 반환한다.

여기서 문제가 되었던 부분은 Character는 다수의 Unicode Scalar(UTF32)가 모인 그룹이라는 것이다.

> A string’s unicodeScalars property is a collection of Unicode scalar values, the 21-bit codes that are the basic unit of Unicode. Each scalar value is represented by a Unicode.Scalar instance and is equivalent to a UTF-32 code unit.
>
> 문자열의 unicodeScalars 속성은 유니코드의 기본 단위인 21비트 코드인 유니코드 스칼라 값 모음입니다. 각 스칼라 값은 유니코드.스칼라 인스턴스로 표시되며 UTF-32 코드 단위와 동일합니다.
>
> Reference. [Apple Document: String](https://developer.apple.com/documentation/swift/string/#Accessing-a-Strings-Unicode-Representation)


어떠한 이모지가 문자열에 존재하더라도 하나의 Character로 읽어들이기 때문에 이모지의 count는 1이 된다.

```swift
let text1 = "🐿"

print(text1.count) // 1

let text2 = "👨‍👩‍👧‍👧"

print(text2.count) // 1
```

하지만 NSString의 인코딩 방식은 UTF16이기 때문에 Unicode Scalar를 UTF16으로 인코딩한 값들로 이루어진 집합이 된다.

> An NSString object encodes a Unicode-compliant text string, represented as a sequence of UTF–16 code units. All lengths, character indexes, and ranges are expressed in terms of 16-bit platform-endian values, with index values starting at 0.
>
> NSString 객체는 UTF-16 코드 단위의 시퀀스로 표시되는 유니코드 호환 텍스트 문자열을 인코딩합니다. 모든 길이, 문자 인덱스 및 범위는 16비트 플랫폼 엔디안 값으로 표현되며, 인덱스 값은 0부터 시작합니다.
>
> Reference. [Apple Document: NSString](https://developer.apple.com/documentation/foundation/nsstring#1666323)

때문에 NSString(UTF16)에서 이모지는 다수의 UnicodeScalar를 UTF16으로 인코딩한 값의 집합을 가지게 된다.
또한 하나의 UnicodeScalar(UTF32)는 UTF16으로 인코딩하기 때문에 1 또는 2의 length를 가지게 된다.

```swift
let text1 = "🐿"

print(text1.unicodeScalars.count) // 1, 하나의 Unicode Scalar로 구성
print(Array(text1.utf16)) // [55,357, 56,383]
print((text1 as NSString).length) // 2
print(text1.utf16.count) // 2

let text2 = "👨‍👩‍👧‍👧"

print(text2.unicodeScalars.count) // 7, 일곱 개의 Unicode Scalar로 구성
print(Array(text2.utf16)) // [55357, 56424, 8205, 55357, 56425, 8205, 55357, 56423, 8205, 55357, 56423]
print((text2 as NSString).length) // 11
print(text2.utf16.count) // 11
```

## 결론

단순히 String과 NSString이 상호호환이 되기 때문에 비슷한 데이터 처리를 할 것이라는 생각을 하고 코드를 짰었고, 이 부분이 문제의 원인이 되었다.

글을 적으며 나름대로 정리하였지만 이 모든 내용은 [Apple Document: String](https://developer.apple.com/documentation/swift/string/#Accessing-a-Strings-Unicode-Representation)의 `Accessing a String’s Unicode Representation` 섹션에 친절한 예시와 함께 잘 설명되어있다. (...)

왜 String은 Random Access가 안되냐고 불평할 시간에 공식 문서와 함께 내부 구조를 차분히 공부해서 활용하는 개발자가 되어야겠다.