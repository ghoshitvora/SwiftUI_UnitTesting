//
//  HomeModel.swift
//  SwiftUI_TestCase
//
//  Created by Ghoshit.
//

import Foundation

struct HomeModel: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let email: String
}
