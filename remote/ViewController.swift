//
//  ViewController.swift
//  remote
//
//  Created by Emiel Lensink | The Mobile Company on 29/03/16.
//  Copyright © 2016 The Mobile Company. All rights reserved.
//

import UIKit
import GameController

class ViewController: GCEventViewController {

	var controller:GCMicroGamepad!
	var motion:GCMotion!
	
	@IBOutlet var remoteView:UIView!
	
	@IBOutlet var menuButtonView:UIView!
	@IBOutlet var playPauseButtonView:UIView!
	@IBOutlet var trackpadButtonView:UIView!
	
	@IBOutlet var trackpadDot:UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.controllerUserInteractionEnabled = false
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(connected), name: GCControllerDidConnectNotification, object: nil)
		
		menuButtonView.alpha = 0
		playPauseButtonView.alpha = 0
		trackpadButtonView.alpha = 0
		trackpadDot.alpha = 0
	}

	override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
		super.pressesBegan(presses, withEvent: event)
	}
	
	override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
		super.pressesEnded(presses, withEvent: event)
		
		if let p = presses.first {
			if p.type == UIPressType.Menu {
				menuButtonView.alpha = 1
			
				let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.4 * Double(NSEC_PER_SEC)))
				dispatch_after(time, dispatch_get_main_queue(), {
					self.menuButtonView.alpha = 0
				})
			}
		}
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesBegan(touches, withEvent: event)
		
		trackpadDot.alpha = 1
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesEnded(touches, withEvent: event)

		trackpadDot.alpha = 0
	}
	
	func connected() {

		let controllers = GCController.controllers()
		if controllers.count > 0 {
			let c = controllers[0]
			
			if let mgp = c.microGamepad {
				controller = mgp;
				controller.reportsAbsoluteDpadValues = true
				controller.valueChangedHandler = {(gamepad, element) -> Void in
					self.buttonChanged(gamepad, element: element)
				}
			}
			
			if let m = c.motion {
				motion = m
				motion.valueChangedHandler = {(motion) -> Void in
					self.motionChanged(motion)
				}
			}
		}
	}

	func buttonChanged(gamepad:GCMicroGamepad, element:GCControllerElement) {
		
		if let button = element as? GCControllerButtonInput {
			if button == gamepad.buttonX {
				playPauseButtonView.alpha = button.pressed ? 1 : 0
			}

			if button == gamepad.buttonA {
				trackpadButtonView.alpha = button.pressed ? 1 : 0
			}
		}
		
		if let pad = element as? GCControllerDirectionPad {
			// Axis values range from -1 to 1
			let center = trackpadButtonView.center
			let factor = trackpadButtonView.frame.size.width / 2.0
			
			trackpadDot.center = CGPoint(x: center.x + factor * CGFloat(pad.xAxis.value), y: center.y - factor * CGFloat(pad.yAxis.value))
		}
	}
	
	func motionChanged(motion:GCMotion) {
		let rotation = atan2(motion.gravity.x, motion.gravity.y) - M_PI
		remoteView.transform = CGAffineTransformMakeRotation(CGFloat(-rotation))
	}
}

