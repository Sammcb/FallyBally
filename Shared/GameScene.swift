//
//  GameScene.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/15/21.
//

import SpriteKit
import SwiftUI

class GameScene: SKScene, @MainActor SKPhysicsContactDelegate {
	var gameData: GameData?

	private static let initialLifeSpawnDelay = 10
	private static let lifeSpawnDelay = 20
	private static let spawnThreshold = 50
	private static let verticalDistance: CGFloat = 70
	private static let ballVerticalOffset: CGFloat = 100
	private static let ballRadius: CGFloat = 10
	private static let lifeRadius: CGFloat = 10
	private static let lifeFillAlpha: Double = 0.5
	private static let lineWidth: CGFloat = 60
	private static let lineHeight: CGFloat = 4
	private static let minCameraSpeed: CGFloat = 1.5
	private static let maxCameraSpeed: CGFloat = 5
	private static let bonusScore = 100
	private let cameraNode = SKCameraNode()
	private let lines = Lines(initialLifeSpawnDelay: initialLifeSpawnDelay, lifeSpawnDelay: lifeSpawnDelay, spawnThreshold: spawnThreshold, verticalDistance: verticalDistance)
	private let ball = Ball(radius: ballRadius)
	private var cameraSpeedDelta: CGFloat = 0.001
	private var cameraSpeed: CGFloat = 0
	private var animationDuration: TimeInterval = 0

	func paint() {
		ball.paint()
		lines.paint(ballColor: ball.color)
	}

	func setState(_ state: GameData.State) {
		switch state {
		case .menu: setupGame()
		case .playing: isPaused = false
		case .paused: isPaused = true
		case .over: isPaused = true
		}
	}
	
	override func didMove(to view: SKView) {
		view.ignoresSiblingOrder = true
		physicsWorld.contactDelegate = self
		backgroundColor = .clear
		animationDuration = TimeInterval(1 / view.preferredFramesPerSecond)

		cameraSpeedDelta /= CGFloat(view.preferredFramesPerSecond)
		addChild(cameraNode)
		camera = cameraNode

		addChild(ball)
		
		let lineSize = CGSize(width: Self.lineWidth, height: Self.lineHeight)
		lines.setup(in: frame, lineSize: lineSize, lifeRadius: Self.lifeRadius, lifeFillAlpha: Self.lifeFillAlpha)
		addChild(lines)

		setupGame()
		paint()
	}

	func moveBall(left: Bool) {
		guard let ballPhysicsBody = ball.physicsBody, !isPaused else {
			return
		}
		let impulseForce = 2
		ballPhysicsBody.applyImpulse(CGVector(dx: left ? -impulseForce : impulseForce, dy: 0))
	}

	private func ballCollision(lifeNode: Life) {
		guard let gameData else {
			return
		}

		lifeNode.collect()

		guard ball.color == .purple else {
			ball.oneUp()
			gameData.ballColor = ball.color
			lines.paint(ballColor: ball.color)
			return
		}

		gameData.currentGame.score += Self.bonusScore
	}

	private func ballCollision(lineNode: Line) {
		guard let gameData else {
			return
		}

		guard !lineNode.scored else {
			return
		}

		lineNode.score(ball.fillColor)
		gameData.currentGame.score += ball.color.rawValue
	}

	private func testBallCollision(nodeA: SKNode, nodeB: SKNode) {
		guard nodeA as? Ball != nil else {
			return
		}

		if let lifeNode = nodeB as? Life {
			ballCollision(lifeNode: lifeNode)
			return
		}

		if let lineNode = nodeB as? Line {
			ballCollision(lineNode: lineNode)
			return
		}
	}

	func didBegin(_ contact: SKPhysicsContact) {
		guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else {
			return
		}

		testBallCollision(nodeA: nodeA, nodeB: nodeB)
		testBallCollision(nodeA: nodeB, nodeB: nodeA)
	}

	private func resetBall() {
		ball.position = cameraNode.position.applying(CGAffineTransform(translationX: 0, y: Self.ballVerticalOffset))

		guard let ballPhysicsBody = ball.physicsBody else {
			return
		}

		ballPhysicsBody.velocity = .zero
	}

	func setupGame() {
		guard let gameData else {
			return
		}

		// Reset camera
		cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
		cameraSpeed = Self.minCameraSpeed

		resetBall()

		// Reset lines
		lines.nextLineYCoordinate = frame.midY
		lines.positionLines(in: frame)

		gameData.currentGame.score = 0
		isPaused = true
	}

	private func updateCamera() {
		let cameraMoveAction = SKAction.moveTo(y: cameraNode.position.y - cameraSpeed, duration: animationDuration)
		cameraNode.run(cameraMoveAction)
		lines.wrapLines(in: frame, at: cameraNode.position)
		guard cameraSpeed < Self.maxCameraSpeed else {
			return
		}
		cameraSpeed += cameraSpeedDelta
	}

	override func update(_ currentTime: TimeInterval) {
		guard let gameData else {
			return
		}

		updateCamera()

		// Exit if ball is still on screen
		if cameraNode.contains(ball) {
			return
		}

		// Lose life if multiple lives
		guard ball.color == .red else {
			ball.die()
			paint()
			resetBall()
			gameData.ballColor = ball.color
			return
		}

		// Game over if no lives left
		gameData.state = .over
	}
}
