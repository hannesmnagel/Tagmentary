//
//  String+AutoCompletable.swift
//  Tagmentary
//
//  Created by Hannes Nagel on 12/23/24.
//

import Foundation

extension String: AutoCompletable {
    public var autoCompletion: String {self}
}