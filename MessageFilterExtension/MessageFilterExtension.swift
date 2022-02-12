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
        
        // Filter all messages from email addresses
        if (messageSender.lowercased().contains("@")) {
            return .junk
        }
        
        // Filte all messages containing URLs using risky TLDs
        if (hasAbuseiveTld(messageBody: messageBody.lowercased())) {
            return .junk
        }
        
        // Filter all messages containing IPv4 addresses
        let ipRegex = #"\b(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))\b"#
        if (messageBody.range(of: ipRegex, options: .regularExpression) != nil) {
            return .junk
        }
        
        // Filter messages from full phone numbers which mention banks
        let sortedSender = String(messageSender.lowercased().sorted())
        if (sortedSender.range(of: #"\d{7,}"#, options: .regularExpression) != nil) {
            if (hasBankName(messageBody: messageBody.lowercased())) {
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
    for abusiveTld in abusiveTlds {
        if (messageBody.range(of: abusiveTld, options: .regularExpression) != nil) {
            return true
        }
    }
    return false
}

func hasBankName(messageBody: String) -> Bool {
    let bankNames = [
        #"\bafcu\b"#,
        #"\balliant\b"#,
        #"\bally financial\b"#,
        #"\bamerica first\b"#,
        #"\bamerican express\b"#,
        #"\bamericu\b"#,
        #"\bameriprise\b"#,
        #"\bameris\b"#,
        #"\bamex\b"#,
        #"\barvest\b"#,
        #"\batlantic union bank\b"#,
        #"\bbanc-corp\b"#,
        #"\bbancorp\b"#,
        #"\bbancshares\b"#,
        #"\bbank of america\b"#,
        #"\bbank of hawaii\b"#,
        #"\bbank of the west\b"#,
        #"\bbank ozk\b"#,
        #"\bbankunited\b"#,
        #"\bbarclays\b"#,
        #"\bbci financial\b"#,
        #"\bbecu\b"#,
        #"\bbmo harris\b"#,
        #"\bbnp\b"#,
        #"\bbofa\b"#,
        #"\bbok financial\b"#,
        #"\bcadence bank\b"#,
        #"\bcapital one\b"#,
        #"\bcathay bank\b"#,
        #"\bcentral bancompany\b"#,
        #"\bchase\b"#,
        #"\bcibc bank\b"#,
        #"\bcit group\b"#,
        #"\bciti\b"#,
        #"\bcitizens financial\b"#,
        #"\bcity national bank\b"#,
        #"\bcomerica\b"#,
        #"\bcommerce bancshares\b"#,
        #"\bcredit suisse\b"#,
        #"\bcredit union\b"#,
        #"\bdeutsche bank\b"#,
        #"\bdiscover\b"#,
        #"\beast west bank\b"#,
        #"\bfargo\b"#,
        #"\bfifth third\b"#,
        #"\bfirst citizens\b"#,
        #"\bfirst hawaiian bank\b"#,
        #"\bfirst horizon\b"#,
        #"\bfirst interstate\b"#,
        #"\bfirst midwest bank\b"#,
        #"\bfirst national\b"#,
        #"\bfirst republic bank\b"#,
        #"\bfirstbank\b"#,
        #"\bflagstar\b"#,
        #"\bfnb\b"#,
        #"\bgolden1\b"#,
        #"\bhsbc\b"#,
        #"\binvestors bank\b"#,
        #"\bjpmorgan\b"#,
        #"\bkey bank\b"#,
        #"\bkeycorp\b"#,
        #"\bm&t bank\b"#,
        #"\bmaster card\b"#,
        #"\bmidfirst bank\b"#,
        #"\bmufg union\b"#,
        #"\bnavy federal\b"#,
        #"\bncfu\b"#,
        #"\bnew york community bank\b"#,
        #"\bnorthern trust\b"#,
        #"\bnycb\b"#,
        #"\bold national bank\b"#,
        #"\bpacific premier\b"#,
        #"\bpacwest\b"#,
        #"\bpaypal\b"#,
        #"\bpeople's united\b"#,
        #"\bpinnacle financial\b"#,
        #"\bpnc\b"#,
        #"\brbc bank\b"#,
        #"\bregions bank\b"#,
        #"\bregions financial\b"#,
        #"\bsantander bank\b"#,
        #"\bschwab\b"#,
        #"\bsignature bank\b"#,
        #"\bsimmons bank\b"#,
        #"\bsmbc\b"#,
        #"\bsterling\b"#,
        #"\bstifel\b"#,
        #"\bsuncoast\b"#,
        #"\bsvb\b"#,
        #"\bsynchrony\b"#,
        #"\bsynovus\b"#,
        #"\btd bank\b"#,
        #"\btexas capital bank\b"#,
        #"\btiaa\b"#,
        #"\btruist\b"#,
        #"\bubs\b"#,
        #"\bumb financial\b"#,
        #"\bumpqua\b"#,
        #"\bunited bank\b"#,
        #"\bunited community bank\b"#,
        #"\bus bank\b"#,
        #"\busaa\b"#,
        #"\bvisa\b"#,
        #"\bwashington federal\b"#,
        #"\bwebster bank\b"#,
        #"\bwells\b"#,
        #"\bwestern alliance bank\b"#,
        #"\bwintrust\b"#,
        #"\bzions bancorporation\b"#,
    ]
    for bankName in bankNames {
        if (messageBody.range(of: bankName, options: .regularExpression) != nil) {
            return true
        }
    }
    return false
}
