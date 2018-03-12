import Foundation

//********************************************************************************
//
// This source is Copyright (c) 2013 by Solinst Canada.  All rights reserved.
//
//********************************************************************************
/**
    String and character extensions to make common manipulations such as array
    indexing and conversions from C characters to unicode characters simpler.
 
    - Author:   Michael Griebling
    - Date:   22 June 2014
     
******************************************************************************** */

public extension String {
    
    //********************************************************************************
    /**
        Implements a subscript which returns the character as the *n*th position of
        the string.
     
        - Author:   Michael Griebling
        - Date:       2 April 2013
     
     ******************************************************************************** */
    public subscript (n: Int) -> Character {
        get {
            //let s = advance(self.startIndex, n)
            let s = self.index(self.startIndex, offsetBy: n)
            if s < self.endIndex {
                return self[s]
            }
            return "\0"
        }
        set {
            let s = self.index(self.startIndex, offsetBy: n)
            if s < self.endIndex {
                let str = self[index(after: s)...]
                self = self[...s] + "\(newValue)" + str
            }
        }
    }
    
    //********************************************************************************
    /**
        Returns the number of characters in the active string.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
     
     ******************************************************************************** */
    public var count : Int { return self.unicodeScalars.count }
    
    //********************************************************************************
    /**
        Returns the string formed from the active string by trimming all the trailing
        characters in the *characterSet*.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
     
     ******************************************************************************** */
    public func stringByTrimmingTrailingCharactersInSet (_ characterSet: CharacterSet) -> String {
        if let rangeOfLastWantedCharacter = self.rangeOfCharacter(from: characterSet.inverted, options:.backwards) {
            return String(self[...rangeOfLastWantedCharacter.upperBound])
        }
        return ""
    }
    
    //********************************************************************************
    /**
        Returns the substring starting at the *from* character and extending for
        *length* characters in the active string.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
     
     ******************************************************************************** */
    public func substring (_ from: Int, _ length: Int) -> String {
        let str = self as NSString
        return str.substring(with: NSMakeRange(from, length))
    }
    
    //********************************************************************************
    /**
        Returns the active string with trailing and leading white space removed.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
     
     ******************************************************************************** */
    public func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    //********************************************************************************
    /**
        Returns the double-precision number formed from the active string.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
     
     ******************************************************************************** */
    public func toDouble() -> Double {
        if let decimalAsDoubleUnwrapped = Double(self) {
            return decimalAsDoubleUnwrapped
        }
        return 0.0
    }
    
}

public extension Character {

    //********************************************************************************
    /**
        Returns the unicode integer equivalent for the active character.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
     
     ******************************************************************************** */
    public var unicodeValue : Int { return Int(unicodeScalar.value) }
    public var unicodeScalar : UnicodeScalar { return String(self).unicodeScalars.first ?? "\0" }
    
    //********************************************************************************
    /**
        Returns *true* if the active character is a valid unicode letter.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
     
     ******************************************************************************** */
    public func isLetter() -> Bool { return CharacterSet.letters.contains(self.unicodeScalar) }
    public func isAscii() -> Bool { return self.unicodeScalar.isASCII }
    public func isUppercase() -> Bool {
        let cSet = CharacterSet.uppercaseLetters
        return cSet.contains(self.unicodeScalar)
    }
    
    //********************************************************************************
    /**
        Returns *true* if the active character is a valid unicode letter or number.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
     
     ******************************************************************************** */
    public func isAlphanumeric() -> Bool { return CharacterSet.alphanumerics.contains(self.unicodeScalar) }
    
    //********************************************************************************
    /**
        Returns the lowercase version of *self*.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
     
     ******************************************************************************** */
    public var lowercase : Character {
        let s = String(self).lowercased(with: Locale.current)
        return s.first ?? self
    }
    
    //********************************************************************************
    /**
        Initializes a *Character* from the unicode scalar integer value.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
     
     ******************************************************************************** */
    public init(_ int: Int) { self = String(describing: UnicodeScalar(int)!).first! }
    
    //********************************************************************************
    /**
        Increments the unicode value of the active character by *n* and returns the
        new unicode *Character*.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
     
     ******************************************************************************** */
    public func add (_ n: Int) -> Character { return Character(self.unicodeValue + n) }
    
}

//********************************************************************************
/**
     Returns *true* if the unicode integer value of *r* is equal to *l*.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
 
 ******************************************************************************** */
public func == (l: Int, r: Character) -> Bool { return l == r.unicodeValue }

//********************************************************************************
/**
     Returns *true* if the unicode integer value of *l* is equal to *r*.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
 
 ******************************************************************************** */
public func == (l: Character, r: Int) -> Bool { return r == l }

//********************************************************************************
/**
     Returns *true* if the unicode integer value of *r* is not equal to *l*.
 
     - Author:   Michael Griebling
     - Date:       2 April 2013
 
 ******************************************************************************** */
public func != (l: Int, r: Character) -> Bool { return l != r.unicodeValue }

//********************************************************************************
/**
     Returns *true* if the unicode integer value of *l* is not equal to *r*.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
 
 ******************************************************************************** */
public func != (l: Character, r: Int) -> Bool { return r != l }

//********************************************************************************
/**
     Increments the unicode value of the character *c* by *inc* and returns the
     new unicode *Character*.
 
     - Author:   Michael Griebling
     - Date:       2 April 2013
 
 ******************************************************************************** */
public func + (c: Character, inc: Int) -> Character { return c.add(inc) }

//********************************************************************************
/**
     Decrements the unicode value of the character *c* by *inc* and returns the
     new unicode *Character*.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
 
 ******************************************************************************** */
public func - (c: Character, inc: Int) -> Character { return c.add(-inc) }

//********************************************************************************
/**
     Decrements the unicode value of the character *c* by *inc* and returns the
     new unicode *Character*.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
 
 ******************************************************************************** */
public func - (c: Character, inc: Character) -> Int { return c.add(-inc.unicodeValue).unicodeValue }

//********************************************************************************
/**
     Increments the unicode value of the character *c* by *inc*.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
 
 ******************************************************************************** */
public func += (c: inout Character, inc: Int) { c = c + inc }

//********************************************************************************
/**
     Decrements the unicode value of the character *c* by *inc*.
     
     - Author:   Michael Griebling
     - Date:       2 April 2013
 
 ******************************************************************************** */
public func -= (c: inout Character, inc: Int) { c = c - inc }




