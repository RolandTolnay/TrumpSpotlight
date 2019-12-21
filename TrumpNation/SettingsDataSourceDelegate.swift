//
//  SettingsDataSourceDelegate.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 23/05/2017.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

protocol SettingsDataSourceDelegate {
   
   func didUpdateContent(of dataSource: SettingsMenuDataSource)
   
   func dataSource(_ dataSource: SettingsMenuDataSource, isLoading: Bool)
}
