//
//  GameScene.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/15/21.
//

import SpriteKit
import GameKit

class GameScene: SKScene, UIGestureRecognizerDelegate, SKPhysicsContactDelegate {
	// MARK: - Game objects
	let ballOffset: CGFloat = 100
	let ball = Ball(radius: 10)
	let cam = SKCameraNode()
	let lines = Lines()
	let ui = UI()
	
	// MARK: - Score tracking
	var score = 0 {
		didSet {
			guard oldValue != score else {
				return
			}
			ui.scoreLabel.text = "\(score)"
		}
	}
	var highscore = 0 {
		didSet {
			guard oldValue != highscore else {
				return
			}
			ui.highscoreLabel.text = "\(highscore)"
		}
	}
	
	// MARK: - Pausing
	var playing = false
	override var isPaused: Bool {
		didSet {
			guard playing else {
				return
			}

			if isPaused {
				ui.showPause()
				pause()
			}
		}
	}
	
	// MARK: - Camera speed
	// Increase by 1.5 points per frame over the course of 8 minutes
	let camSpeedDelta: CGFloat = 1.5 / (6 * 3600)
	let minCamSpeed: CGFloat = 1.5
	let maxCamSpeed: CGFloat = 3
	var camSpeed: CGFloat = 0
	
	// MARK: - Achievements
	var didUpgrade = false
	var startTime = Date()
	
	// MARK: - Game Center
	let localPlayer = GKLocalPlayer.local
	
	// MARK: - Local save data
	let localStorage = UserDefaults.standard
	
	func authenticateUser() {
		localPlayer.authenticateHandler = { viewController, error in
			guard viewController == nil else {
				return
			}
			
			guard error == nil else {
				return
			}
			
			GKAccessPoint.shared.location = .topLeading
			GKAccessPoint.shared.showHighlights = false
			GKAccessPoint.shared.isActive = !self.ui.playButton.isHidden
			GKLeaderboard.loadLeaderboards(IDs: ["scores"]) { leaderboards, error in
				guard error == nil else {
					return
				}
				
				leaderboards!.first!.loadEntries(for: [self.localPlayer], timeScope: .allTime) { entry, entries, error in
					guard error == nil else {
						return
					}
					
					guard let highscore = entries?.first?.score, highscore > self.highscore else {
						return
					}
					
					self.highscore = highscore
				}
			}
		}
	}
	
	override func didMove(to view: SKView) {
		view.ignoresSiblingOrder = true
		
		physicsWorld.contactDelegate = self
		
		camera = cam
		addChild(cam)
		
		authenticateUser()
		
		didUpgrade = false
		
		ball.zPosition = 1
		ball.ui = ui
		addChild(ball)
		
		lines.bounds = frame
		for _ in stride(from: size.height, to: -ballOffset, by: -lines.distance) {
			let line = Line(width: 60, height: 4)
			let heart = Heart()
			line.addChild(heart)
			heart.position = CGPoint(x: line.frame.midX, y: line.frame.maxY + 15)
			lines.addChild(line)
		}
		addChild(lines)
		
		form()
		
		cam.addChild(ui)
		ui.world = self
		ui.bounds = frame
		ui.paint()
		ui.form()
		NotificationCenter.default.addObserver(ui, selector: #selector(ui.paint), name: NSNotification.Name(rawValue: colorModeKey), object: nil)
		
		pause()
	}
	
	// Detect if a node was tapped
	func pressed(button: Button, at touch: UITouch) -> Bool {
		nodes(at: touch.location(in: self)).contains(button)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if isPaused {
			return
		}
		
		if pressed(button: ui.playButton, at: touches.first!) {
			startTime = Date()
			ui.showPlay()
			resume()
			return
		}
		
		if pressed(button: ui.pauseButton, at: touches.first!) {
			ui.showPause()
			pause()
			return
		}
		
		if pressed(button: ui.resumeButton, at: touches.first!) {
			ui.showPlay()
			resume()
			return
		}

		if pressed(button: ui.restartButton, at: touches.first!) {
			form()
			ui.form()
			return
		}
		
		// Absorbe taps when paused
		guard playing else {
			return
		}
		
		// Move the ball left or right
		ball.physicsBody!.applyImpulse(CGVector(dx: touches.first!.location(in: self).x < frame.midX ? -2 : 2, dy: 0))
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		let otherNode = contact.bodyA.node!.name != "ball" ? contact.bodyA.node! : contact.bodyB.node!
		if let heartNode = otherNode as? Heart {
			if ball.color == .purple {
				let bonus = 100
				score += bonus
				heartNode.score(bonus)
				let upgradeOverflow = GKAchievement(identifier: "upgradeOverflow")
				if !upgradeOverflow.isCompleted {
					achieve(achievement: upgradeOverflow)
				}
			} else {
				didUpgrade = true
				ball.oneUp()
				heartNode.collect()
				switch ball.color {
					case .orange:
						let orange = GKAchievement(identifier: "orangeUpgrade")
						if !orange.isCompleted {
							achieve(achievement: orange)
						}
						break
					case .yellow:
						let yellow = GKAchievement(identifier: "yellowUpgrade")
						if !yellow.isCompleted {
							achieve(achievement: yellow)
						}
						break
					case .green:
						let green = GKAchievement(identifier: "greenUpgrade")
						if !green.isCompleted {
							achieve(achievement: green)
						}
						break
					case .blue:
						let blue = GKAchievement(identifier: "blueUpgrade")
						if !blue.isCompleted {
							achieve(achievement: blue)
						}
						break
					case .purple:
						let purple = GKAchievement(identifier: "purpleUpgrade")
						if !purple.isCompleted {
							achieve(achievement: purple)
						}
						break
					default:
						break
				}
			}
		} else if let lineNode = otherNode as? Line {
			if lineNode.scored {
				let scoreAgain = GKAchievement(identifier: "scoreAgain")
				if !scoreAgain.isCompleted {
					achieve(achievement: scoreAgain)
				}
				return
			}
			lineNode.score(ball.fillColor)
			score += ball.color.rawValue
			if !didUpgrade && score >= 100 {
				let hundred = GKAchievement(identifier: "oneHundRed")
				if !hundred.isCompleted {
					achieve(achievement: hundred)
				}
			}
		}
	}
	
	func form() {
		score = 0

		cam.position = CGPoint(x: frame.midX, y: frame.midY)
		camSpeed = minCamSpeed
		lines.camSpeed = Double(camSpeed)
		
		ball.position = CGPoint(x: cam.position.x, y: cam.position.y + ballOffset)
		ball.physicsBody!.velocity = CGVector.zero
		
		lines.nextY = cam.position.y
		lines.shouldSpawnHeart = 10
		lines.place()
		
		if !localPlayer.isAuthenticated {
			highscore = localStorage.integer(forKey: "highscore")
		}
	}
	
	func achieve(achievement: GKAchievement, progress: Double = 100) {
		achievement.percentComplete = progress
		achievement.showsCompletionBanner = true
		GKAchievement.report([achievement]) { error in
			guard error == nil else {
				return
			}
		}
	}
	
	func updateLeaderboard() {
		guard localPlayer.isAuthenticated else {
			return
		}
		
		GKLeaderboard.submitScore(score, context: 0, player: localPlayer, leaderboardIDs: ["scores"]) { error in
			guard error == nil else {
				return
			}
		}
	}
	
	func updateAchievements() {
		guard localPlayer.isAuthenticated else {
			return
		}
		
		let firstGame = GKAchievement(identifier: "firstGame")
		if !firstGame.isCompleted {
			achieve(achievement: firstGame)
		}
		
		let score1k = GKAchievement(identifier: "score1000")
		if !score1k.isCompleted {
			if score >= 1000 {
				achieve(achievement: score1k)
			} else {
				achieve(achievement: score1k, progress: round(Double(score) / 1000 * 100))
			}
		}
		
		let score5k = GKAchievement(identifier: "score5000")
		if !score5k.isCompleted {
			if score >= 5000 {
				achieve(achievement: score5k)
			} else  {
				achieve(achievement: score5k, progress: round(Double(score) / 5000 * 100))
			}
		}
		
		let quickGame = GKAchievement(identifier: "quickGame")
		if !quickGame.isCompleted && Date() < startTime.addingTimeInterval(10) {
			achieve(achievement: quickGame)
		}
	}
	
	func pause() {
		playing = false
		physicsWorld.speed = 0
		for child in children {
			child.isPaused = true
		}
	}
	
	func resume() {
		playing = true
		physicsWorld.speed = 1
		for child in children {
			child.isPaused = false
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		guard playing else {
			return
		}
		
		cam.position.y -= camSpeed
		if camSpeed < maxCamSpeed {
			camSpeed += camSpeedDelta
			lines.camSpeed = Double(camSpeed)
		}
		
		lines.wrap(center: cam.position.y)
		
		if cam.contains(ball) {
			return
		}
		
		if ball.color == .red {
			if score > highscore {
				highscore = score
				localStorage.set(highscore, forKey: "highscore")
			}
			updateLeaderboard()
			updateAchievements()
			ui.showOver()
			pause()
			return
		}
		
		ball.die()
		ball.physicsBody!.velocity = CGVector.zero
		ball.position = CGPoint(x: cam.position.x, y: cam.position.y + ballOffset)
		
		if !ball.physicsBody!.allContactedBodies().isEmpty {
			ball.position.y += 10
		}
	}
}
