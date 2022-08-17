//
//  MessageFilterExtension.swift
//  MessageFilterExtension
//
//  Created by Jonathan Gregson on 2/7/22.
//

import IdentityLookup

final class MessageFilterExtension: ILMessageFilterExtension {}

extension MessageFilterExtension: ILMessageFilterQueryHandling {
    
    func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
        let offlineAction = self.offlineAction(for: queryRequest)
        
        switch offlineAction {
            // Filter messages based on the results of offlineAction
        case .allow, .junk, .promotion, .transaction:
            let response = ILMessageFilterQueryResponse()
            response.action = offlineAction
            completion(response)
            
            // We don't need to send anything over the network
        case .none:
            let response = ILMessageFilterQueryResponse()
            response.action = .none
            completion(response)
            
        @unknown default:
            break
        }
    }
    
    private func offlineAction(for queryRequest: ILMessageFilterQueryRequest) -> ILMessageFilterAction {
        guard let messageSender = queryRequest.sender else {
            return .none
        }
        
        guard let messageBody = queryRequest.messageBody else {
            return .none
        }
        
        let sortedSender = String(messageSender.lowercased().sorted())
        let ipRegex = #"\b(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))\b"#

        // Filter all messages from email addresses
        if (messageSender.lowercased().contains("@")) {
            return .junk
        }
        
        // Filte all messages containing URLs using risky TLDs
        if (hasAbuseiveTld(messageBody: messageBody)) {
            return .junk
        }
        
        // Filter all messages containing IPv4 addresses
        if (messageBody.range(of: ipRegex, options: .regularExpression) != nil) {
            return .junk
        }
        
        // Filter messages from 7+ digit phone numbers which mention banks
        if (sortedSender.range(of: #"\d{7,}"#, options: .regularExpression) != nil) {
            if (hasBankName(messageBody: messageBody)) {
                return .junk
            }
        }
        
        // Filter messages from 7+ digit phone numbers which contain common phishing phrases
        if (sortedSender.range(of: #"\d{7,}"#, options: .regularExpression) != nil) {
            if (hasPhishingPhrase(messageBody: messageBody)) {
                return .junk
            }
        }
        
        // Default action
        return .none;
    }
    
}

func hasAbuseiveTld(messageBody: String) -> Bool {
    let abusiveTlds = [
        #"\b\.amazonaws\.com\b"#,
        #"\b\.amplifyap\.com\b"#,
        #"\b\.au\b"#,
        #"\b\.bar\b"#,
        #"\b\.bd\b"#,
        #"\b\.best\b"#,
        #"\b\.br\b"#,
        #"\b\.business\b"#,
        #"\b\.buzz\b"#,
        #"\b\.cam\b"#,
        #"\b\.casa\b"#,
        #"\b\.cc\b"#,
        #"\b\.center\b"#,
        #"\b\.cloud\b"#,
        #"\b\.cn\b"#,
        #"\b\.cyou\b"#,
        #"\b\.digital\b"#,
        #"\b\.digital\b"#,
        #"\b\.email\b"#,
        #"\b\.fun\b"#,
        #"\b\.funance\b"#,
        #"\b\.godaddysites\.com\b"#,
        #"\b\.host\b"#,
        #"\b\.icu\b"#,
        #"\b\.ik\b"#,
        #"\b\.in\b"#,
        #"\b\.info\b"#,
        #"\b\.ir\b"#,
        #"\b\.ke\b"#,
        #"\b\.ke\b"#,
        #"\b\.link\b"#,
        #"\b\.live\b"#,
        #"\b\.monster\b"#,
        #"\b\.net\b"#,
        #"\b\.netfly\.app\b"#,
        #"\b\.ng\b"#,
        #"\b\.np\b"#,
        #"\b\.one\b"#,
        #"\b\.online\b"#,
        #"\b\.online\b"#,
        #"\b\.pe\b"#,
        #"\b\.ph\b"#,
        #"\b\.pk\b"#,
        #"\b\.pl\b"#,
        #"\b\.quest\b"#,
        #"\b\.rest\b"#,
        #"\b\.ru\b"#,
        #"\b\.sa\b"#,
        #"\b\.sbs\b"#,
        #"\b\.services\b"#,
        #"\b\.shop\b"#,
        #"\b\.site\b"#,
        #"\b\.store\b"#,
        #"\b\.su\b"#,
        #"\b\.support\b"#,
        #"\b\.surf\b"#,
        #"\b\.td\b"#,
        #"\b\.th\b"#,
        #"\b\.tk\b"#,
        #"\b\.top\b"#,
        #"\b\.tr\b"#,
        #"\b\.trycloudflare\.com\b"#,
        #"\b\.uz\b"#,
        #"\b\.ve\b"#,
        #"\b\.vn\b"#,
        #"\b\.wang\b"#,
        #"\b\.web\.app\b"#,
        #"\b\.website\b"#,
        #"\b\.weebly\.com\b"#,
        #"\b\.work\b"#,
        #"\b\.xyz\b"#,
    ]
    
    let filteredMessageBody = messageBody.lowercased()
    for abusiveTld in abusiveTlds {
        if (filteredMessageBody.range(of: abusiveTld, options: .regularExpression) != nil) {
            return true
        }
    }
    return false
}

func hasBankName(messageBody: String) -> Bool {
    let bankNames = [
        #"\bafcu\b"#,
        #"\balliant\b"#,
        #"\ballyfinancial\b"#,
        #"\bamericafirst\b"#,
        #"\bamericanexpress\b"#,
        #"\bamericu\b"#,
        #"\bameriprise\b"#,
        #"\bameris\b"#,
        #"\bamex\b"#,
        #"\barvest\b"#,
        #"\batlanticunionbank\b"#,
        #"\bbanccorp\b"#,
        #"\bbancorp\b"#,
        #"\bbancshares\b"#,
        #"\bbankof\b"#,
        #"\bbankozk\b"#,
        #"\bbankunited\b"#,
        #"\bbarclays\b"#,
        #"\bbcifinancial\b"#,
        #"\bbecu\b"#,
        #"\bbmoharris\b"#,
        #"\bbnp\b"#,
        #"\bbofa\b"#,
        #"\bbokfinancial\b"#,
        #"\bcadencebank\b"#,
        #"\bcapitalone\b"#,
        #"\bcathaybank\b"#,
        #"\bcentralbancompany\b"#,
        #"\bchase\b"#,
        #"\bcibcbank\b"#,
        #"\bcitgroup\b"#,
        #"\bciti\b"#,
        #"\bcitizensfinancial\b"#,
        #"\bcitynationalbank\b"#,
        #"\bcomerica\b"#,
        #"\bcommercebancshares\b"#,
        #"\bcreditsuisse\b"#,
        #"\bcreditunion\b"#,
        #"\bdeutschebank\b"#,
        #"\bdiscover\b"#,
        #"\beastwestbank\b"#,
        #"\bfargo\b"#,
        #"\bfifththird\b"#,
        #"\bfirstcitizens\b"#,
        #"\bfirsthawaiian bank\b"#,
        #"\bfirsthorizon\b"#,
        #"\bfirstinterstate\b"#,
        #"\bfirstmidwest bank\b"#,
        #"\bfirstnational\b"#,
        #"\bfirstrepublic bank\b"#,
        #"\bfirstbank\b"#,
        #"\bflagstar\b"#,
        #"\bfnb\b"#,
        #"\bgolden1\b"#,
        #"\bhsbc\b"#,
        #"\binvestors bank\b"#,
        #"\bjpmorgan\b"#,
        #"\bkeybank\b"#,
        #"\bkeycorp\b"#,
        #"\bm&tbank\b"#,
        #"\bmastercard\b"#,
        #"\bmidfirstbank\b"#,
        #"\bmufgunion\b"#,
        #"\bnavyfederal\b"#,
        #"\bncfu\b"#,
        #"\bnewyorkcommunitybank\b"#,
        #"\bnortherntrust\b"#,
        #"\bnycb\b"#,
        #"\boldnationalbank\b"#,
        #"\bpacificpremier\b"#,
        #"\bpacwest\b"#,
        #"\bpaypal\b"#,
        #"\bpeoplesunited\b"#,
        #"\bpinnaclefinancial\b"#,
        #"\bpnc\b"#,
        #"\brbcbank\b"#,
        #"\bregionsbank\b"#,
        #"\bregionsfinancial\b"#,
        #"\bsantanderbank\b"#,
        #"\bschwab\b"#,
        #"\bsignaturebank\b"#,
        #"\bsimmonsbank\b"#,
        #"\bsmbc\b"#,
        #"\bsterling\b"#,
        #"\bstifel\b"#,
        #"\bsuncoast\b"#,
        #"\bsvb\b"#,
        #"\bsynchrony\b"#,
        #"\bsynovus\b"#,
        #"\btdbank\b"#,
        #"\btexascapitalbank\b"#,
        #"\btiaa\b"#,
        #"\btruist\b"#,
        #"\bubs\b"#,
        #"\bumbfinancial\b"#,
        #"\bumpqua\b"#,
        #"\bunitedbank\b"#,
        #"\bunitedcommunitybank\b"#,
        #"\busbank\b"#,
        #"\busaa\b"#,
        #"\bvisa\b"#,
        #"\bwashingtonfederal\b"#,
        #"\bwebsterbank\b"#,
        #"\bwells\b"#,
        #"\bwesternalliancebank\b"#,
        #"\bwintrust\b"#,
        #"\bzionsbancorporation\b"#,
    ]
    
    let filteredMessageBody = messageBody.lowercased().filter("abcdefghijklmnopqrstuvwxyz0123456789".contains)
    for bankName in bankNames {
        if (filteredMessageBody.range(of: bankName, options: .regularExpression) != nil) {
            return true
        }
    }
    return false
}

func hasPhishingPhrase(messageBody: String) -> Bool {
    let phishingPhrases = [
        #"\bfreepiano\b"#,
        #"\byourorderhasbeen\b"#,
        #"\bcontactcustomercare\b"#,
        #"\bcontactcustomersupport\b"#,
        #"\bifyouwishtocancel\b"#,
        #"\bpleasecall\b"#,
        #"\bdearcustomer\b"#,
        #"\byouraccount\b"#,
        #"\baprize\b"#,
        #"\byouwon\b"#,
        #"\byouvewon\b"#,
        #"\bgiftcard\b"#,
        #"\bgiftcertificate\b"#,
        #"\byourcard\b"#,
        #"\bcardislocked\b"#,
        #"\btemporarilylocked\b"#,
        #"\baccfrozen\b"#,
        #"\baccountfrozen\b"#,
        #"\bcardalert\b"#,
        #"\btaxrefund\b"#,
        #"\btaxreturn\b"#,
        #"\brefunding\b"#,
        #"\byourrefund\b"#,
        #"\bbankaccount\b"#,
        #"\bppackage\b"#,
        #"\bfedex\b"#,
        #"\bups\b"#,
        #"\bdhl\b"#,
        #"\bdelivery\b"#,
        #"\bicloudid\b"#,
        #"\bbitcoin\b"#,
        #"\bconfirmtransaction\b"#,
        #"\bbailmoney\b"#,
        #"\bwesternunion\b"#,
        #"\barrestwarrant\b"#,
        #"\blawsuitagainst\b"#,
        #"\bwarrantagainst\b"#,
        #"\bgooglesecurity\b"#,
        #"\bapplesecurity\b"#,
        #"\bamazonsecurity\b"#,
        #"\bunusualactivity\b"#,
        #"\bunusualsignin\b"#,
        #"\bunusuallogin\b"#,
        #"\brandomlypicked\b"#,
        #"\brandomlyselected\b"#,
        #"\bwinner\b"#,
        #"\bsweepstake\b"#,
        #"\bpayrollproviders\b"#,
    ]
    
    let filteredMessageBody = messageBody.lowercased().filter("abcdefghijklmnopqrstuvwxyz".contains)
    for phishingPhrase in phishingPhrases {
        if (filteredMessageBody.range(of: phishingPhrase, options: .regularExpression) != nil) {
            return true
        }
    }
    return false
}
