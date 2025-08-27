//
//  AppModel.swift
//  FireLab
//
//  Created by YIHAN  on 27/8/2025.
//

import SwiftUI
import Combine

final class AppModel: ObservableObject {
    @Published var inputs = FireInputs()
    @Published var portfolio = PortfolioModel()
    
    //for FIRE calculations

}
