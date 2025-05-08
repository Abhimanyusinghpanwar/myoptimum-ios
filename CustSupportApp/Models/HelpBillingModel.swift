//
//  HelpBillingModel.swift
//  CustSupportApp
//
//  Created by Sudheer Kumar Mundru on 02/11/23.
//

import Foundation

struct HelpBillingModel: Decodable {
    
    var id        : String?
    var text      : String?
    var forScreen : String?
    var data      : [HelpBillingData]?
    var screenTitle : String?
    var screenSubTitle : String?
    
    enum CodingKeys: String, CodingKey {
        case id, text, forScreen, data, screenTitle, screenSubTitle
    }
    
    init(id: String?, text: String?, forScreen: String?, data: [HelpBillingData]?, screenTitle: String?, screenSubTitle :String?)  {
        self.id        = id
        self.text      = text
        self.forScreen = forScreen
        self.data      = data
        self.screenTitle = screenTitle
        self.screenSubTitle = screenSubTitle
    }
    
}

struct HelpBillingData: Decodable {
    
  var startContentWithBold : String?
  var content              : String?
  var hyperLinkText        : String?
  var hyperLinkURL         : String?
  var isImage              : Bool?
  var isBullet             : Bool?

  enum CodingKeys: String, CodingKey {
    case startContentWithBold, content, hyperLinkText, hyperLinkURL, isImage, isBullet
  }

  init(startContentWithBold: String?, content: String?, hyperLinkText: String?, hyperLinkURL: String?, isImage: Bool?, isBullet: Bool? )  {

      self.startContentWithBold = startContentWithBold
      self.content              = content
      self.hyperLinkText        = hyperLinkText
      self.hyperLinkURL         = hyperLinkURL
      self.isImage              = isImage
      self.isBullet             = isBullet
   }

}

