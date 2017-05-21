//
//  FilteredImageView.swift
//  PocketCoreImage
//
//  Translated by OOPer in cooperation with shlab.jp, on 2016/1/2.
//
//
/*
     File: FilteredImageView.h
     File: FilteredImageView.m
 Abstract: UIView subclass that renders a UIImage with a set of filters applied.
 The filters are requested from it's data source.
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

@objc(FilteredViewDatasource)
protocol FilteredViewDatasource: NSObjectProtocol {
    
    var filtersToApply: [CIFilter] {get}
    
}



@objc(FilteredImageView)
class FilteredImageView: UIView {
    private var _filteredImage: CIImage?
    
    @IBOutlet weak var datasource: FilteredViewDatasource!
    
    var inputImage: UIImage? {
        didSet {didSetInputImage(oldValue)}
    }
    
    //
    // Requests the list of filters from the data source and applies each filter
    // in order to the _inputImage.
    func reloadData() {
        guard let inputImage = inputImage else {
            return
        }
        
        // Create a CIImage from the _inputImage.  While UIImage has a property returning
        // a CIImage representation of it, there are cases where it will not work.  This is the
        // most compatible route.
        _filteredImage = CIImage(cgImage: inputImage.cgImage!, options: nil)
        
        // Retrieve the list of CIFilters to apply from our datasource.
        let filters = self.datasource.filtersToApply
        // Iterate through each filter setting our CIImage as the input and re-assigning
        // the filter's output back to our CIImage.  This creates a chaining effect.
        for filter in filters {
            filter.setValue(_filteredImage, forKey:"inputImage")
            // Certain filters place restrictions on their input values that we may not have accounted for
            // in the configuration method.  For example, CIColorCube requires its parameter to be a power
            // of 2.  In such as case, the filter will throw an exception when we ask it generate and image.
            // Catch the exception and pretend nothing happened thereby bypassing the filter.
            //### `NSException` cannot be handled properly in ARC environment. Be careful not to raise exceptions.
            //            @try {
            _filteredImage = filter.outputImage
            //            @catch (NSException* e) { }
        }
        
        // Inform UIKit that we need to be redrawn.
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let _filteredImage = _filteredImage else {
            return
        }
        
        // This is the rect we'll draw our final image into.  By making it a bit smaller than our bounds
        // we'll get a nice border.
        let innerBounds = CGRect(x: 5, y: 5, width: self.bounds.size.width - 10, height: self.bounds.size.height - 10)
        
        // To display the image, convert it back to a UIImage and draw it in our rect.  UIImage takes
        // into account the orientation of an image when drawing which we would have needed to worry about
        // when drawing it directly with Core Image and Core Graphics calls.
        UIImage(ciImage: _filteredImage).draw(in: innerBounds)
    }
    
    private func didSetInputImage(_ inputImage: UIImage?) {
        // Since Core Image filters must be operate on every pixel in an image, you may want to
        // consider resizing an input image to the view size before applying any filters.
        //
        
        self.reloadData()
    }
    
}
