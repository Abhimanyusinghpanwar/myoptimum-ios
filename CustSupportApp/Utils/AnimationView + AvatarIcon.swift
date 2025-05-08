//
//  LottieAnimationView + AvatarIcon.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 26/10/22.
//

import Foundation
import Lottie

extension LottieAnimationView {
    func createStaticImageForProfileAvatar(avatarID:Int?, profileName: String?,isOnlinePause: Bool = false, isHomeWithBg:Bool = false, isHomeOnlinepause : Bool = false, completionBlock :@escaping (Bool) -> () = {_ in }) {
            let avatarIcon = AvatarIcon(avatarID: avatarID, profileName: profileName)
            let imageName = avatarIcon.getAvatarName(isOnlinepause: isOnlinePause, isHomeOnlinepause:isHomeOnlinepause, isHomeWithBg: isHomeWithBg)
            self.animation = LottieAnimation.named(imageName)
            var animationFrameTime = AnimationFrameTime()
            if imageName == "Chess-Profile-Pause-Online" || imageName ==  "Chess-Home-Offline-Online1"{
                if let startFrame = self.animation?.startFrame {
                    animationFrameTime = startFrame
                }
            } else {
                if isOnlinePause {
                    if let endFrame = self.animation?.startFrame {
                        animationFrameTime = endFrame
                    }
                } else {
                    if let endFrame = self.animation?.endFrame {
                        animationFrameTime = endFrame
                    }
                }
            }
            self.play(fromFrame: animationFrameTime ,
                      toFrame: animationFrameTime) { _ in
                completionBlock(true)
            }
        self.pause()
        }
    
    func playAnimationForPauseUnpause(avatarID:Int?, profileName: String?,isProfileOnlinePause: Bool = false,completionBlock :@escaping (Bool) -> () = {_ in }) {
            let avatarIcon = AvatarIcon(avatarID: avatarID, profileName: profileName)
            let imageName = avatarIcon.getAvatarName(isHomeOnlinepause: isProfileOnlinePause)
            self.animation = LottieAnimation.named(imageName)
            self.loopMode  = .playOnce
            self.play()
     }
}
