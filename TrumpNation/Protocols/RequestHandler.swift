//
//  RequestHandler.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/8/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation
import Alamofire

typealias RequestCompletionHandler = (_ response: Dictionary<String, Any>?, _ error: Error?) -> ()

protocol RequestHandler {
    
    /// Processes and sends a request object
    ///
    /// - Parameters:
    ///   - request: The request object being sent
    ///   - completionHandler: The function being called once a response is received. 
    ///                        Has a dictionary parameter and an error parameter.
    func send(request: Request, completionHandler: @escaping RequestCompletionHandler)
}

extension RequestHandler {
    
    func send(request: Request, completionHandler: @escaping RequestCompletionHandler) {
        Alamofire.request(request.toString).responseJSON { response in
            if let error = response.error {
                let errorCode = response.response?.statusCode ?? 404
                let customError = RequestError.invalidResponse(code: "\(errorCode)", message: error.localizedDescription)
                completionHandler(nil, customError)
                return
            }
            
            if let jsonResponse = response.result.value as? Dictionary<String, Any> {
                completionHandler(jsonResponse, nil)
            } else {
                completionHandler(nil, RequestError.invalidFormat)
            }
        }
    }
}
