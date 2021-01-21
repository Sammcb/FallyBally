//
//  GameScene.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/15/21.
//

import SpriteKit
import GameKit

//class World: SKNode {
//	
//}
//
//class UI: SKNode {
//	
//}

class GameScene: SKScene, UIGestureRecognizerDelegate, SKPhysicsContactDelegate {
	// UI
	let restartButton = Button(symbolName: "goforward", width: 30)
	let playButton = Button(symbolName: "play.fill", width: 30)
	let pauseButton = Button(symbolName: "pause.circle.fill", width: 30)
	let resumeButton = Button(symbolName: "play.circle.fill", width: 30)
	let highScoreLabel = Text()
	let highScoreSymbol = ScaleableNode(symbolName: "crown.fill", width: 20)
	let scoreLabel = Text()
	let scoreXLabel = Text()
	let uiY: CGFloat = 90
	let uiX: CGFloat = 50
	var gameView: SKView?
	var colorMode: UIUserInterfaceStyle?
	var colorModeObserver: NSKeyValueObservation?
	
	// Game
	let localStorage = UserDefaults.standard
	let ballOffset: CGFloat = 100
	let ball = Ball(radius: 10)
	let cam = SKCameraNode()
	let lines = Lines()
	var score = 0
	var highScore = 0
	var start = false
	
	// Game Center
	let localPlayer = GKLocalPlayer.local
	var scoresLeaderboard: GKLeaderboard?
	
	// Recolor elements to match system color theme
	func paint() {
		backgroundColor = .systemBackground
		ball.paint()
		lines.paint()
		restartButton.paint()
		playButton.paint()
		pauseButton.paint()
		resumeButton.paint()
		highScoreLabel.paint()
		highScoreSymbol.paint()
		scoreLabel.paint()
		scoreXLabel.paint()
	}
	
	// Start a new game
	func buildLevel() {
		// Display the Game Center Access Point
		if localPlayer.isAuthenticated {
			GKAccessPoint.shared.isActive = true
		}
		
		// Init score
		score = 0
		
		// Set camera position
		cam.position = CGPoint(x: frame.midX, y: frame.midY)
		
		// Set the UI element positions
		playButton.position = CGPoint.zero
		playButton.isHidden = false
		
		pauseButton.position = CGPoint(x: frame.midX - uiX, y: -frame.midY + uiY)
		pauseButton.isHidden = true
		
		resumeButton.position = pauseButton.position
		resumeButton.isHidden = true
		
		restartButton.position = CGPoint.zero
		restartButton.isHidden = true
		
		highScoreLabel.text = "\(highScore)"
		highScoreLabel.position = CGPoint(x: 0, y: frame.midY - uiY)
		
		highScoreSymbol.position = CGPoint(x: 0, y: highScoreLabel.frame.height + 5)
		
		scoreLabel.text = "\(score)"
		scoreLabel.position = CGPoint(x: frame.midX / 2 + 20, y: frame.midY - uiY)
		
		scoreXLabel.text = "x\(ball.color.rawValue)"
		scoreXLabel.position = CGPoint(x: 0, y: -scoreLabel.frame.height)
		scoreXLabel.paint(ball.fillColor)
		
		// Place the ball and prevent movement
		ball.position = CGPoint(x: 0, y: ballOffset)
		ball.physicsBody!.isDynamic = false
		
		// Place the platforms
		lines.nextY = cam.position.y
		lines.place()
	}
	
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
			GKAccessPoint.shared.isActive = self.localPlayer.isAuthenticated
			GKLeaderboard.loadLeaderboards(IDs: ["scores"]) { leaderboards, error in
				guard error == nil else {
					return
				}
					
				self.scoresLeaderboard = leaderboards!.first!
				self.scoresLeaderboard?.loadEntries(for: [self.localPlayer], timeScope: .allTime) { entry, entries, error in
					guard error == nil else {
						return
					}
					
					guard entry != nil else {
						return
					}
					
					self.highScore = entry!.score
					
					print("SCORES: \(entry!.score)")
				}
			}
		}
	}
	
	override func didMove(to view: SKView) {
		// Store the view and color scheme for color scheme change detection
		gameView = view
		colorMode = view.traitCollection.userInterfaceStyle
		
		// Connect to game center
		authenticateUser()
		
		// Init highscore
		if !localPlayer.isAuthenticated {
			highScore = localStorage.integer(forKey: "highscore")
		}
		
		// Set up physics contact handler
		physicsWorld.contactDelegate = self
		
		// Set the camera
		camera = cam
		addChild(cam)
		
		// UI init
		playButton.zPosition = 2
		cam.addChild(playButton)
		
		pauseButton.zPosition = 2
		cam.addChild(pauseButton)
		
		resumeButton.zPosition = 2
		cam.addChild(resumeButton)
		
		restartButton.zPosition = 2
		cam.addChild(restartButton)
		
		highScoreLabel.zPosition = 2
		highScoreLabel.verticalAlignmentMode = .center
		highScoreLabel.horizontalAlignmentMode = .center
		cam.addChild(highScoreLabel)
		
		highScoreSymbol.zPosition = 2
		highScoreSymbol.paint(.systemYellow)
		highScoreLabel.addChild(highScoreSymbol)
		
		scoreLabel.zPosition = 2
		scoreLabel.verticalAlignmentMode = .center
		scoreLabel.horizontalAlignmentMode = .center
		cam.addChild(scoreLabel)
		
		scoreXLabel.zPosition = 2
		scoreXLabel.verticalAlignmentMode = .center
		scoreXLabel.horizontalAlignmentMode = .center
		scoreXLabel.fontSize = 15
		scoreLabel.addChild(scoreXLabel)
		
		// Spawn ball
		ball.zPosition = 1
		cam.addChild(ball)
		
		// Generate lines and hearts
		lines.set(frame: frame)
		for _ in stride(from: cam.position.y + frame.midY, to: cam.position.y - frame.midY - ballOffset, by: -lines.distance) {
			let line = Line(width: 60, height: 5)
			let heart = Heart()
			line.addChild(heart)
			heart.position = CGPoint(x: line.frame.midX, y: line.frame.maxY + 15)
			lines.addChild(line)
		}
		addChild(lines)
		
		paint()
		buildLevel()
	}
	
	// Detect if a node was tapped
	func pressed(button: Button, at touch: UITouch) -> Bool {
		nodes(at: touch.location(in: self)).contains(button)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		// Start the game
		guard start || !pressed(button: playButton, at: touches.first!) else {
			playButton.flash()
			ball.physicsBody!.isDynamic = true
			start = true
			playButton.hide()
			pauseButton.show()
			GKAccessPoint.shared.isActive = false
			return
		}
		
		// Pause the game
		guard isPaused || !start || !pressed(button: pauseButton, at: touches.first!) else {
			pauseButton.flash()
			isPaused = true
			pauseButton.isHidden = true
			resumeButton.isHidden = false
			return
		}
		
		// Resume the game
		guard !isPaused || !start || !pressed(button: resumeButton, at: touches.first!) else {
			isPaused = false
			resumeButton.flash()
			pauseButton.isHidden = false
			resumeButton.isHidden = true
			return
		}
		
		// Resets the level
		guard !isPaused || !start || !pressed(button: restartButton, at: touches.first!) else {
			isPaused = false
			restartButton.flash()
			start = false
			buildLevel()
			return
		}
		
		// Absorbe taps when paused
		guard !isPaused else {
			return
		}
		
		// Move the ball left or right
		ball.physicsBody!.applyImpulse(CGVector(dx: touches.first!.location(in: self).x < frame.midX ? -2 : 2, dy: 0))
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		let ballNode = (contact.bodyA.node!.name == "ball" ? contact.bodyA.node! : contact.bodyB.node!) as! Ball
		let otherNode = contact.bodyA.node!.name != "ball" ? contact.bodyA.node! : contact.bodyB.node!
		if let heartNode = otherNode as? Heart {
			guard ball.color != .purple else {
				// give player points
				return
			}
			ballNode.oneUp()
			heartNode.collect()
			scoreXLabel.text = "x\(ball.color.rawValue)"
			scoreXLabel.paint(ball.fillColor)
		} else if let lineNode = otherNode as? Line {
			lineNode.score(ballNode.fillColor)
			score += ball.color.rawValue
			scoreLabel.text = "\(score)"
		}
	}
	
	func updateGameCenter() {
		if scoresLeaderboard != nil {
			print(scoresLeaderboard!)
			scoresLeaderboard!.submitScore(score, context: 0, player: localPlayer) {error in
				guard error == nil else {
					return
				}
			}
		}
		
//		let firstGame = GKAchievement(identifier: "firstGame")
//		if !firstGame.isCompleted {
//			firstGame.percentComplete = 100
//			firstGame.showsCompletionBanner = true
//		}
//		GKAchievement.report([firstGame]) { error in
//			guard error == nil else {
//				return
//			}
//		}
	}
	
	// Resets the game, saves the game information, and tells the viewcontroller the game ended
	func reset() {
		// Hide gamplay buttons
		if !pauseButton.isHidden {
			pauseButton.isHidden = true
		}
		if !resumeButton.isHidden {
			resumeButton.isHidden = true
		}
		
		// Show the reset button
		restartButton.isHidden = false
		
		// Update highscore
		if score > highScore {
			highScore = score
			localStorage.set(highScore, forKey: "highscore")
			highScoreLabel.text = "\(highScore)"
			updateGameCenter()
		}
		
		// Pause the game to stop platforms
		isPaused = true
	}
	
	override func update(_ currentTime: TimeInterval) {
		// Check system color them changes
		if (gameView?.traitCollection.userInterfaceStyle != colorMode) {
			colorMode = gameView?.traitCollection.userInterfaceStyle
			paint()
			// Changing system theme with scene paused unpauses scene
			// Pause again if the game was paused
			isPaused = start && pauseButton.isHidden
		}
		
		// Exit if game not started
		guard start else {
			return
		}
		
		// Move camera down
		cam.position.y -= 1
		
		// Move any lines above the screen below the screen
		lines.wrap(center: cam.position.y)
		
		// Exit if the ball is onscreen
		guard !cam.contains(ball) else {
			return
		}
		
		// End the game if the ball is red
		guard ball.color != .red else {
			reset()
			return
		}
		
		// Remove a life from the ball
		ball.die()
		scoreXLabel.text = "x\(ball.color.rawValue)"
		scoreXLabel.paint(ball.fillColor)
		ball.physicsBody!.velocity = CGVector.zero
		ball.position = CGPoint(x: 0, y: ballOffset)
		
		// If ball respawns in a platform, move ball out of platform
		if !ball.physicsBody!.allContactedBodies().isEmpty {
			ball.position.y += 10
		}
	}
}
