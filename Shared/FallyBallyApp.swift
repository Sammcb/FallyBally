//
//  FallyBallyApp.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/15/21.
//

import SwiftUI
import SwiftData

@main
struct FallyBallyApp: App {
	let container: ModelContainer
	
	var body: some Scene {
		WindowGroup {
				GameView()
		}
		.modelContainer(container)
	}
	
	init() {
		let schema = Schema(versionedSchema: SchemaV1_0_0.self)
		let modelConfiguration = ModelConfiguration(schema: schema)
		do {
			container = try ModelContainer(for: schema, migrationPlan: MigrationPlan.self, configurations: modelConfiguration)
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}
}
