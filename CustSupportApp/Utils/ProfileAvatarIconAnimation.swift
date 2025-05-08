//
//  ManageMyHouseholdDevicesVC + Animation.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 20/10/22.
//

import Foundation
import Lottie

enum ImageType{
    case alphabet
    case avatarIcon
    case none
}

enum AnimateFrom {
    case Home
    case ProfileDevices
    case ProfileFirstUX
    case None
}
enum NavigationType {
    case Push
    case Present
}
extension UIViewController {
    
    typealias CompletionHandler = (_ isAnimationCompleted:Bool) -> Void
    typealias CompletionHandlerWithImageType = (_ isAnimationCompleted:Bool, _ imageType:ImageType) -> Void
    
    // MARK: - Source VC ProfileAvatar Animation methods
    func addImageViewAsSubview<T>(selectedView : T,
                                  animeName: String = "",
                                  profileDetail: Profile? = nil,
                                  profileModel: ProfileModel? = nil,animateFromVC: AnimateFrom = .ProfileDevices,
                                  completionHandler:@escaping CompletionHandler) {
        // add profile icon as subview initially
        var avatarType: (text: String , image: ImageType?)
      
        if profileModel != nil {
            avatarType = self.getCurrentAvatarImageName(avatarId: profileModel?.profile?.avatar_id ?? 13, profileName: profileModel?.profileName)
        } else {
            avatarType = self.getCurrentAvatarImageName(avatarId: profileDetail?.avatar_id ?? 13, profileName: profileDetail?.profile)
        }
        let frame = self.getFrameOfSelectedAvatarIcon(selectedView: selectedView, animateFromVC: animateFromVC, imageType: avatarType.1 ?? .none)
        let profileIcon = LottieAnimationView.init(frame: frame)
        profileIcon.tag = 100
        profileIcon.contentMode = .scaleAspectFit
        
        if profileModel != nil {
            profileIcon.createStaticImageForProfileAvatar(avatarID: profileModel?.profile?.avatar_id ?? 0, profileName: profileModel?.profileName)
            
        } else {
            profileIcon.createStaticImageForProfileAvatar(avatarID: profileDetail?.avatar_id, profileName: profileDetail?.profile)
            
        }
        //Added bg view for profileIcon animation
        let bgAnimationView : UIView = UIView.init(frame: self.view.frame)
        bgAnimationView.tag = 1000
        bgAnimationView.alpha = 0.3
        bgAnimationView.backgroundColor = energyBlueRGB
        bgAnimationView.addSubview(profileIcon)
        self.view.addSubview(bgAnimationView)
        //Add avatarIcon LottieAnimationView for backward animation
        if animateFromVC == .Home {
            let backwardAnimationView = LottieAnimationView.init(frame: frame)
            backwardAnimationView.contentMode = .scaleAspectFit
            backwardAnimationView.tag = 101
            backwardAnimationView.alpha = 0.0
            if profileModel != nil {
                backwardAnimationView.createStaticImageForProfileAvatar(avatarID: profileModel?.profile?.avatar_id ?? 0, profileName: profileModel?.profileName, isHomeWithBg: true)
            } else {
                backwardAnimationView.createStaticImageForProfileAvatar(avatarID: profileDetail?.avatar_id, profileName: profileDetail?.profile, isHomeWithBg: true)
            }
            self.view.addSubview(backwardAnimationView)
        }
        
        
        if animateFromVC == .ProfileFirstUX {
            profileIcon.frame = CGRect(x: UIScreen.main.bounds.width/2 , y: UIScreen.main.bounds.height/2, width: 110, height: 110)
            profileIcon.center = CGPoint(x: bgAnimationView.frame.size.width  / 2,
                                         y: bgAnimationView.frame.size.height / 2)
            let label:UILabel = UILabel.init(frame: CGRect(x:0,y:profileIcon.frame.origin.y + profileIcon.frame.height + 20,width:bgAnimationView.frame.width, height: 60))
            label.text = "Nice choice, \n \(profileModel?.profileName ?? "")!"
            label.tag = 1004
            label.textAlignment = .center
            label.numberOfLines = 0
            label.alpha = 0
            label.font = UIFont.init(name: "Regular-Bold", size:22.0)
            label.textColor = .white
            bgAnimationView.addSubview(label)
        }
        let (avatarId,profileName) = self.getAvatarIdAndProfileName(profileDetail: profileDetail, profileModel: profileModel)
       // let avatarId = avatarId //{
            let (imageName, _) = self.getCurrentAvatarImageName(avatarId: avatarId, profileName: profileName)
            if animateFromVC != .Home {
            let imageView = UIImageView.init(frame: frame)
            imageView.contentMode = .scaleAspectFit
            imageView.tag = 101
            imageView.alpha = 0.0
            imageView.image = UIImage.init(named: imageName)
            self.view.addSubview(imageView)
        }

                //Create and add  alphabetView for backward animation
        let alphabetView = self.view.createViewForAlphabets(letter: imageName, animateFromVC: animateFromVC, frame: CGPoint(x: frame.origin.x, y: frame.origin.y))
                alphabetView.tag = 102
                alphabetView.alpha = 0.0
                self.view.addSubview(alphabetView)
      //  }
        UIView.animate(withDuration: 0.6) { [self] in
            //fade out UI Elements with alpha
            self.setAlphaForUIElements(alpha: 0.0)
            bgAnimationView.alpha = 1.0
        } completion: { _ in
            if animateFromVC != .ProfileFirstUX {
                self.animateProfileIconToTop(profileDetail: profileDetail, profileModel: profileModel) { isAnimationCompleted in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        completionHandler(true)
                    }
                }
            } else {
                self.animateProfileIconFromCenter(profileDetail: profileDetail, profileModel: profileModel) { isAnimationCompleted in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        completionHandler(true)
                    }
                }
            }
        }
    }
    
    func getAvatarIdAndProfileName(profileDetail:Profile?, profileModel: ProfileModel?)->(avatarId:Int,profileName:String){
        let avatarId = profileModel != nil ? profileModel?.profile?.avatar_id ?? 13: profileDetail?.avatar_id ?? 13
        let profileName = profileModel != nil ? profileModel?.profileName ?? " ": profileDetail?.profile ?? " "
        return (avatarId, profileName)
    }
    
    func setAlphaForUIElements(alpha : CGFloat){
        self.view.subviews.forEach({ if $0 != self.view.viewWithTag(1000) { $0.alpha = alpha }})
    }
    
    func getFrameOfSelectedAvatarIcon<T>(selectedView:T, animateFromVC: AnimateFrom = .ProfileDevices, imageType : ImageType = .none) -> CGRect{
        var avatarIconFrame:CGRect = CGRect()
        if let selectedCell = selectedView as? ManageMyHouseholdDeviceCell {
            avatarIconFrame = selectedCell.convert(selectedCell.profileAvatarImgView
                .frame, to: self.view)
        }
        if let selectedCell = selectedView as? DeviceCollectionViewCell {
            avatarIconFrame = selectedCell.convert(selectedCell.animationView
                .frame, to: self.view)
        }
        if let selectedCell = selectedView as? ProfileDetailsTableViewCell {
            avatarIconFrame = selectedCell.convert(selectedCell.profileIconLottieView
                .frame, to: self.view)
        }
        if let selectedCell = selectedView as? ConnectedDevicesListTableViewCell {
            avatarIconFrame = selectedCell.vwContainer.convert(selectedCell.imgViewType
                .frame, to: self.view)
            return avatarIconFrame
        }
        if let selectedCell = selectedView as? TvDeviceListViewCell {
            avatarIconFrame = selectedCell.contentView.convert(selectedCell.streamIcon.frame, to: self.view)
            return avatarIconFrame
        }
        avatarIconFrame.origin.x = avatarIconFrame.origin.x + (animateFromVC == .ProfileDevices ? 12.5 : imageType == .alphabet ? 16.5 : 17)
       
        avatarIconFrame.origin.y = avatarIconFrame.origin.y + (animateFromVC == .ProfileDevices ? 11.5 : imageType == .alphabet ? 19 : 14.5)
        avatarIconFrame.size.width = (animateFromVC == .ProfileDevices) ? 45.0 : 65.0
        avatarIconFrame.size.height = (animateFromVC == .ProfileDevices) ? 45.0 : 65.0
        return avatarIconFrame
    }
    
    
    func animateProfileIconFromCenter(dimensions:CGFloat = 90.0 , profileDetail:Profile? = nil, profileModel:ProfileModel? = nil, completionHandler: @escaping CompletionHandler) {
        guard let profileButton = self.view.viewWithTag(100), let alphabetLabel = self.view.viewWithTag(1004) else {
            completionHandler(true )
            return
        }
        
        let xDestinationPoint = 0.0
        let yDestinationPoint:CGFloat = 0.0
        let yTransform = (profileButton.frame.origin.y - yDestinationPoint) * -0.3
        let labelyTransform = (alphabetLabel.frame.origin.y - yDestinationPoint) * -0.25
        
        UIView.animate(withDuration: 0.8) {
            profileButton.transform = CGAffineTransform(translationX: xDestinationPoint, y: yTransform)
            alphabetLabel.transform = CGAffineTransform(translationX: xDestinationPoint, y: labelyTransform)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
                alphabetLabel.alpha = 1.0
            }
            
        } completion: { _ in
            completionHandler(true)
        }
    }
    
    func animateProfileIconToTop(dimensions:CGFloat = 90.0 , profileDetail:Profile? = nil, profileModel:ProfileModel? = nil, completionHandler: @escaping CompletionHandler) {
        guard let profileButton = self.view.viewWithTag(100), let imageView = self.view.viewWithTag(101), let alphabetView = self.view.viewWithTag(102) else {
         completionHandler(true )
         return
         }
        let xDestinationPoint = self.view.frame.width/2 - 45.0 - profileButton.frame.origin.x
        var yDestinationPoint:CGFloat = 0.0
        
        if (currentScreenWidth >= 390.0 || currentScreenWidth == 375.0) && UIDevice.current.hasNotch {
            yDestinationPoint = UIDevice.current.topInset
        } else {
            yDestinationPoint = UIDevice.current.topInset + 20
        }
        
        let yTransform = (profileButton.frame.origin.y - yDestinationPoint) * -1
            UIView.animate(withDuration: 0.5) {
                profileButton.transform = CGAffineTransform(translationX: xDestinationPoint, y: yTransform)
               imageView.transform = CGAffineTransform(translationX: xDestinationPoint, y: yTransform)
                alphabetView.transform = CGAffineTransform(translationX: xDestinationPoint, y: yTransform)
                profileButton.frame.size.width =  dimensions
                profileButton.frame.size.height = dimensions
                imageView.frame.size.width =  dimensions
               imageView.frame.size.height = dimensions
                alphabetView.frame.size.width =  dimensions
                alphabetView.frame.size.height = dimensions
            } completion: { _ in
                completionHandler(true)
            }
    }

    func updateAvatarAfterEditForBackwardAnimation(updatedProfileDetail:Profile?,animatingVC:AnimateFrom = .ProfileDevices, completionHandler: @escaping CompletionHandler) {
        guard let profileButton = self.view.viewWithTag(100) as? LottieAnimationView, let imageView = self.view.viewWithTag(101), let alphabetView = self.view.viewWithTag(102) else {
            completionHandler(true)
            return
        }
        guard let profileName = updatedProfileDetail?.profile, !profileName.isEmpty else {
            completionHandler(true)
            return
        }
        if let avatarId = updatedProfileDetail?.avatar_id {
            let (imageName, imageType) = self.getCurrentAvatarImageName(avatarId: avatarId, profileName: profileName)
            if imageType == .alphabet {
               let alphabetLabel = alphabetView.viewWithTag(1002) as? UILabel
               alphabetLabel?.text = profileName.prefix(1).capitalized
            } else {
                if animatingVC == .ProfileDevices {
                    let shadowImageView = imageView as? UIImageView
                    shadowImageView?.image = UIImage.init(named: imageName)
                } else {
                    let shadowView = imageView as? LottieAnimationView
                    shadowView?.createStaticImageForProfileAvatar(avatarID: updatedProfileDetail?.avatar_id, profileName: profileName, isHomeWithBg:true)
                }
            }
            //Updated lottie ImageView
            profileButton.createStaticImageForProfileAvatar(avatarID: updatedProfileDetail?.avatar_id, profileName: profileName) { isAnimationCompleted in
                completionHandler(true)
            }
        }
        
    }
    
    func animateProfileAvatarIconFromTopToBottomHome<T>(toView: T, fromView: T, profileDetail:Profile, color:UIColor,  completionHandler: @escaping CompletionHandlerWithImageType) {
        guard let profileButton = self.view.viewWithTag(100) as? LottieAnimationView, let imageView = self.view.viewWithTag(101) as? LottieAnimationView,let alphabetView = self.view.viewWithTag(102), let bgView = self.view.viewWithTag(1000) else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completionHandler(true,.none)
            }
            return
        }
        
        let alphaLetterView = self.view.viewWithTag(1002)
        let alphaLetterViewBg = self.view.viewWithTag(1003)

        var (_, imageType): (String, ImageType?) = ("", nil)
        let avatarId = profileDetail.avatar_id ?? 13
        (_, imageType) = self.getCurrentAvatarImageName(avatarId: avatarId, profileName: profileDetail.profile)
        let destinationFrame = self.getFrameOfSelectedAvatarIcon(selectedView: toView, animateFromVC: .Home, imageType: imageType ?? .none)
        UIView.animate(withDuration: 0.7) {
            let shiftXValue = (imageType == .alphabet) ? 1.5 : 3.0
            let shiftYValue = (imageType == .alphabet) ? 1.0 : 3.0
            
            profileButton.contentMode = .scaleAspectFit
            profileButton.frame.origin.x = destinationFrame.origin.x - shiftXValue
            profileButton.frame.origin.y = destinationFrame.origin.y - shiftYValue
            profileButton.frame.size.width =  imageType == .alphabet ? 68.0 : 70.0
            profileButton.frame.size.height = imageType == .alphabet ? 68.0 : 70.0
            
            //imageView.frame.origin.x = destinationFrame.origin.x
            
            var frame = destinationFrame
            frame.origin.x = frame.origin.x - 19.5
            frame.size.width =  90
            frame.size.height = 90
            
            if imageType == .avatarIcon {
                frame.origin.x = frame.origin.x + 7.5
                frame.origin.y = destinationFrame.origin.y - 10.5
                imageView.frame = frame // withBackground
            } else {
                alphabetView.frame = frame
                alphabetView.frame.origin.x = frame.origin.x + 2
                alphabetView.frame.origin.y = destinationFrame.origin.y - 20
                alphaLetterView?.frame.size.width =  99.5
                alphaLetterView?.frame.size.height =  99.5
                alphaLetterViewBg?.frame.size.width =  99.5
                alphaLetterViewBg?.frame.size.height =  99.5
            }
        } completion: { _ in
            UIView.animate(withDuration: 0.4) {
                bgView.backgroundColor = color
                if imageType == .avatarIcon {
                    imageView.alpha = 1.0
                } else {
                    alphabetView.alpha = 1.0
                }
                profileButton.alpha = 0.0
            } completion: { _ in
                profileButton.removeFromSuperview()
                completionHandler(true, imageType ?? .none)
            }
        }
    }
    
    func animateProfileAvatarIconFromTopToBottom<T>(toView: T,profileDetail:Profile, color:UIColor, animateFromVC: AnimateFrom = .ProfileDevices,  completionHandler: @escaping CompletionHandlerWithImageType){
        guard let profileButton = self.view.viewWithTag(100) as? LottieAnimationView, let imageView = self.view.viewWithTag(101),let alphabetView = self.view.viewWithTag(102), let bgView = self.view.viewWithTag(1000) else {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completionHandler(true, .none)
        }
        return
    }
        let destinationFrame = self.getFrameOfSelectedAvatarIcon(selectedView: toView, animateFromVC: animateFromVC)
        var (_, imageType): (String, ImageType?) = ("", nil)
        let avatarId = profileDetail.avatar_id ?? 13
             (_, imageType) = self.getCurrentAvatarImageName(avatarId: avatarId, profileName: profileDetail.profile)
        UIView.animate(withDuration: 0.7) {
            profileButton.frame.size.width = (animateFromVC == .ProfileDevices) ? 45.0 : 55.0
            profileButton.frame.size.height = (animateFromVC == .ProfileDevices) ? 45.0 : 55.0
            profileButton.contentMode = .scaleAspectFit
            profileButton.frame.origin.x = destinationFrame.origin.x
            profileButton.frame.origin.y = destinationFrame.origin.y
            
            var frame = imageView.frame
            frame.origin.x = destinationFrame.origin.x - (animateFromVC == .ProfileDevices ? 12.5 : 18.0)
            frame.origin.y = destinationFrame.origin.y - (animateFromVC == .ProfileDevices ? 11.5 : 17.5)
            frame.size.width = (animateFromVC == .ProfileDevices) ? 70.0 : 99.5
            frame.size.height = (animateFromVC == .ProfileDevices) ? 70.0 : 99.5
            if imageType == .avatarIcon {
                imageView.frame = frame
            } else {
                alphabetView.frame = frame
            }
        } completion: { _ in
                     UIView.animate(withDuration: 0.4) {
             bgView.backgroundColor = color
             if imageType == .avatarIcon {
                 imageView.alpha = 1.0
             } else {
                 alphabetView.alpha = 1.0
             }
             profileButton.alpha = 0.0
                 } completion: { _ in
                     profileButton.removeFromSuperview()
                     completionHandler(true, imageType ?? .none)
                 }
             }
    }
 
    func getCurrentAvatarImageName(avatarId:Int, profileName:String?) -> (String, ImageType?){
        switch avatarId {
        case 1...12:
            return ("Online" + String(avatarId),.avatarIcon)
        default:
            guard let profile = profileName, !profile.isEmpty else {
                break
            }
            return (profile.prefix(1).capitalized, .alphabet)
        }
        return ("", nil)
    }
    
    // MARK: - Source VC Device Icon Animation methods
    func addDeviceIconAsSubviewAndAnimate(frame:CGRect, iconImage: UIImage,isEditDeviceScreen : Bool = false,backGroundColor :UIColor = energyBlueRGB,
                                          completionHandler:@escaping CompletionHandler){
        // add ConnectedDevice icon as subview initially
        let imageView:UIImageView =  UIImageView.init(frame: frame)
        imageView.image =  iconImage
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 100
        //Added bg view for deviceIcon animation
        let bgAnimationView : UIView = UIView.init(frame: self.view.frame)
        bgAnimationView.tag = 1000
        bgAnimationView.alpha = 0.3
        bgAnimationView.backgroundColor = backGroundColor 
        bgAnimationView.addSubview(imageView)
        self.view.addSubview(bgAnimationView)
        UIView.animate(withDuration: 0.5) { [self] in
            //fade out UI Elements with alpha
            self.setAlphaForUIElements(alpha: 0.0)
            bgAnimationView.alpha = 1.0
        } completion: { _ in
            //Move device icon to top with animation
            if isEditDeviceScreen {
                self.animateDeviceIconToTopForEditDevice() { isAnimationCompleted in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        completionHandler(true)
                    }
                }
            } else {
                self.animateDeviceIconToTop() { isAnimationCompleted in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        completionHandler(true)
                    }
                }
            }
        }
    }
    
    func addDeviceIconAsSubviewAndAnimateForAssignProfile(frame:CGRect, iconImage: UIImage,backGroundColor :UIColor = energyBlueRGB, completionHandler:@escaping CompletionHandler){
        // add ConnectedDevice icon as subview initially
        let imageView:UIImageView =  UIImageView.init(frame: frame)
        imageView.image =  iconImage
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 100
        //Added bg view for deviceIcon animation
        let bgAnimationView : UIView = UIView.init(frame: self.view.frame)
        bgAnimationView.tag = 1000
        bgAnimationView.alpha = 0.3
        bgAnimationView.backgroundColor = backGroundColor
        bgAnimationView.addSubview(imageView)
        self.view.addSubview(bgAnimationView)
        UIView.animate(withDuration: 0.5) { [self] in
            //fade out UI Elements with alpha
            self.setAlphaForUIElements(alpha: 0.0)
            bgAnimationView.alpha = 1.0
        } completion: { _ in
            //Move device icon to top with animation
            self.animateDeviceIconToTopForAssignProfile() { isAnimationCompleted in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    completionHandler(true)
                }
            }
        }
    }
    
    func animateDeviceIconToTop(dimensions:CGFloat = 50.0, completionHandler:@escaping CompletionHandler){
        guard let imageView = self.view.viewWithTag(100) else {
            completionHandler(true)
            return
        }
        let xDestinationPoint = self.view.frame.width/2 - 25.0 - imageView.frame.origin.x
        var yDestinationPoint:CGFloat = 0.0
        //handle topSpace as per screenSize
        if UIDevice.current.hasNotch{
            yDestinationPoint = UIDevice.current.topInset + 20
        } else {
            yDestinationPoint = UIDevice.current.topInset + 25
        }
        let yTransform = (imageView.frame.origin.y - yDestinationPoint) * -1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.7) {
                imageView.frame.size.width =  dimensions
                imageView.frame.size.height = dimensions
                imageView.transform = CGAffineTransform(translationX: xDestinationPoint, y: yTransform)
            } completion: { _ in
                completionHandler(true)
            }
        }
    }
    
    func animateDeviceIconToTopForEditDevice(completionHandler:@escaping CompletionHandler){
        guard let imageView = self.view.viewWithTag(100) else {
            completionHandler(true)
            return
        }
        let xDestinationPoint = self.view.frame.width/2 - 40 - imageView.frame.origin.x
     
        //handle topSpace as per screenSize
       var yTransform:CGFloat = 0.0
        if UIDevice.current.hasNotch {
            yTransform = 36
        } else {
            yTransform = 35
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.7) {
                // for edit device screen
               imageView.frame.size.height = 80
               imageView.frame.size.width = 80
               imageView.transform = CGAffineTransform(translationX: xDestinationPoint, y: yTransform)
            } completion: { _ in
                completionHandler(true)
            }
        }
    }
    
    func animateDeviceIconToTopForAssignProfile(completionHandler:@escaping CompletionHandler){
        guard let imageView = self.view.viewWithTag(100) else {
            completionHandler(true)
            return
        }
        let xDestinationPoint = self.view.frame.width/2 - 45 - imageView.frame.origin.x
     
        //handle topSpace as per screenSize
       var yTransform:CGFloat = 0.0
        if UIDevice.current.hasNotch {
            yTransform = 11
        } else {
            yTransform = 3.7
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.7) {
                // for edit device screen
               imageView.frame.size.height = 90
               imageView.frame.size.width = 90
               imageView.transform = CGAffineTransform(translationX: xDestinationPoint, y: yTransform)
            } completion: { _ in
                completionHandler(true)
            }
        }
    }
    
    func animateDeviceIconFromTopToBottom(image:UIImage,with dimensions:CGFloat = 50.0,frame: CGRect = CGRectZero, completionHandler: @escaping CompletionHandler) {
         guard let imageView = self.view.viewWithTag(100) as? UIImageView else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                completionHandler(true)
            }
            return
         }
        imageView.image = image
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIView.animate(withDuration: 0.7) {
                imageView.frame.size.width =  dimensions
                imageView.frame.size.height = dimensions
                if frame == CGRectZero {
                    imageView.transform = .identity
                } else {
                    // if position of connected device in ViewProfileWithDevice change after edit
                    imageView.frame.origin.y = frame.origin.y
                    imageView.frame.origin.x = frame.origin.x
                }
            } completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    completionHandler(true)
                }
            }
        }
    }
    
    func animateDeviceIconFromBottomTopToForEditDevice(image:UIImage, completionHandler: @escaping CompletionHandler) {
         guard let imageView = self.view.viewWithTag(100) as? UIImageView else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                completionHandler(true)
            }
            return
         }
        imageView.image = image
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIView.animate(withDuration: 0.7) {
                imageView.transform = .identity
                // for edit device screen
                imageView.frame.size.width = 50
                imageView.frame.size.height = 50
                
            } completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    completionHandler(true)
                }
            }
        }
    }

    func streamBoxBackAnimation(image:UIImage, completionHandler: @escaping CompletionHandler)
    {
        guard let imageView = self.view.viewWithTag(100) as? UIImageView ,let img = self.view.viewWithTag(101) as? UIImageView,let label = self.view.viewWithTag(102) as? UILabel, let firstView = self.view.viewWithTag(103) else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                completionHandler(true)
            }
            return
        }
        imageView.image = image
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIView.animate(withDuration: 0.7) {
                firstView.transform = .identity
                img.transform = .identity
                label.transform = .identity
                imageView.transform = .identity
                //CMAIOS-2143 Fixed image size
                imageView.frame.size.width = 60
                imageView.frame.size.height = 60
             } completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    completionHandler(true)
                }
            }
        }
    }

    func streamBoxToTop(frame:CGRect, topImageFrame : CGRect, topLabelFrame : CGRect,iconImage: UIImage, topImage1:UIImage,labelText : String, firstViewFrame : CGRect,backGroundColor :UIColor = energyBlueRGB, completionHandler:@escaping CompletionHandler){
        // add ConnectedDevice icon as subview initially
        let imageView:UIImageView =  UIImageView.init(frame: frame)
        let topImage:UIImageView =  UIImageView.init(frame: topImageFrame)
        let topLabel:UILabel =  UILabel.init(frame: topLabelFrame)
        let firstView : UIView = UIView.init(frame: firstViewFrame)
        firstView.frame.origin.y = UIDevice.current.topInset
        firstView.tag = 103
        topLabel.font = UIFont(name: "Regular-Bold", size: 28)
        topLabel.textColor = .white
        imageView.image =  iconImage
        //CMAIOS-2143 Changed content mode
        imageView.contentMode = .center
        imageView.tag = 100
        topImage.image =  topImage1
        topImage.contentMode = .scaleAspectFit
        topImage.tag = 101
        topLabel.text =  labelText
        topLabel.contentMode = .scaleAspectFit
        topLabel.tag = 102
        //Added bg view for streambox animation
        let bgAnimationView : UIView = UIView.init(frame: self.view.frame)
        bgAnimationView.tag = 1000
        bgAnimationView.alpha = 0.3
        bgAnimationView.backgroundColor = backGroundColor
        firstView.addSubview(topImage)
        firstView.addSubview(topLabel)
        bgAnimationView.addSubview(firstView)
        bgAnimationView.addSubview(imageView)
        self.view.addSubview(bgAnimationView)
        UIView.animate(withDuration: 0.5) { [self] in
            //fade out UI Elements with alpha
            self.setAlphaForUIElements(alpha: 0.0)
            bgAnimationView.alpha = 1.0
        } completion: { _ in
            //Move streambox icon to top with animation
            self.animatioOfStreamBoxToTop() { isAnimationCompleted in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    completionHandler(true)
                }
            }
        }
    }
    
    func animatioOfStreamBoxToTop(completionHandler:@escaping CompletionHandler) {
        guard let imageView = self.view.viewWithTag(100), let img = self.view.viewWithTag(101),let label = self.view.viewWithTag(102), let viewTop = self.view.viewWithTag(103) else {
            completionHandler(true)
            return
        }
        let xDestinationPoint = (currentScreenWidth/2 - 30.0)
        var yDestinationPoint:CGFloat = 0.0
        //CMAIOS-2143
        yDestinationPoint = UIDevice.current.topInset + 55
        let yTransform = (imageView.frame.origin.y - yDestinationPoint) * -1
         UIView.animate(withDuration: 0.5) {
             viewTop.transform = CGAffineTransform(translationX: 0, y: -500)
                imageView.transform = CGAffineTransform(translationX: xDestinationPoint - imageView.frame.origin.x, y: yTransform)
             img.transform = CGAffineTransform(translationX: 0, y: -500)
             label.transform = CGAffineTransform(translationX: 0, y: -500)
             imageView.frame.size.height = 10
             imageView.frame.size.width = 60
             } completion: { _ in
                completionHandler(true)
            }
        }
    func trackAndNavigateToChat(chatTransitionType: NavigationType = .Present, chatVC : UIViewController, completionBlock: @escaping CompletionHandler = {_ in}){
            UIView.animate(withDuration: 0) { [self] in
                chatTransitionType == .Push ? self.navigationController?.pushViewController(chatVC, animated: true) : present(chatVC, animated: true)
            } completion: { _ in
                self.trackChatEvent()
                completionBlock(true)
            }
        }
        
        private func trackChatEvent(){
            //CMAIOS-2215 updated custome param
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ASAPChatScreen.Chat_Landing_Page.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT: Intent.General.rawValue])
        }
}
