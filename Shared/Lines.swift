//
//  Lines.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/17/21.
//

import SpriteKit

class Lines: SKNode {
	// Number of lines to wrap before trying to spawn lives
	private let lifeSpawnDelay: Int
	private let spawnThreshold: Int
	// Vertical space between lines
	private let verticalDistance: CGFloat
	private var currentLifeSpawnDelay = 0
	var nextLineYCoordinate: CGFloat = 0

	init(initialLifeSpawnDelay: Int, lifeSpawnDelay: Int, spawnThreshold: Int, verticalDistance: CGFloat) {
		self.lifeSpawnDelay = lifeSpawnDelay
		self.currentLifeSpawnDelay = initialLifeSpawnDelay
		self.spawnThreshold = spawnThreshold
		self.verticalDistance = verticalDistance
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
		self.lifeSpawnDelay = 0
		self.spawnThreshold = 0
		self.verticalDistance = 0
		super.init(coder: aDecoder)
	}

	func resetLifeSpawning(initialLifeSpawnDelay: Int) {
		self.currentLifeSpawnDelay = initialLifeSpawnDelay
	}

	func setup(in frame: CGRect, lineSize: CGSize, lifeRadius: CGFloat, lifeFillAlpha: Double) {
		for _ in stride(from: 0, to: frame.height * 1.1, by: verticalDistance) {
			let line = Line(width: lineSize.width, height: lineSize.height)
			let life = Life(radius: lifeRadius, fillAlpha: lifeFillAlpha)
			let lifeVerticalOffset = 3 * line.frame.height
			line.addChild(life)
			life.position = CGPoint(x: line.frame.midX, y: line.frame.maxY + lifeVerticalOffset)
			addChild(line)
		}
	}

	private func position(_ line: Line, in frame: CGRect) {
		line.position = CGPoint(x: CGFloat.random(in: frame.minX...frame.maxX - line.frame.width), y: nextLineYCoordinate)
		nextLineYCoordinate -= verticalDistance
		line.setup()
		trySpawnLife(on: line)
	}

	func positionLines(in frame: CGRect) {
		for child in children {
			guard let line = child as? Line else {
				continue
			}

			position(line, in: frame)
		}
	}

	private func trySpawnLife(on line: Line) {
		guard let life = line.children.first as? Life else {
			return
		}

		guard currentLifeSpawnDelay <= 0 else {
			currentLifeSpawnDelay -= 1
			return
		}

		let spawnChance = Int.random(in: 0...100)
		guard spawnChance >= spawnThreshold else {
			life.collect()
			return
		}

		currentLifeSpawnDelay = lifeSpawnDelay
		life.spawn()
	}

	func wrapLines(in frame: CGRect, at framePosition: CGPoint) {
		for child in children {
			guard let line = child as? Line else {
				continue
			}

			guard line.position.y > framePosition.y + frame.midY + line.frame.height else {
				continue
			}

			position(line, in: frame)
		}
	}

	func paint(ballColor: Ball.Color) {
		for child in children {
			guard let line = child as? Line else {
				continue
			}

			line.paint(ballColor: ballColor)
		}
	}
}
