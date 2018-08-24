//
//  TurkishWord.swift
//  Eng-Turkey Dictionary
//
//  Created by quoccuong on 7/27/18.
//  Copyright © 2018 quoccuong. All rights reserved.
//

import Foundation

class Word {
    var index: Int32       = 0
    var language: Int      = 2
    var word: String       = ""
    var latinWord: String  = ""
    var definition: String = ""
    
    init(index: Int32, language: Int32, word: UnsafePointer<UInt8>, latinWord: UnsafePointer<UInt8>, definition: UnsafePointer<UInt8>) {
        let index      = index
        let language   = Int(language)
        let word       = String(cString: word)
        let latinWord  = String(cString: latinWord)
        let definition = String(cString: definition)
        
        self.index      = index
        self.language   = language
        self.word       = word
        self.latinWord  = latinWord
        self.definition = definition
    }
    
    var category: String? {
        if language == 2 {
            return "English"
        } else {
            return "Turkish"
        }
    }
    var definitionString: String? {
        return definition.htmlToString
    }
}
