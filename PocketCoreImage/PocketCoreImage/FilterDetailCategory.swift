//
//  FilterDetailCategory.swift
//  PocketCoreImage
//
//  Translated by OOPer in cooperation with shlab.jp, on 2016/1/2.
//
//
/*
     File: FilterDetailCategory.m
 Abstract: Extensions to MainViewController that handle configuring a CIFilter's parameters with
 random values.
  Version: 1.0

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2011 Apple Inc. All Rights Reserved.

 */

import UIKit


extension MainViewController {
    
    //
    // Helper method.
    // Returns an NSDictionary containg only the parameters we want our configure method
    // to operate on.
    static func deriveEditableAttributesForFilter(_ filter: CIFilter) -> [String: Any] {
        var editableAttributes: [String: Any] = [:]
        let filterAttributes = filter.attributes
        
        for (key, attribute) in filterAttributes {
            if key == "CIAttributeFilterCategories"  {continue}
            else if key == "CIAttributeFilterDisplayName" {continue}
            else if key == "inputImage" {continue}
            else if key == "outputImage" {continue}
            else if !(attribute is [AnyHashable: Any]) {continue}
            
            editableAttributes[key] = attribute
        }
        
        return editableAttributes
    }
    
    //
    // Helper function that returns a random float value within the specified range.
    static func randFloat(_ a: Float, _ b: Float) -> Float {
        return ((b-a)*(Float(arc4random())/Float(UInt32.max)))+a;
    }
    
    //
    // Given a filter, examine all its parameters and configure them with randomly generated values.
    static func configureFilter(_ filter: CIFilter) {
        // Get the filter's parameters we're interested in configuring here.
        let editableAttributes = MainViewController.deriveEditableAttributesForFilter(filter)
        
        for (key, attributeDictionary) in editableAttributes as! [String: [String: Any]] {
            
            // Our method here only supports generating random values for parameters that expect numbers.
            // Some paramters take an image, color, or vector.
            if attributeDictionary[kCIAttributeClass] as? String == "NSNumber" {
                
                // The number types are further broken down into sub types.  For our purposes, we
                // can group them into types that require either a boolean, float, or integer.
                let attributeType = attributeDictionary[kCIAttributeType] as? String
                if attributeType == kCIAttributeTypeBoolean {
                    let randomValue = Int(arc4random() % 2)
                    
                    NSLog("Setting %i for key %@ of type BOOL", randomValue, key)
                    filter.setValue(randomValue, forKey: key)
                } else if attributeType == kCIAttributeTypeScalar ||
                    attributeType == kCIAttributeTypeDistance ||
                    attributeType == kCIAttributeTypeAngle
                {
                    // Get the min and max values
                    let maximumValue = (attributeDictionary[kCIAttributeSliderMax] as! NSNumber).floatValue
                    let minimumValue = (attributeDictionary[kCIAttributeSliderMin] as! NSNumber).floatValue
                    
                    let randomValue = randFloat(minimumValue, maximumValue)
                    
                    NSLog("Setting %f for key %@ of type Decimal", randomValue, key)
                    filter.setValue(randomValue, forKey: key)
                } else {
                    // Get the min and max values
                    let maximumValue = attributeDictionary[kCIAttributeMax] as! Int
                    let minimumValue = attributeDictionary[kCIAttributeMin] as! Int
                    
                    let randomValue = (Int(arc4random()) % (maximumValue - minimumValue)) + minimumValue
                    
                    NSLog("Setting %i for key %@ of type Integer", randomValue, key)
                    filter.setValue(randomValue, forKey: key)
                }
                
            }
            
        }
    }
    
}
