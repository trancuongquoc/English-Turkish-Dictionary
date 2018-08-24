//
//  SQLiteHelper.swift
//  Eng-Turkey Dictionary
//
//  Created by quoccuong on 7/26/18.
//  Copyright © 2018 quoccuong. All rights reserved.
//

import Foundation
import SQLite3

class SQLiteHelper {
    static let shared: SQLiteHelper = SQLiteHelper()
    
    var wordsPackage = [Word]()
    
    var db: OpaquePointer? {
        get {
            return openDatabase(filePath: url)
        }
    }
    
    var words = [String]()
    let url = Bundle.main.url(forResource: "engturkdict", withExtension: "sqlite")!
    
    func openDatabase(filePath: URL) -> OpaquePointer? {
        
        var db: OpaquePointer? = nil
                
        
        if sqlite3_open(url.path, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(url)")
            return db
        } else {
            print("Unable to open database. Verify that you created the directory described " +
                "in the Getting Started section.")
            return nil
        }
        
    }
    
    func query(matchWord: String, lastValue: Int32) {
        var queryStatement: OpaquePointer? = nil
        let queryStatementString = """
        SELECT * FROM ZWORD
        WHERE ZWORD LIKE '%\(matchWord.lowercased())%'
        AND Z_PK > ?
        ORDER BY Z_PK
        limit 15 ;
        """
        wordsPackage = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, lastValue)
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                
                let zpk = sqlite3_column_int(queryStatement, 0)
                let zlang = sqlite3_column_int(queryStatement, 3)
                let zdefinition = sqlite3_column_text(queryStatement, 4)
                let zlatin = sqlite3_column_text(queryStatement, 5)
                let zword = sqlite3_column_text(queryStatement, 6)
                
                let wordData = Word(index: zpk, language: zlang, word: zword!, latinWord: zlatin!, definition: zdefinition!)
                wordsPackage.append(wordData)
            }
        } else {
            print("SELECT statement could not be prepared")
        sqlite3_reset(db)
        sqlite3_finalize(queryStatement)
        close()
    }
}
    
    func close() {
        sqlite3_close(db)
        }
    }

