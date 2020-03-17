//
//  Message.swift
//  DrawBerry
//
//  Created by Calvin Chen on 12/3/20.
//  Copyright © 2020 DrawBerry. All rights reserved.
//

enum Message {
    static let emptyTextField = "Text fields should not be empty!"
    static let whitespaceOnlyTextField = "Text field should not contain whitespaces only!"
    static let signInError = "Wrong password or user account does not exists"
    static let signUpError = "Unable to register user!"
    static let invalidEmail = "Email address is invalid. \n Format: abc@example.com"
    static let invalidPassword = """
    Password should be alpha-numerical without special characters,
    with at least 8 characters, containing an alphabet and a number.
    """
    static let passwordsDoNotMatch = "Passwords do not match!"
}
