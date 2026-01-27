//
//  SchemaVersioning.swift
//  FallyBally
//
//  Created by Sam McBroom on 8/16/25.
//

import SwiftData

typealias GameData = SchemaV1_0_0.GameData

enum MigrationPlan: SchemaMigrationPlan {
	static var schemas: [VersionedSchema.Type] {
		[SchemaV1_0_0.self]
	}

	static var stages: [MigrationStage] {
		[]
	}
}

enum SchemaV1_0_0: VersionedSchema {
	static var models: [any PersistentModel.Type] {
		[GameData.self]
	}

	static var versionIdentifier: Schema.Version {
		.init(1, 0, 0)
	}
}
