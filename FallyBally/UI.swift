//
//  UI.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/22/21.
//

import SpriteKit
import GameKit

class UI: SKNode {
	let restartButton = ScaleableNode(symbolName: "goforward", width: 40)
	let playButton = ScaleableNode(symbolName: "play.fill", width: 40)
	let pauseButton = ScaleableNode(symbolName: "pause.circle.fill", width: 40)
	let resumeButton = ScaleableNode(symbolName: "play.circle.fill", width: 40)
	let highscoreLabel = Text()
	let highscoreSymbol = ScaleableNode(symbolName: "crown.fill", width: 20)
	let scoreLabel = Text()
	let scoreXLabel = Text()
	let yPadding: CGFloat = 90
	let xPadding: CGFloat = 50
	let uiZ: CGFloat = 2
	var bounds = CGRect.zero
	var world: GameScene?
	
	override init() {
		super.init()
		playButton.zPosition = uiZ
		addChild(playButton)
		
		pauseButton.zPosition = uiZ
		addChild(pauseButton)
		
		resumeButton.zPosition = uiZ
		addChild(resumeButton)
		
		restartButton.zPosition = uiZ
		addChild(restartButton)
		
		highscoreLabel.zPosition = uiZ
		highscoreLabel.verticalAlignmentMode = .center
		highscoreLabel.horizontalAlignmentMode = .center
		addChild(highscoreLabel)
		
		highscoreSymbol.zPosition = uiZ
		highscoreSymbol.paint(.systemYellow)
		highscoreLabel.addChild(highscoreSymbol)

		scoreLabel.zPosition = uiZ
		scoreLabel.verticalAlignmentMode = .center
		scoreLabel.horizontalAlignmentMode = .center
		addChild(scoreLabel)
		
		scoreXLabel.zPosition = uiZ
		scoreXLabel.verticalAlignmentMode = .center
		scoreXLabel.horizontalAlignmentMode = .center
		scoreXLabel.fontSize = 15
		scoreLabel.addChild(scoreXLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init()
	}
	
	func form() {
		playButton.position = CGPoint.zero
		playButton.isHidden = false
		
		pauseButton.position = CGPoint(x: bounds.midX - xPadding, y: yPadding - bounds.midY)
		pauseButton.isHidden = true
		
		resumeButton.position = pauseButton.position
		resumeButton.isHidden = true
		
		restartButton.position = CGPoint.zero
		restartButton.isHidden = true
		
		highscoreLabel.text = "\(world!.highscore)"
		highscoreLabel.position = CGPoint(x: 0, y: bounds.midY - yPadding)
		
		highscoreSymbol.position = CGPoint(x: 0, y: highscoreLabel.frame.height + 5)
		
		scoreLabel.text = "0"
		scoreLabel.position = CGPoint(x: bounds.midX / 2 + 20, y: bounds.midY - yPadding)
		
		scoreXLabel.text = "x1"
		scoreXLabel.position = CGPoint(x: 0, y: -scoreLabel.frame.height)
		scoreXLabel.paint(.systemRed)
		
		GKAccessPoint.shared.isActive = world!.loginSuccess
	}
	
	@objc func paint() {
		world!.scene!.backgroundColor = .systemBackground
		world!.ball.paint()
		world!.lines.paint()
		restartButton.paint()
		playButton.paint()
		pauseButton.paint()
		resumeButton.paint()
		highscoreLabel.paint()
		highscoreSymbol.paint()
		scoreLabel.paint()
		scoreXLabel.paint()
	}
	
	func showPlay() {
		playButton.isHidden = true
		pauseButton.isHidden = false
		resumeButton.isHidden = true
		GKAccessPoint.shared.isActive = false
	}
	
	func showPause() {
		pauseButton.isHidden = true
		resumeButton.isHidden = false
	}
	
	func showOver() {
		pauseButton.isHidden = true
		resumeButton.isHidden = true
		restartButton.isHidden = false
	}
}
