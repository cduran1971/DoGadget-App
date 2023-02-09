//
//  DoGadgetApp.swift
//  DoGadget
//
//  Created by Celso Duran on 2/9/23.
//

import SwiftUI

@main
struct DoGadgetApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
